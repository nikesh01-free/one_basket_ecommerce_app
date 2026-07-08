# OneBasket Backend Structure Documentation

This document defines the complete backend architecture, database schema, API endpoints, authentication mechanisms, and infrastructure guidelines for **OneBasket**, a hyperlocal single-vendor ecommerce platform based in Ahmedabad.

---

## 1. Architecture Overview

### Backend Architecture
OneBasket utilizes **Supabase** as its core backend provider, leveraging the following native services to support a serverless, scalable infrastructure:
*   **Database (PostgreSQL):** The transactional database hosting all application state, structured relationships, check constraints, and Row Level Security (RLS) policies.
*   **Authentication (Supabase Auth / GoTrue):** Manages user sign-up, login, session validation, password changes, and JWT token issuance.
*   **Realtime (Supabase Realtime):** Exposes a WebSocket interface to stream database changes (e.g., order status updates) directly to the clients.
*   **Storage (Supabase Storage):** Hosts assets (product images, category images, and avatars) in public and private buckets.
*   **Edge Functions:** Serverless TypeScript/JavaScript runtimes used for orchestrating Stripe payments, handling Stripe webhooks, and triggering notifications.
*   **SMTP Email:** Integrates with a transactional mail provider (e.g., SendGrid, Resend, or custom SMTP) to deliver order confirmations and status changes.
*   **Payments (Stripe):** Handles secure payment capture, tokenization, and processing.

```
┌────────────────────────────────────────────────────────────────────────┐
│                              CLIENT APPS                               │
│  ┌─────────────────────────┐               ┌────────────────────────┐  │
│  │   Customer App (Web/Mo) │               │    Admin Portal (Web)  │  │
│  └────────────┬────────────┘               └───────────┬────────────┘  │
└───────────────┼────────────────────────────────────────┼───────────────┘
                │ HTTPS (PostgREST) / WSS (Realtime)     │
                ▼                                        ▼
┌────────────────────────────────────────────────────────────────────────┐
│                          SUPABASE EDGE GATEWAY                         │
│  ┌───────────────────┐    ┌────────────────────┐    ┌───────────────┐  │
│  │   Supabase Auth   │    │  PostgREST (REST)  │    │   Realtime    │  │
│  └─────────┬─────────┘    └─────────┬──────────┘    └───────┬───────┘  │
└────────────┼────────────────────────┼───────────────────────┼──────────┘
             │                        │                       │
             ▼                        ▼                       ▼
┌────────────────────────────────────────────────────────────────────────┐
│                           POSTGRESQL DATABASE                          │
│   (Row Level Security, Foreign Keys, Functions, Triggers, Indexes)    │
└────────────────────────────────────┬───────────────────────────────────┘
                                     │ Trigger / RPC
                                     ▼
┌────────────────────────────────────────────────────────────────────────┐
│                          SUPABASE EDGE FUNCTIONS                       │
│  ┌─────────────────────────────┐         ┌──────────────────────────┐  │
│  │   Stripe Payment Processor  │         │  Order Notification Hub  │  │
│  └─────────────┬───────────────┘         └─────────────┬────────────┘  │
└────────────────┼───────────────────────────────────────┼───────────────┘
                 │ API Requests                          │ SMTP / API
                 ▼                                       ▼
┌─────────────────────────────────┐       ┌──────────────────────────────┐
│           STRIPE API            │       │        TRANSACTIONAL EMAIL   │
└─────────────────────────────────┘       └──────────────────────────────┘
```

### Request Lifecycle
1.  **Read Operations (Products, Categories):** The client app makes an HTTP `GET` request. The API Gateway forwards the request to PostgREST, which directly queries the database. RLS filters results based on user status (e.g., `is_active` products only for normal users). Results are formatted in JSON and returned.
2.  **Write Operations (Cart, Wishlist, Addresses):** The client makes authenticated `POST/PATCH/DELETE` requests with a JWT in the `Authorization: Bearer` header. PostgREST executes RLS, matching `auth.uid() = user_id` in database checks before writing data.
3.  **Payment Lifecycle (Stripe Checkout):**
    *   Client posts cart items and address to the `/checkout/stripe-intent` Edge Function.
    *   Edge Function queries database product prices, calculates the total, registers a `pending` order in the database, and requests a `PaymentIntent` from Stripe.
    *   Stripe returns a `client_secret`; Edge Function sends this and the generated `order_id` back to the client.
    *   Client confirms the payment with Stripe via the mobile/web Stripe SDK.
    *   Stripe calls the `/stripe-webhook` Edge Function after payment capture.
    *   Webhook validates the signature, updates the order status to `confirmed`, shifts payment status to `paid`, decrements inventory, and triggers email notifications.
4.  **Cash on Delivery (COD) Checkout:**
    *   Client posts cart items and address to `/checkout/cod`.
    *   Order is immediately validated, inventory checked and decremented, and the order is inserted with status `pending`, payment status `pending`, and payment method `cod`.
    *   An email confirmation is dispatched.

---

## 2. Database Schema

The database relies on strict constraints, appropriate foreign keys, index optimization, and automatic update triggers.

### Triggers & Global Helpers
The database uses a standard plpgsql trigger to update `updated_at` columns automatically.

```sql
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

### Table Specifications

#### 1. users (public.users)
Mirrors and extends the `auth.users` table for metadata queries and foreign key referencing.
*   **Cardinality:**
    *   `users` 1 ── 1 `profiles`
    *   `users` 1 ── 0..1 `admin_users`
    *   `users` 1 ── 0..* `addresses`
    *   `users` 1 ── 0..* `orders`

| Column | Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `UUID` | `PRIMARY KEY`, `REFERENCES auth.users(id) ON DELETE CASCADE` | - | Unique user identifier mapping to auth system. |
| `email` | `VARCHAR(255)` | `NOT NULL`, `UNIQUE` | - | Email address synced from authentication provider. |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL` | `now()` | Record creation timestamp. |
| `updated_at` | `TIMESTAMPTZ` | `NOT NULL` | `now()` | Record last update timestamp. |

#### 2. profiles (public.profiles)
Holds basic customer profile information.
*   **Cardinality:** 1-to-1 relationship with `public.users`.

| Column | Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `UUID` | `PRIMARY KEY`, `REFERENCES public.users(id) ON DELETE CASCADE` | - | Identifies the profile owner. |
| `first_name` | `VARCHAR(100)` | - | - | User's first name. |
| `last_name` | `VARCHAR(100)` | - | - | User's last name. |
| `phone` | `VARCHAR(20)` | - | - | Contact phone number. |
| `avatar_url` | `TEXT` | - | - | Public URL of user avatar uploaded to storage. |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL` | `now()` | Record creation timestamp. |
| `updated_at` | `TIMESTAMPTZ` | `NOT NULL` | `now()` | Record last update timestamp. |

#### 3. sessions (public.sessions)
Custom table for logging active customer sessions, tracking IPs, and managing manual logout tokens.
*   **Cardinality:** Many-to-1 relationship with `public.users`.

| Column | Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `UUID` | `PRIMARY KEY` | `gen_random_uuid()` | Unique session identifier. |
| `user_id` | `UUID` | `NOT NULL`, `REFERENCES public.users(id) ON DELETE CASCADE` | - | Associated user account. |
| `token_hash` | `VARCHAR(255)` | `NOT NULL`, `UNIQUE` | - | SHA-256 hashed signature of token. |
| `expires_at` | `TIMESTAMPTZ` | `NOT NULL` | - | Session expiration date/time. |
| `user_agent` | `TEXT` | - | - | Browser or device user agent. |
| `ip_address` | `VARCHAR(45)` | - | - | Client IPv4 or IPv6 address. |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL` | `now()` | Session initialization timestamp. |
| `updated_at` | `TIMESTAMPTZ` | `NOT NULL` | `now()` | Session update timestamp. |

#### 4. categories (public.categories)
Groups products.
*   **Cardinality:** 1 category can map to many products.

| Column | Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `UUID` | `PRIMARY KEY` | `gen_random_uuid()` | Unique category identifier. |
| `name` | `VARCHAR(100)` | `NOT NULL`, `UNIQUE` | - | Human readable name. |
| `slug` | `VARCHAR(100)` | `NOT NULL`, `UNIQUE` | - | URL-friendly URL identifier. |
| `description` | `TEXT` | - | - | Detailed category details. |
| `image_url` | `TEXT` | - | - | Category banner image URL. |
| `is_active` | `BOOLEAN` | `NOT NULL` | `true` | Enables/disables category display on client. |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL` | `now()` | Record creation timestamp. |
| `updated_at` | `TIMESTAMPTZ` | `NOT NULL` | `now()` | Record last update timestamp. |

#### 5. products (public.products)
Main product catalog definition.
*   **Cardinality:**
    *   `products` * ── 1 `categories` (ON DELETE SET NULL)
    *   `products` 1 ── * `product_images` (ON DELETE CASCADE)
    *   `products` 1 ── * `product_variants` (ON DELETE CASCADE)

| Column | Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `UUID` | `PRIMARY KEY` | `gen_random_uuid()` | Unique product identifier. |
| `category_id` | `UUID` | `REFERENCES public.categories(id) ON DELETE SET NULL` | - | Associated category. |
| `name` | `VARCHAR(255)` | `NOT NULL` | - | Product title. |
| `slug` | `VARCHAR(255)` | `NOT NULL`, `UNIQUE` | - | URL slug. |
| `description` | `TEXT` | - | - | HTML or markdown description. |
| `price` | `DECIMAL(10,2)`| `NOT NULL`, `CHECK (price >= 0.00)` | - | Default base product retail price in INR. |
| `is_active` | `BOOLEAN` | `NOT NULL` | `true` | Toggles product visibility (soft delete). |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL` | `now()` | Record creation timestamp. |
| `updated_at` | `TIMESTAMPTZ` | `NOT NULL` | `now()` | Record last update timestamp. |

#### 6. product_images (public.product_images)
Stores multiple product media assets.
*   **Cardinality:** Many-to-1 relationship with `public.products`.

| Column | Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `UUID` | `PRIMARY KEY` | `gen_random_uuid()` | Unique asset identifier. |
| `product_id` | `UUID` | `NOT NULL`, `REFERENCES public.products(id) ON DELETE CASCADE` | - | Product parent. |
| `url` | `TEXT` | `NOT NULL` | - | Public CDN URL of product image. |
| `display_order` | `INTEGER` | `NOT NULL`, `CHECK (display_order >= 0)` | `0` | Sequence identifier to sort image view. |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL` | `now()` | Record creation timestamp. |
| `updated_at` | `TIMESTAMPTZ` | `NOT NULL` | `now()` | Record last update timestamp. |

#### 7. product_variants (public.product_variants)
Defines sellable items (size, weight, pack variations).
*   **Cardinality:**
    *   `product_variants` * ── 1 `products`
    *   `product_variants` 1 ── 1 `inventory`

| Column | Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `UUID` | `PRIMARY KEY` | `gen_random_uuid()` | Unique variant identifier. |
| `product_id` | `UUID` | `NOT NULL`, `REFERENCES public.products(id) ON DELETE CASCADE` | - | Product parent. |
| `name` | `VARCHAR(100)` | `NOT NULL` | - | Variant description, e.g., "500g", "1kg", "Pack of 2". |
| `sku` | `VARCHAR(100)` | `NOT NULL`, `UNIQUE` | - | Stock Keeping Unit. |
| `price_override`| `DECIMAL(10,2)`| `CHECK (price_override >= 0.00)` | `NULL` | Optional specific price overriding base product price. |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL` | `now()` | Record creation timestamp. |
| `updated_at` | `TIMESTAMPTZ` | `NOT NULL` | `now()` | Record last update timestamp. |

#### 8. inventory (public.inventory)
Keeps track of physical stock levels.
*   **Cardinality:** 1-to-1 relationship with `public.product_variants`.

| Column | Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `UUID` | `PRIMARY KEY` | `gen_random_uuid()` | Unique inventory identifier. |
| `product_variant_id`| `UUID` | `NOT NULL`, `UNIQUE`, `REFERENCES public.product_variants(id) ON DELETE CASCADE` | - | Associated variant. |
| `quantity` | `INTEGER` | `NOT NULL`, `CHECK (quantity >= 0)` | `0` | Available items in physical warehouse. |
| `low_stock_threshold`| `INTEGER`| `NOT NULL`, `CHECK (low_stock_threshold >= 0)`| `5` | Threshold triggering warnings in Admin portal. |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL` | `now()` | Record creation timestamp. |
| `updated_at` | `TIMESTAMPTZ` | `NOT NULL` | `now()` | Record last update timestamp. |

#### 9. cart (public.cart)
User shopping cart container.
*   **Cardinality:** 1-to-1 relationship with `public.users`.

| Column | Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `UUID` | `PRIMARY KEY` | `gen_random_uuid()` | Unique cart identifier. |
| `user_id` | `UUID` | `NOT NULL`, `UNIQUE`, `REFERENCES public.users(id) ON DELETE CASCADE` | - | Associated user owner. |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL` | `now()` | Record creation timestamp. |
| `updated_at` | `TIMESTAMPTZ` | `NOT NULL` | `now()` | Record last update timestamp. |

#### 10. cart_items (public.cart_items)
Line items within user cart.
*   **Cardinality:** Many-to-1 relationship with `public.cart` and `public.product_variants`.

| Column | Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `UUID` | `PRIMARY KEY` | `gen_random_uuid()` | Unique item identifier. |
| `cart_id` | `UUID` | `NOT NULL`, `REFERENCES public.cart(id) ON DELETE CASCADE` | - | Parent cart reference. |
| `product_variant_id`| `UUID` | `NOT NULL`, `REFERENCES public.product_variants(id) ON DELETE CASCADE` | - | Selected variant. |
| `quantity` | `INTEGER` | `NOT NULL`, `CHECK (quantity > 0)` | `1` | Selected quantity. |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL` | `now()` | Record creation timestamp. |
| `updated_at` | `TIMESTAMPTZ` | `NOT NULL` | `now()` | Record last update timestamp. |

*   **Composite Constraint:** `UNIQUE (cart_id, product_variant_id)` avoids duplicate rows.

#### 11. wishlist (public.wishlist)
User wishlist container.
*   **Cardinality:** 1-to-1 relationship with `public.users`.

| Column | Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `UUID` | `PRIMARY KEY` | `gen_random_uuid()` | Unique wishlist identifier. |
| `user_id` | `UUID` | `NOT NULL`, `UNIQUE`, `REFERENCES public.users(id) ON DELETE CASCADE` | - | Associated user owner. |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL` | `now()` | Record creation timestamp. |
| `updated_at` | `TIMESTAMPTZ` | `NOT NULL` | `now()` | Record last update timestamp. |

#### 12. wishlist_items (public.wishlist_items)
Line items in user wishlist.
*   **Cardinality:** Many-to-1 relationship with `public.wishlist` and `public.products`.

| Column | Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `UUID` | `PRIMARY KEY` | `gen_random_uuid()` | Unique item identifier. |
| `wishlist_id` | `UUID` | `NOT NULL`, `REFERENCES public.wishlist(id) ON DELETE CASCADE` | - | Parent wishlist. |
| `product_id` | `UUID` | `NOT NULL`, `REFERENCES public.products(id) ON DELETE CASCADE` | - | Saved product. |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL` | `now()` | Record creation timestamp. |
| `updated_at` | `TIMESTAMPTZ` | `NOT NULL` | `now()` | Record last update timestamp. |

*   **Composite Constraint:** `UNIQUE (wishlist_id, product_id)` avoids duplication.

#### 13. addresses (public.addresses)
Delivery addresses saved by customers.
*   **Cardinality:** Many-to-1 relationship with `public.users`.

| Column | Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `UUID` | `PRIMARY KEY` | `gen_random_uuid()` | Unique address identifier. |
| `user_id` | `UUID` | `NOT NULL`, `REFERENCES public.users(id) ON DELETE CASCADE` | - | Address owner. |
| `recipient_name` | `VARCHAR(100)` | `NOT NULL` | - | Full name of recipient. |
| `recipient_phone`| `VARCHAR(20)` | `NOT NULL` | - | Delivery contact number. |
| `street_address` | `TEXT` | `NOT NULL` | - | House/building number, street, area. |
| `landmark` | `TEXT` | - | - | Near identifier context. |
| `city` | `VARCHAR(100)` | `NOT NULL` | `'Ahmedabad'` | Target city (Ahmedabad-restricted in validation). |
| `pincode` | `VARCHAR(10)` | `NOT NULL` | - | Delivery area postal code. |
| `is_default` | `BOOLEAN` | `NOT NULL` | `false` | Fallback address flag. |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL` | `now()` | Record creation timestamp. |
| `updated_at` | `TIMESTAMPTZ` | `NOT NULL` | `now()` | Record last update timestamp. |

#### 14. orders (public.orders)
Purchase order status and cost summary.
*   **Cardinality:**
    *   `orders` * ── 1 `users` (ON DELETE SET NULL)
    *   `orders` * ── 1 `addresses` (ON DELETE SET NULL)
    *   `orders` 1 ── * `order_items` (ON DELETE CASCADE)
    *   `orders` 1 ── 0..1 `coupon_usage` (ON DELETE CASCADE)

| Column | Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `UUID` | `PRIMARY KEY` | `gen_random_uuid()` | Unique order invoice identifier. |
| `user_id` | `UUID` | `REFERENCES public.users(id) ON DELETE SET NULL` | - | Purchasing customer account. |
| `address_id` | `UUID` | `REFERENCES public.addresses(id) ON DELETE SET NULL` | - | Delivery destination. |
| `status` | `VARCHAR(50)` | `NOT NULL`, `CHECK (status IN ('pending', 'confirmed', 'shipped', 'delivered', 'cancelled'))` | `'pending'` | Current fulfillment stage. |
| `subtotal` | `DECIMAL(10,2)`| `NOT NULL`, `CHECK (subtotal >= 0.00)` | - | Total price before discounts. |
| `discount_amount`| `DECIMAL(10,2)`| `NOT NULL`, `CHECK (discount_amount >= 0.00)`| `0.00` | Applied savings from coupons. |
| `shipping_fee` | `DECIMAL(10,2)`| `NOT NULL`, `CHECK (shipping_fee >= 0.00)` | `0.00` | Local shipment cost. |
| `total` | `DECIMAL(10,2)`| `NOT NULL`, `CHECK (total >= 0.00)` | - | Final charged sum. |
| `coupon_code` | `VARCHAR(50)` | - | - | Redundant code tracking string. |
| `payment_method` | `VARCHAR(50)` | `NOT NULL`, `CHECK (payment_method IN ('stripe', 'cod'))` | - | Transaction mechanism. |
| `payment_status` | `VARCHAR(50)` | `NOT NULL`, `CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded'))` | `'pending'` | Financial transaction state. |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL` | `now()` | Order placement time. |
| `updated_at` | `TIMESTAMPTZ` | `NOT NULL` | `now()` | Record update timestamp. |

#### 15. order_items (public.order_items)
List of variants purchased in a specific order.
*   **Cardinality:** Many-to-1 relationship with `public.orders` and `public.product_variants`.

| Column | Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `UUID` | `PRIMARY KEY` | `gen_random_uuid()` | Unique line item identifier. |
| `order_id` | `UUID` | `NOT NULL`, `REFERENCES public.orders(id) ON DELETE CASCADE` | - | Parent order reference. |
| `product_variant_id`| `UUID`| `REFERENCES public.product_variants(id) ON DELETE SET NULL` | - | Ordered variant. |
| `quantity` | `INTEGER` | `NOT NULL`, `CHECK (quantity > 0)` | - | Number of items purchased. |
| `price_per_unit`| `DECIMAL(10,2)`| `NOT NULL`, `CHECK (price_per_unit >= 0.00)` | - | Snapshot unit price in INR. |
| `total_price` | `DECIMAL(10,2)`| `NOT NULL`, `CHECK (total_price >= 0.00)` | - | Units * price. |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL` | `now()` | Record creation timestamp. |
| `updated_at` | `TIMESTAMPTZ` | `NOT NULL` | `now()` | Record last update timestamp. |

#### 16. payments (public.payments)
Logs financial transaction history.
*   **Cardinality:** Many-to-1 relationship with `public.orders`.

| Column | Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `UUID` | `PRIMARY KEY` | `gen_random_uuid()` | Unique transaction log ID. |
| `order_id` | `UUID` | `NOT NULL`, `REFERENCES public.orders(id) ON DELETE RESTRICT` | - | Associated order. |
| `stripe_payment_intent_id`| `VARCHAR(255)`| `UNIQUE` | - | Stripe external intent key identifier. |
| `amount` | `DECIMAL(10,2)`| `NOT NULL`, `CHECK (amount >= 0.00)` | - | Payment sum. |
| `currency` | `VARCHAR(10)` | `NOT NULL` | `'INR'` | Price ISO tag. |
| `status` | `VARCHAR(50)` | `NOT NULL`, `CHECK (status IN ('pending', 'succeeded', 'failed', 'refunded'))` | - | Verification status of transaction. |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL` | `now()` | Record creation timestamp. |
| `updated_at` | `TIMESTAMPTZ` | `NOT NULL` | `now()` | Record last update timestamp. |

#### 17. coupons (public.coupons)
Rules for cart promotions.
*   **Cardinality:**
    *   `coupons` 1 ── * `coupon_usage`

| Column | Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `UUID` | `PRIMARY KEY` | `gen_random_uuid()` | Unique promotion rule ID. |
| `code` | `VARCHAR(50)` | `NOT NULL`, `UNIQUE` | - | Raw alphanumeric code applied. |
| `discount_type` | `VARCHAR(20)` | `NOT NULL`, `CHECK (discount_type IN ('flat', 'percentage'))` | - | Discount computation method. |
| `value` | `DECIMAL(10,2)`| `NOT NULL`, `CHECK (value > 0.00)` | - | Numeric savings (in INR or % weight). |
| `min_order_value`| `DECIMAL(10,2)`| `NOT NULL`, `CHECK (min_order_value >= 0.00)`| `0.00` | Cart subtotal check parameter. |
| `max_discount` | `DECIMAL(10,2)`| `CHECK (max_discount >= 0.00)` | - | Ceiling cap for percentage coupons. |
| `usage_limit` | `INTEGER` | `CHECK (usage_limit >= 0)` | - | Max total coupon use count globally. |
| `expiry_date` | `TIMESTAMPTZ` | `NOT NULL` | - | Coupon expiration date. |
| `is_active` | `BOOLEAN` | `NOT NULL` | `true` | Admin toggle control state. |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL` | `now()` | Record creation timestamp. |
| `updated_at` | `TIMESTAMPTZ` | `NOT NULL` | `now()` | Record last update timestamp. |

#### 18. coupon_usage (public.coupon_usage)
Tracks when a specific customer uses a coupon for an order.
*   **Cardinality:** Many-to-1 relationship with `public.coupons` and `public.users`.

| Column | Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `UUID` | `PRIMARY KEY` | `gen_random_uuid()` | Unique usage log identifier. |
| `coupon_id` | `UUID` | `NOT NULL`, `REFERENCES public.coupons(id) ON DELETE CASCADE` | - | Applied promotion rule. |
| `user_id` | `UUID` | `NOT NULL`, `REFERENCES public.users(id) ON DELETE CASCADE` | - | Claiming customer. |
| `order_id` | `UUID` | `NOT NULL`, `UNIQUE`, `REFERENCES public.orders(id) ON DELETE CASCADE` | - | Target order receipt. |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL` | `now()` | Transaction execution timestamp. |
| `updated_at` | `TIMESTAMPTZ` | `NOT NULL` | `now()` | Record last update timestamp. |

#### 19. reviews (public.reviews)
Customers submitting product ratings and comments.
*   **Cardinality:** Many-to-1 relationship with `public.products` and `public.users`.

| Column | Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `UUID` | `PRIMARY KEY` | `gen_random_uuid()` | Unique feedback identifier. |
| `product_id` | `UUID` | `NOT NULL`, `REFERENCES public.products(id) ON DELETE CASCADE` | - | Rated product. |
| `user_id` | `UUID` | `NOT NULL`, `REFERENCES public.users(id) ON DELETE CASCADE` | - | Author customer account. |
| `rating` | `INTEGER` | `NOT NULL`, `CHECK (rating >= 1 AND rating <= 5)` | - | Assigned stars rating (1-5). |
| `comment` | `TEXT` | - | - | Written feedback review text. |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL` | `now()` | Record creation timestamp. |
| `updated_at` | `TIMESTAMPTZ` | `NOT NULL` | `now()` | Record last update timestamp. |

*   **Composite Constraint:** `UNIQUE (product_id, user_id)` restricts feedback to one review per product per customer.

#### 20. notifications (public.notifications)
System announcements and status alerts.
*   **Cardinality:** Many-to-1 relationship with `public.users`.

| Column | Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `UUID` | `PRIMARY KEY` | `gen_random_uuid()` | Unique notification ID. |
| `user_id` | `UUID` | `NOT NULL`, `REFERENCES public.users(id) ON DELETE CASCADE` | - | Recipient target account. |
| `title` | `VARCHAR(255)` | `NOT NULL` | - | High level notification subject. |
| `message` | `TEXT` | `NOT NULL` | - | Notification body context. |
| `is_read` | `BOOLEAN` | `NOT NULL` | `false` | Read status tracking flag. |
| `type` | `VARCHAR(50)` | `NOT NULL` | `'general'` | Filter tag e.g. `'order_status'`, `'promo'`. |
| `reference_id` | `UUID` | - | - | Optional dynamic entity key (e.g. `order_id`). |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL` | `now()` | Dispatch timestamp. |
| `updated_at` | `TIMESTAMPTZ` | `NOT NULL` | `now()` | Record update timestamp. |

#### 21. admin_users (public.admin_users)
Elevated identities capable of configuring parameters.
*   **Cardinality:** 1-to-1 relationship with `public.users`.

| Column | Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `UUID` | `PRIMARY KEY`, `REFERENCES public.users(id) ON DELETE CASCADE` | - | References authorized user ID. |
| `role` | `VARCHAR(50)` | `NOT NULL`, `CHECK (role IN ('super_admin', 'admin', 'manager'))` | `'admin'` | Staff access role. |
| `is_active` | `BOOLEAN` | `NOT NULL` | `true` | Toggles staff platform control. |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL` | `now()` | Record creation timestamp. |
| `updated_at` | `TIMESTAMPTZ` | `NOT NULL` | `now()` | Record last update timestamp. |

#### 22. audit_logs (public.audit_logs)
Audit trail tracks admin configurations and events.
*   **Cardinality:** Many-to-1 relationship with `public.users` (the operator).

| Column | Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `UUID` | `PRIMARY KEY` | `gen_random_uuid()` | Unique log sequence key. |
| `user_id` | `UUID` | `REFERENCES public.users(id) ON DELETE SET NULL` | - | Action operator account. |
| `action` | `VARCHAR(255)` | `NOT NULL` | - | Described action string (e.g. `'UPDATE_PRODUCT'`). |
| `entity_name` | `VARCHAR(100)` | `NOT NULL` | - | Affected table database tag (e.g. `'products'`). |
| `entity_id` | `UUID` | - | - | Unique key of modified entity row. |
| `previous_state`| `JSONB` | - | - | Snapshot payload before execution. |
| `new_state` | `JSONB` | - | - | Snapshot payload post execution. |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL` | `now()` | Operation completion time. |
| `updated_at` | `TIMESTAMPTZ` | `NOT NULL` | `now()` | Record last update timestamp. |

---

### SQL CREATE TABLE Statements

```sql
-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =========================================================================
-- 1. users
-- =========================================================================
CREATE TABLE public.users (
  id UUID PRIMARY KEY, -- Maps directly to auth.users.id
  email VARCHAR(255) UNIQUE NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- =========================================================================
-- 2. profiles
-- =========================================================================
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  phone VARCHAR(20),
  avatar_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- =========================================================================
-- 3. sessions
-- =========================================================================
CREATE TABLE public.sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  token_hash VARCHAR(255) UNIQUE NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  user_agent TEXT,
  ip_address VARCHAR(45),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- =========================================================================
-- 4. categories
-- =========================================================================
CREATE TABLE public.categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) UNIQUE NOT NULL,
  slug VARCHAR(100) UNIQUE NOT NULL,
  description TEXT,
  image_url TEXT,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- =========================================================================
-- 5. products
-- =========================================================================
CREATE TABLE public.products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
  name VARCHAR(255) NOT NULL,
  slug VARCHAR(255) UNIQUE NOT NULL,
  description TEXT,
  price DECIMAL(10, 2) NOT NULL CHECK (price >= 0.00),
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- =========================================================================
-- 6. product_images
-- =========================================================================
CREATE TABLE public.product_images (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  url TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0 CHECK (display_order >= 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- =========================================================================
-- 7. product_variants
-- =========================================================================
CREATE TABLE public.product_variants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  sku VARCHAR(100) UNIQUE NOT NULL,
  price_override DECIMAL(10, 2) CHECK (price_override >= 0.00),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- =========================================================================
-- 8. inventory
-- =========================================================================
CREATE TABLE public.inventory (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_variant_id UUID UNIQUE NOT NULL REFERENCES public.product_variants(id) ON DELETE CASCADE,
  quantity INTEGER NOT NULL DEFAULT 0 CHECK (quantity >= 0),
  low_stock_threshold INTEGER NOT NULL DEFAULT 5 CHECK (low_stock_threshold >= 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- =========================================================================
-- 9. cart
-- =========================================================================
CREATE TABLE public.cart (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID UNIQUE NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- =========================================================================
-- 10. cart_items
-- =========================================================================
CREATE TABLE public.cart_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  cart_id UUID NOT NULL REFERENCES public.cart(id) ON DELETE CASCADE,
  product_variant_id UUID NOT NULL REFERENCES public.product_variants(id) ON DELETE CASCADE,
  quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT unique_cart_variant UNIQUE (cart_id, product_variant_id)
);

-- =========================================================================
-- 11. wishlist
-- =========================================================================
CREATE TABLE public.wishlist (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID UNIQUE NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- =========================================================================
-- 12. wishlist_items
-- =========================================================================
CREATE TABLE public.wishlist_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wishlist_id UUID NOT NULL REFERENCES public.wishlist(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT unique_wishlist_product UNIQUE (wishlist_id, product_id)
);

-- =========================================================================
-- 13. addresses
-- =========================================================================
CREATE TABLE public.addresses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  recipient_name VARCHAR(100) NOT NULL,
  recipient_phone VARCHAR(20) NOT NULL,
  street_address TEXT NOT NULL,
  landmark TEXT,
  city VARCHAR(100) NOT NULL DEFAULT 'Ahmedabad',
  pincode VARCHAR(10) NOT NULL,
  is_default BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- =========================================================================
-- 14. orders
-- =========================================================================
CREATE TABLE public.orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
  address_id UUID REFERENCES public.addresses(id) ON DELETE SET NULL,
  status VARCHAR(50) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'shipped', 'delivered', 'cancelled')),
  subtotal DECIMAL(10, 2) NOT NULL CHECK (subtotal >= 0.00),
  discount_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00 CHECK (discount_amount >= 0.00),
  shipping_fee DECIMAL(10, 2) NOT NULL DEFAULT 0.00 CHECK (shipping_fee >= 0.00),
  total DECIMAL(10, 2) NOT NULL CHECK (total >= 0.00),
  coupon_code VARCHAR(50),
  payment_method VARCHAR(50) NOT NULL CHECK (payment_method IN ('stripe', 'cod')),
  payment_status VARCHAR(50) NOT NULL DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- =========================================================================
-- 15. order_items
-- =========================================================================
CREATE TABLE public.order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
  product_variant_id UUID REFERENCES public.product_variants(id) ON DELETE SET NULL,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  price_per_unit DECIMAL(10, 2) NOT NULL CHECK (price_per_unit >= 0.00),
  total_price DECIMAL(10, 2) NOT NULL CHECK (total_price >= 0.00),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- =========================================================================
-- 16. payments
-- =========================================================================
CREATE TABLE public.payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE RESTRICT,
  stripe_payment_intent_id VARCHAR(255) UNIQUE,
  amount DECIMAL(10, 2) NOT NULL CHECK (amount >= 0.00),
  currency VARCHAR(10) NOT NULL DEFAULT 'INR',
  status VARCHAR(50) NOT NULL CHECK (status IN ('pending', 'succeeded', 'failed', 'refunded')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- =========================================================================
-- 17. coupons
-- =========================================================================
CREATE TABLE public.coupons (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(50) UNIQUE NOT NULL,
  discount_type VARCHAR(20) NOT NULL CHECK (discount_type IN ('flat', 'percentage')),
  value DECIMAL(10, 2) NOT NULL CHECK (value > 0.00),
  min_order_value DECIMAL(10, 2) NOT NULL DEFAULT 0.00 CHECK (min_order_value >= 0.00),
  max_discount DECIMAL(10, 2) CHECK (max_discount >= 0.00),
  usage_limit INTEGER CHECK (usage_limit >= 0),
  expiry_date TIMESTAMPTZ NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- =========================================================================
-- 18. coupon_usage
-- =========================================================================
CREATE TABLE public.coupon_usage (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  coupon_id UUID NOT NULL REFERENCES public.coupons(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  order_id UUID UNIQUE NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- =========================================================================
-- 19. reviews
-- =========================================================================
CREATE TABLE public.reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT unique_product_user_review UNIQUE (product_id, user_id)
);

-- =========================================================================
-- 20. notifications
-- =========================================================================
CREATE TABLE public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  is_read BOOLEAN NOT NULL DEFAULT false,
  type VARCHAR(50) NOT NULL DEFAULT 'general',
  reference_id UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- =========================================================================
-- 21. admin_users
-- =========================================================================
CREATE TABLE public.admin_users (
  id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
  role VARCHAR(50) NOT NULL DEFAULT 'admin' CHECK (role IN ('super_admin', 'admin', 'manager')),
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- =========================================================================
-- 22. audit_logs
-- =========================================================================
CREATE TABLE public.audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
  action VARCHAR(255) NOT NULL,
  entity_name VARCHAR(100) NOT NULL,
  entity_id UUID,
  previous_state JSONB,
  new_state JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- =========================================================================
-- Assigning Update Triggers
-- =========================================================================
CREATE TRIGGER trigger_update_users BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trigger_update_profiles BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trigger_update_sessions BEFORE UPDATE ON public.sessions FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trigger_update_categories BEFORE UPDATE ON public.categories FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trigger_update_products BEFORE UPDATE ON public.products FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trigger_update_product_images BEFORE UPDATE ON public.product_images FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trigger_update_product_variants BEFORE UPDATE ON public.product_variants FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trigger_update_inventory BEFORE UPDATE ON public.inventory FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trigger_update_cart BEFORE UPDATE ON public.cart FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trigger_update_cart_items BEFORE UPDATE ON public.cart_items FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trigger_update_wishlist BEFORE UPDATE ON public.wishlist FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trigger_update_wishlist_items BEFORE UPDATE ON public.wishlist_items FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trigger_update_addresses BEFORE UPDATE ON public.addresses FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trigger_update_orders BEFORE UPDATE ON public.orders FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trigger_update_order_items BEFORE UPDATE ON public.order_items FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trigger_update_payments BEFORE UPDATE ON public.payments FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trigger_update_coupons BEFORE UPDATE ON public.coupons FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trigger_update_coupon_usage BEFORE UPDATE ON public.coupon_usage FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trigger_update_reviews BEFORE UPDATE ON public.reviews FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trigger_update_notifications BEFORE UPDATE ON public.notifications FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trigger_update_admin_users BEFORE UPDATE ON public.admin_users FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trigger_update_audit_logs BEFORE UPDATE ON public.audit_logs FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- =========================================================================
-- Performance Optimization Indexes
-- =========================================================================
CREATE INDEX idx_profiles_phone ON public.profiles(phone);
CREATE INDEX idx_sessions_user_id ON public.sessions(user_id);
CREATE INDEX idx_products_category_id ON public.products(category_id);
CREATE INDEX idx_product_images_product_id ON public.product_images(product_id);
CREATE INDEX idx_product_variants_product_id ON public.product_variants(product_id);
CREATE INDEX idx_cart_items_cart_id ON public.cart_items(cart_id);
CREATE INDEX idx_wishlist_items_wishlist_id ON public.wishlist_items(wishlist_id);
CREATE INDEX idx_addresses_user_id ON public.addresses(user_id);
CREATE INDEX idx_orders_user_id ON public.orders(user_id);
CREATE INDEX idx_orders_status ON public.orders(status);
CREATE INDEX idx_orders_created_at ON public.orders(created_at DESC);
CREATE INDEX idx_order_items_order_id ON public.order_items(order_id);
CREATE INDEX idx_payments_order_id ON public.payments(order_id);
CREATE INDEX idx_coupon_usage_coupon_id ON public.coupon_usage(coupon_id);
CREATE INDEX idx_coupon_usage_user_id ON public.coupon_usage(user_id);
CREATE INDEX idx_reviews_product_id ON public.reviews(product_id);
CREATE INDEX idx_notifications_user_is_read ON public.notifications(user_id, is_read);
CREATE INDEX idx_audit_logs_entity ON public.audit_logs(entity_name, entity_id);

-- GIN Full Text Search index for products
CREATE INDEX idx_products_fts ON public.products USING gin(to_tsvector('english', name || ' ' || coalesce(description, '')));
```

---

## 3. API Documentation

All API queries follow REST structures served via Supabase PostgREST or Supabase Edge Functions. All payload formats map snake_case database rows to camelCase fields in API responses.

### Authentication

#### `POST /auth/register`
*   **Description:** Creates a new customer account, issues a JWT, and initializes a Profile, Cart, and Wishlist.
*   **Authentication Required:** No
*   **Authorization Role:** Anonymous
*   **Request Headers:**
    *   `Content-Type: application/json`
*   **Request JSON:**
    ```json
    {
      "email": "customer@example.com",
      "password": "SecurePassword123"
    }
    ```
*   **Validation Rules:**
    *   `email`: Required, valid email format.
    *   `password`: Required, string length >= 8 characters.
*   **Success Response (201 Created):**
    ```json
    {
      "accessToken": "eyJhbGciOi...",
      "refreshToken": "r4_token...",
      "user": {
        "id": "e98e4d29-1a74-4b53-9118-ff2775f0a442",
        "email": "customer@example.com",
        "createdAt": "2026-07-08T20:32:00Z"
      }
    }
    ```
*   **Error Responses:**
    *   `400 Bad Request` (Validation errors, passwords do not match).
    *   `409 Conflict` (Email already exists).
*   **Database Changes:** Inserts rows into `auth.users`, triggers automatic insertion into `public.users`, `public.profiles`, `public.cart`, and `public.wishlist`.
*   **Emails Triggered:** Verification email (if enabled in GoTrue parameters).
*   **Realtime Events:** None.
*   **Cache Invalidations:** None.

---

#### `POST /auth/login`
*   **Description:** Signs in a user and returns access/refresh tokens. Merges the local guest cart into the account cart.
*   **Authentication Required:** No
*   **Request JSON:**
    ```json
    {
      "email": "customer@example.com",
      "password": "SecurePassword123"
    }
    ```
*   **Success Response (200 OK):**
    ```json
    {
      "accessToken": "eyJhbGciOi...",
      "refreshToken": "r4_token...",
      "user": {
        "id": "e98e4d29-1a74-4b53-9118-ff2775f0a442",
        "email": "customer@example.com"
      }
    }
    ```
*   **Error Responses:**
    *   `400 Bad Request` (Missing email/password).
    *   `401 Unauthorized` (Incorrect email or password).
*   **Database Changes:** Creates session rows in `public.sessions` (or internal auth.sessions) and updates last login context. Integrates guest cart items via trigger.
*   **Emails Triggered:** None.
*   **Realtime Events:** None.
*   **Cache Invalidations:** None.

---

#### `POST /auth/logout`
*   **Description:** Invalidates the current user session and refresh token.
*   **Authentication Required:** Yes
*   **Request Headers:**
    *   `Authorization: Bearer <access_token>`
*   **Request JSON:** None.
*   **Success Response (204 No Content):** Empty.
*   **Error Responses:**
    *   `401 Unauthorized` (Invalid bearer token).
*   **Database Changes:** Deletes the active row from `public.sessions` and revokes internal refresh token in `auth.refresh_tokens`.
*   **Emails Triggered:** None.
*   **Realtime Events:** None.
*   **Cache Invalidations:** None.

---

#### `POST /auth/refresh`
*   **Description:** Rotates and issues a new active JWT using a valid refresh token.
*   **Authentication Required:** No (Token passed in body)
*   **Request JSON:**
    ```json
    {
      "refreshToken": "r4_token..."
    }
    ```
*   **Success Response (200 OK):**
    ```json
    {
      "accessToken": "new_eyJhbGciOi...",
      "refreshToken": "new_r4_token..."
    }
    ```
*   **Error Responses:**
    *   `400 Bad Request` (Missing refresh token parameter).
    *   `401 Unauthorized` (Refresh token expired or revoked).
*   **Database Changes:** Updates expiration timestamps on active session rows.
*   **Emails Triggered:** None.
*   **Realtime Events:** None.
*   **Cache Invalidations:** None.

---

### Products

#### `GET /products`
*   **Description:** Retrieves a paginated list of products, optionally filtered by category name and sorted by price.
*   **Authentication Required:** No
*   **Request Headers:** None.
*   **Query Parameters:**
    *   `categoryId` (UUID) - Filter by category.
    *   `search` (String) - Search queries matching product title.
    *   `minPrice`, `maxPrice` (Decimal) - Range boundaries.
    *   `sortBy` (enum: `priceAsc`, `priceDesc`, `newest`) - Sort options.
    *   `page` (Integer, default `1`)
    *   `limit` (Integer, default `20`)
*   **Success Response (200 OK):**
    ```json
    {
      "products": [
        {
          "id": "2b3c4d5e-6f7g-8h9i-0j1k-2l3m4n5o6p7q",
          "name": "Organic Alphonso Mangoes",
          "slug": "organic-alphonso-mangoes",
          "description": "Sweet, fresh mangoes from trusted local farms in Gujarat.",
          "price": 450.00,
          "category": {
            "id": "e1f2g3h4-i5j6-k7l8-m9n0-o1p2q3r4s5t6",
            "name": "Fresh Fruits"
          },
          "images": [
            {
              "url": "https://<SUPABASE_URL>/storage/v1/object/public/products/mangoes.jpg",
              "displayOrder": 0
            }
          ],
          "variants": [
            {
              "id": "c1d2e3f4-5678-90ab-cdef-1234567890ab",
              "name": "1kg Pack",
              "sku": "OB-FRT-MGO-1KG",
              "priceOverride": null,
              "stockQuantity": 25
            }
          ]
        }
      ],
      "totalPages": 5,
      "currentPage": 1
    }
    ```
*   **Error Responses:**
    *   `400 Bad Request` (Invalid query parameter formats).
*   **Database Changes:** Read-only operation.
*   **Emails Triggered:** None.
*   **Realtime Events:** None.
*   **Cache Invalidations:** None.

---

#### `GET /products/{id}`
*   **Description:** Retrieves a single product detail with its images, variants, current stock, and reviews.
*   **Authentication Required:** No
*   **Success Response (200 OK):**
    ```json
    {
      "id": "2b3c4d5e-6f7g-8h9i-0j1k-2l3m4n5o6p7q",
      "name": "Organic Alphonso Mangoes",
      "slug": "organic-alphonso-mangoes",
      "description": "Sweet, fresh mangoes from trusted local farms in Gujarat.",
      "price": 450.00,
      "images": [
        {
          "url": "https://<SUPABASE_URL>/storage/v1/object/public/products/mangoes.jpg",
          "displayOrder": 0
        }
      ],
      "variants": [
        {
          "id": "c1d2e3f4-5678-90ab-cdef-1234567890ab",
          "name": "1kg Pack",
          "sku": "OB-FRT-MGO-1KG",
          "priceOverride": null,
          "stockQuantity": 25
        }
      ],
      "averageRating": 4.8,
      "reviewsCount": 12
    }
    ```
*   **Error Responses:**
    *   `404 Not Found` (Product does not exist or is inactive).

---

#### `POST /products`
*   **Description:** Creates a new product catalog item, along with its variant and inventory properties.
*   **Authentication Required:** Yes
*   **Authorization Role:** Admin (`public.admin_users`)
*   **Request JSON:**
    ```json
    {
      "categoryId": "e1f2g3h4-i5j6-k7l8-m9n0-o1p2q3r4s5t6",
      "name": "Green Apples",
      "slug": "green-apples",
      "description": "Crisp green apples.",
      "price": 180.00,
      "images": [
        "https://<SUPABASE_URL>/storage/v1/object/public/products/apples.jpg"
      ],
      "variants": [
        {
          "name": "500g Pack",
          "sku": "OB-FRT-APL-500G",
          "stockQuantity": 50,
          "lowStockThreshold": 5
        }
      ]
    }
    ```
*   **Success Response (201 Created):**
    ```json
    {
      "id": "9a8b7c6d-5e4f-3a2b-1c0d-9e8f7a6b5c4d",
      "name": "Green Apples",
      "createdAt": "2026-07-08T20:32:00Z"
    }
    ```
*   **Error Responses:**
    *   `400 Bad Request` (Invalid input, duplicate SKU).
    *   `403 Forbidden` (User is not an authorized administrator).
*   **Database Changes:** Inserts records into `public.products`, `public.product_images`, `public.product_variants`, `public.inventory`, and appends an action row to `public.audit_logs`.
*   **Cache Invalidations:** Invalidates product caches, category lists, and search queries.

---

#### `PATCH /products/{id}`
*   **Description:** Updates core fields of an existing product (e.g., price, description, status).
*   **Authentication Required:** Yes
*   **Authorization Role:** Admin
*   **Request JSON:**
    ```json
    {
      "price": 195.00,
      "description": "Updated description for apples."
    }
    ```
*   **Success Response (200 OK):** Returns the updated product object.
*   **Database Changes:** Updates product row and adds audit log.
*   **Cache Invalidations:** Invalidates target product cache.

---

#### `DELETE /products/{id}`
*   **Description:** Deactivates a product (`is_active = false`) to preserve historical order references (soft delete).
*   **Authentication Required:** Yes
*   **Authorization Role:** Admin
*   **Success Response (200 OK):**
    ```json
    {
      "id": "9a8b7c6d-5e4f-3a2b-1c0d-9e8f7a6b5c4d",
      "isActive": false,
      "message": "Product successfully deactivated."
    }
    ```
*   **Database Changes:** Updates `is_active` to `false` in `public.products`.
*   **Cache Invalidations:** Invalidates active lists.

---

### Categories (Complete CRUD)

*   `GET /categories` - Public access. Returns a list of active categories.
*   `GET /categories/{id}` - Public access. Returns details of a specific category.
*   `POST /categories` - Admin only. Creates a category. Request body includes `name`, `slug`, `description`, `imageUrl`.
*   `PATCH /categories/{id}` - Admin only. Modifies category fields.
*   `DELETE /categories/{id}` - Admin only. Soft-deactivates the category (`is_active = false`).

---

### Cart (Complete CRUD)

#### `GET /cart`
*   **Description:** Retrieves the logged-in customer's active cart and item list.
*   **Authentication Required:** Yes
*   **Authorization Role:** Customer (`authenticated`)
*   **Success Response (200 OK):**
    ```json
    {
      "cartId": "4c5d6e7f-8a9b-0c1d-2e3f-4a5b6c7d8e9f",
      "items": [
        {
          "cartItemId": "11223344-5566-7788-9900-aabbccddeeff",
          "variantId": "c1d2e3f4-5678-90ab-cdef-1234567890ab",
          "productName": "Organic Alphonso Mangoes",
          "variantName": "1kg Pack",
          "price": 450.00,
          "quantity": 2,
          "stockQuantity": 25
        }
      ]
    }
    ```

---

#### `POST /cart/items`
*   **Description:** Adds a product variant to the user's cart.
*   **Authentication Required:** Yes
*   **Request JSON:**
    ```json
    {
      "productVariantId": "c1d2e3f4-5678-90ab-cdef-1234567890ab",
      "quantity": 2
    }
    ```
*   **Validation Rules:**
    *   `quantity` > 0 and cannot exceed the available variant stock.
*   **Success Response (201 Created):** Returns the newly created `cart_item` details.
*   **Error Responses:**
    *   `400 Bad Request` (Quantity exceeds available inventory).

---

#### `PATCH /cart/items/{id}`
*   **Description:** Updates the quantity of a cart line item.
*   **Authentication Required:** Yes
*   **Request JSON:**
    ```json
    {
      "quantity": 5
    }
    ```
*   **Success Response (200 OK):** Returns the updated cart item.

---

#### `DELETE /cart/items/{id}`
*   **Description:** Removes a product variant from the cart.
*   **Authentication Required:** Yes
*   **Success Response (204 No Content):** Empty.

---

### Wishlist (Complete CRUD)

*   `GET /wishlist` - Customer only. Lists all products saved in the user's wishlist.
*   `POST /wishlist/items` - Customer only. Adds a product to the wishlist. Request body: `{ "productId": "UUID" }`.
*   `DELETE /wishlist/items/{id}` - Customer only. Removes an item from the wishlist.

---

### Addresses (Complete CRUD)

*   `GET /addresses` - Customer only. Lists all saved delivery addresses.
*   `GET /addresses/{id}` - Customer only. Retrieves details of a specific address.
*   `POST /addresses` - Customer only. Creates a saved address. Sets `is_default` handling logic (un-marks other user addresses if current is marked default). City is forced to `'Ahmedabad'`.
*   `PATCH /addresses/{id}` - Customer only. Modifies address properties.
*   `DELETE /addresses/{id}` - Customer only. Deletes a saved address.

---

### Orders (Complete CRUD)

#### `GET /orders`
*   **Description:** Lists the authenticated customer's order history (or lists all orders if requested by an Admin).
*   **Authentication Required:** Yes
*   **Success Response (200 OK):**
    ```json
    {
      "orders": [
        {
          "id": "7f8g9h0i-j1k2-l3m4-n5o6-p7q8r9s0t1u2",
          "status": "pending",
          "total": 900.00,
          "paymentMethod": "stripe",
          "createdAt": "2026-07-08T20:32:00Z"
        }
      ]
    }
    ```

---

#### `GET /orders/{id}`
*   **Description:** Returns full details of a specific order including items, delivery address, and payment transaction logs.
*   **Authentication Required:** Yes
*   **Success Response (200 OK):** Returns the full order model including address and unit items.
*   **Error Responses:**
    *   `403 Forbidden` (Customer attempts to read an order belonging to another user).

---

#### `POST /orders`
*   **Description:** Creates an order shell (primarily used for initiating payment checkout).
*   **Authentication Required:** Yes
*   **Request JSON:**
    ```json
    {
      "addressId": "8b8c8d8e-8f8g-8h8i-8j8k-8l8m8n8o8p8q",
      "paymentMethod": "cod",
      "couponCode": "AHMEDABAD10"
    }
    ```
*   **Success Response (201 Created):** Returns order object.

---

#### `PATCH /orders/{id}`
*   **Description:** Updates order status or cancels it.
*   **Authentication Required:** Yes
*   **Request JSON:**
    ```json
    {
      "status": "cancelled"
    }
    ```
*   **Validation Rules:**
    *   Customers can only transition status to `cancelled` and only if the current status is `pending` or `confirmed`.
    *   Admins can transition status to `confirmed`, `shipped`, `delivered`, or `cancelled`.
*   **Database Changes:** Updates `public.orders` status. If transitioning to `cancelled`, restores inventory levels:
    ```sql
    UPDATE public.inventory
    SET quantity = quantity + order_items.quantity
    FROM public.order_items
    WHERE order_items.order_id = NEW.id
      AND inventory.product_variant_id = order_items.product_variant_id;
    ```
*   **Emails Triggered:** Status update or cancellation email.
*   **Realtime Events:** Realtime broadcast to `orders` channel.

---

#### `DELETE /orders/{id}`
*   **Description:** Hard-deletion of order. Disabled by default in the system (returns `405 Method Not Allowed`).

---

### Coupons

#### `POST /coupons/validate`
*   **Description:** Validates a promo coupon against the active cart and returns the calculated discount.
*   **Authentication Required:** Yes
*   **Request JSON:**
    ```json
    {
      "code": "AHMEDABAD10",
      "cartSubtotal": 500.00
    }
    ```
*   **Success Response (200 OK):**
    ```json
    {
      "isValid": true,
      "discountAmount": 50.00,
      "discountType": "percentage",
      "value": 10.00
    }
    ```
*   **Error Responses:**
    *   `400 Bad Request` (Invalid or expired coupon, subtotal below minimum limit, usage limit reached).

---

### Checkout

#### `POST /checkout/stripe-intent`
*   **Description:** Server-side calculation of cart total, creation of an order record with status `pending`, and generation of a Stripe PaymentIntent client secret.
*   **Authentication Required:** Yes
*   **Request JSON:**
    ```json
    {
      "addressId": "8b8c8d8e-8f8g-8h8i-8j8k-8l8m8n8o8p8q",
      "couponCode": "AHMEDABAD10"
    }
    ```
*   **Success Response (200 OK):**
    ```json
    {
      "orderId": "7f8g9h0i-j1k2-l3m4-n5o6-p7q8r9s0t1u2",
      "clientSecret": "pi_123456_secret_654321",
      "publishableKey": "pk_test_51TIAZdCDK3A5M5w3Aqv4D6W5GMGUyqpyhLpj10qovTBWA0s6UBB5XvcZ06Dy3Q6IXMdTOrhsZA1e55sQU2CXr0cz0019nAY68X",
      "totalAmount": 450.00
    }
    ```

---

#### `POST /checkout/cod`
*   **Description:** Places a Cash on Delivery (COD) order, checks stock levels, decrements inventory, and empties the customer's cart.
*   **Authentication Required:** Yes
*   **Request JSON:** Same as Stripe intent.
*   **Success Response (201 Created):** Returns order object.

---

### Reviews (Complete CRUD)

*   `GET /products/{productId}/reviews` - Public access. Lists ratings and comments.
*   `POST /reviews` - Customer only. Adds rating. Request: `{ "productId": "UUID", "rating": 5, "comment": "Excellent!" }`.
*   `PATCH /reviews/{id}` - Customer only. Modifies a rating.
*   `DELETE /reviews/{id}` - Customer or Admin. Deletes a review.

---

### Notifications

*   `GET /notifications` - Customer only. Lists recent in-app notifications.
*   `PATCH /notifications/{id}/read` - Customer only. Marks a notification as read.

---

### Admin Dashboard & Operations

*   `GET /admin/inventory` - Admin only. Returns low-stock items.
*   `PATCH /admin/inventory/{id}` - Admin only. Updates stock quantity.
*   `GET /admin/orders` - Admin only. Retrieves filtered list of orders.
*   `PATCH /admin/orders/{id}/status` - Admin only. Progresses order state.
*   `POST /admin/coupons` - Admin only. Creates a promo coupon.
*   `GET /admin/dashboard` - Admin only. Returns statistics: total sales, order count, top products, low-stock alerts.

---

## 4. Authentication & Authorization

Supabase Auth handles security token generation and verification. Row Level Security policies enforce permissions inside the database.

### Token Specifications

#### JWT Access Token Payload
Issued upon login or token refresh. Expires after **1 hour**.
```json
{
  "aud": "authenticated",
  "exp": 1783629120,
  "sub": "e98e4d29-1a74-4b53-9118-ff2775f0a442",
  "email": "customer@example.com",
  "app_metadata": {
    "provider": "email",
    "providers": ["email"]
  },
  "user_metadata": {
    "first_name": "Priya",
    "last_name": "Patel"
  },
  "role": "authenticated"
}
```

#### Refresh Token Payload
Long-lived token used to acquire new JWTs. Persists for **30 days** in secure local storage.

---

### Authorization & Row Level Security (RLS)

All database tables have Row Level Security enabled:
```sql
ALTER TABLE public.<table_name> ENABLE ROW LEVEL SECURITY;
```

#### Admin Helper Function
Admins are authorized by querying the `public.admin_users` table via a secure database function.
```sql
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.admin_users
    WHERE id = auth.uid() AND is_active = true
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

#### Table Policy Definitions

*   **public.products / public.product_images / public.product_variants / public.categories / public.inventory:**
    *   `SELECT` is visible to all users (both anonymous and authenticated).
    *   `INSERT`, `UPDATE`, `DELETE` are permitted only if `public.is_admin()` evaluates to `true`.
*   **public.profiles:**
    *   `SELECT` and `UPDATE` allowed only if `auth.uid() = id` or `public.is_admin()`.
*   **public.cart / public.wishlist:**
    *   `ALL` operations restricted to owner: `auth.uid() = user_id`.
*   **public.cart_items / public.wishlist_items:**
    *   `ALL` operations verified by checking owner of parent container:
        ```sql
        EXISTS (
          SELECT 1 FROM public.cart
          WHERE cart.id = cart_items.cart_id AND cart.user_id = auth.uid()
        )
        ```
*   **public.addresses:**
    *   `ALL` operations restricted to owner: `auth.uid() = user_id`.
*   **public.orders:**
    *   `SELECT` permitted if `auth.uid() = user_id` or `public.is_admin()`.
    *   `INSERT` allowed if `auth.uid() = user_id`.
    *   `UPDATE` permitted for customers only on status cancellation transitions. Full status progression updates restricted to `public.is_admin()`.
*   **public.order_items:**
    *   `SELECT` permitted if parent order belongs to the user or `public.is_admin()`.
*   **public.coupons:**
    *   `SELECT` readable by all authenticated users.
    *   `INSERT`, `UPDATE`, `DELETE` restricted to `public.is_admin()`.
*   **public.coupon_usage:**
    *   `SELECT` restricted to user or `public.is_admin()`.
*   **public.reviews:**
    *   `SELECT` readable by all users.
    *   `INSERT` and `UPDATE` permitted only if `auth.uid() = user_id`.
    *   `DELETE` permitted if `auth.uid() = user_id` or `public.is_admin()`.
*   **public.notifications:**
    *   `SELECT` and `UPDATE` (e.g. `is_read`) restricted to target owner: `auth.uid() = user_id`.
*   **public.admin_users / public.audit_logs:**
    *   `ALL` operations restricted to authorized staff: `public.is_admin()`.

---

## 5. Standard Error Format

All error responses returned from Edge Functions or PostgREST follow a unified JSON specification.

```json
{
  "status": 422,
  "code": "INSUFFICIENT_STOCK",
  "message": "The selected quantity of this item is no longer available in our inventory.",
  "errors": [
    {
      "field": "quantity",
      "reason": "Requested quantity (5) exceeds available stock (2)."
    }
  ],
  "timestamp": "2026-07-08T20:32:00.123Z",
  "requestId": "d82bd5e3-e847-4952-b883-fa4c49d21cbf"
}
```

### Internal Error Codes
*   `VALIDATION_FAILED`: Form field validation errors.
*   `UNAUTHORIZED`: Missing or invalid credentials.
*   `FORBIDDEN`: RLS policy failure or lack of admin permissions.
*   `NOT_FOUND`: Resource does not exist.
*   `INSUFFICIENT_STOCK`: Requested quantity exceeds inventory.
*   `COUPON_EXPIRED`: Coupon has expired.
*   `COUPON_LIMIT_REACHED`: Coupon usage cap has been met.
*   `PAYMENT_FAILED`: Stripe card charge failed.
*   `INTERNAL_ERROR`: General database or server-side failure.

---

## 6. Caching Strategy

Caching reduces database load and ensures product queries evaluate in under 2 seconds.

| Cache Target | Key Format | TTL (seconds) | Invalidation Rules |
| :--- | :--- | :--- | :--- |
| **Product Cache** | `prod:{id}` | 3600 (1 hour) | Invalidated when admin updates/deletes product details, or when inventory falls to 0. |
| **Category Cache** | `cat:list` | 86400 (24 hours) | Invalidated when admin adds, updates, or deactivates a category. |
| **Coupon Cache** | `promo:{code}` | 1800 (30 mins) | Invalidated when coupon usage limit is met, or when an admin updates the coupon. |
| **Search Cache** | `search:{query}` | 600 (10 mins) | Invalidated when any product description/name in search list changes. |

---

## 7. Rate Limiting

Rate limiting is enforced at the API gateway layer (Kong) and via Postgres triggers.

*   **Authentication API:**
    *   `POST /auth/register` and `/auth/login`: Maximum **5 requests per minute** per IP.
    *   `POST /auth/refresh`: Maximum **30 requests per minute** per IP.
*   **Search API:**
    *   `GET /products` search query params: Maximum **30 requests per minute** per IP.
*   **Checkout API:**
    *   `POST /checkout/stripe-intent` and `/checkout/cod`: Maximum **3 requests per minute** per user token.
*   **Reviews API:**
    *   `POST /reviews`: Maximum **5 requests per minute** per user token.
*   **Admin APIs:**
    *   Dashboard operations: Maximum **60 requests per minute** per admin user token.

---

## 8. Migration & Deployment Strategy

Supabase Schema migrations are managed locally via the Supabase CLI, tested in isolation, and deployed to production.

### Workflow & Commands

#### 1. Local Development Initialization
Developers run the local Supabase environment on Docker.
```bash
# Initialize Supabase configuration in directory
npx -y supabase init

# Start local Docker database environment
npx -y supabase start
```

#### 2. Schema Modification & Migration
All database schema changes must be declared in migration SQL files.
```bash
# Create a new versioned migration script
npx -y supabase migration new add_products_table
```
Developers edit the generated script inside the `supabase/migrations/` folder.

#### 3. Local Verification
Test migrations locally by applying updates:
```bash
# Apply migrations to local test database
npx -y supabase db reset
```

#### 4. Seeding Data
Seed initial data by creating `supabase/seed.sql` with default categories, test products, and admin user credentials. This script is applied automatically during database resets.

#### 5. Production Deployment
Migrations are applied to production during CI/CD checks:
```bash
# Verify local schema matches staging/production migration state
npx -y supabase db lint

# Link local repository to Supabase Cloud Project ID
npx -y supabase link --project-ref hfnyfhmdlmsjthyywksj

# Apply outstanding migration files to remote production database
npx -y supabase db push
```

### Rollback Strategy
If a database migration fails in production:
1.  Locate the corresponding reverse script (manually created by developers alongside migration files).
2.  Run the rollback DDL queries via the Supabase SQL Editor.
3.  Re-synchronize the database migration state metadata using `supabase db remote commit` to log the correct current configuration.