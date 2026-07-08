# Product Requirements Document: Local Ahmedabad Ecommerce Platform

**Document Version:** 1.0
**Date:** July 8, 2026
**Status:** Draft for Review

---

## Context

- **Target Users:** Existing offline-store customers and new online shoppers located in Ahmedabad, Gujarat, who want to browse, purchase, and track products from a locally trusted retailer.
- **Main Problem:** The business currently operates offline only. Customers cannot browse the catalog, check stock, or purchase outside store hours, and have no way to track an order after it's placed.
- **Unique Value:** A hyperlocal (Ahmedabad-only) ecommerce experience backed by an existing, trusted offline business — offering faster local delivery and verified product quality (owned inventory, not third-party marketplace sellers) versus national platforms like Amazon or Flipkart.

---

## 1. Problem Statement

The business's customers currently have no digital channel to interact with the store. Specific pain points:

- Customers can only shop during physical store hours and must travel to the store location.
- Customers cannot verify product availability/stock before visiting, leading to wasted trips.
- There is no self-service way to view order history, track delivery status, or cancel/return an order — all such actions require a phone call or in-person visit.
- The business has no digital record of customer preferences, purchase history, or repeat-customer behavior, limiting its ability to re-engage customers.
- As an offline-only operation, the business cannot reach customers outside people who can physically visit the store, capping growth within Ahmedabad.

---

## 2. Goals & Objectives

| # | Goal | Target | Timeframe |
|---|------|--------|-----------|
| G1 | Launch a functional customer-facing ecommerce app (mobile + web) and an admin web portal | Both apps live in production, handling real orders | Within 4 months of dev start |
| G2 | Migrate a meaningful share of existing offline customers to the app | 200 registered customer accounts | Within 2 months of launch |
| G3 | Achieve reliable order fulfillment | ≥95% of orders reach "delivered" status without cancellation due to stock/system errors | Ongoing, measured monthly post-launch |
| G4 | Keep checkout friction low | ≥70% cart-to-order completion rate (of carts that reach the checkout screen) | Within 3 months of launch |
| G5 | Ensure admin can manage the store efficiently | Admin can add a new product (with variants and images) in under 3 minutes | At launch |

---

## 3. Success Metrics

1. **Monthly Active Customers (MAC):** Number of unique customers who log in and browse at least one product per month.
2. **Order Conversion Rate:** (Orders placed) / (Unique product-detail-page visits) — target ≥5% within first 3 months.
3. **Cart Abandonment Rate:** (Carts created) − (Carts converted to orders) / (Carts created) — target below 60%.
4. **Average Order Fulfillment Time:** Time from "order placed" to "delivered" status — target under 48 hours within Ahmedabad.
5. **App Crash-Free Session Rate:** ≥99% across both customer and admin apps, tracked post-launch.

---

## 4. Target Personas

### Persona 1: Priya, the Returning Local Shopper

- **Demographics:** 29 years old, works in Ahmedabad, has shopped at the physical store before, owns a mid-range Android phone.
- **Tech Proficiency:** Comfortable with apps like WhatsApp, Instagram, Swiggy/Zomato, and occasionally Amazon/Flipkart. Not a power user — expects things to "just work" without a learning curve.
- **Pain Points:** Can't check if an item is in stock before traveling to the store; no way to track a delivery once she's ordered by phone/WhatsApp in the past; doesn't want to create a complicated account or remember many steps to buy.
- **Goals:** Wants to quickly search for a known product, check price/availability, buy with minimal steps, and track delivery — ideally within the same day for local delivery.

### Persona 2: Raj, the Store Admin/Owner

- **Demographics:** 42 years old, owns/runs the offline store, manages inventory and pricing personally, uses a laptop for business tasks.
- **Tech Proficiency:** Moderate — comfortable with spreadsheets, WhatsApp Business, and basic web tools, but not a developer. Needs a simple, visual admin interface, not a technical dashboard.
- **Pain Points:** Currently tracks inventory and orders manually (notebook/Excel/WhatsApp messages), which is error-prone and doesn't scale; has no visibility into which products are best-sellers or low in stock until it's too late.
- **Goals:** Wants a simple screen to add/edit products, see incoming orders in real time, update order status, and get low-stock warnings — without needing technical training.

---

## 5. Features

### P0 — MVP Must-Haves

#### F1. Customer Registration & Login
- **Description:** Email/password registration and login for customers. No OTP or forgot-password recovery flow; users can change their password only while logged in.
- **User Story:** As a new customer, I want to register with my email and password so that I can save my information and place orders.
- **Acceptance Criteria:**
  1. User can register with email, password, and confirm-password fields; password must be ≥8 characters.
  2. Duplicate email registration is blocked with a clear error message.
  3. User can log in with correct credentials and is denied with incorrect ones, showing a clear error.
  4. Logged-in user can change their password from a settings screen by entering a new password.
  5. Session persists across app restarts until the user explicitly logs out.
- **Success Metric:** ≥90% of registration attempts complete successfully without error.

#### F2. Product Catalog Browsing
- **Description:** Customers can view a categorized, paginated product listing and a detailed product page per item.
- **User Story:** As a customer, I want to browse products by category so that I can find items I'm interested in.
- **Acceptance Criteria:**
  1. Product listing displays image, name, price, and stock status (in stock/out of stock) for each item.
  2. Products are grouped under at least one category, visible via a category navigation menu.
  3. Product detail page shows all variant options (size/color/weight), price, description, images, and stock per variant.
  4. Out-of-stock variants are visibly disabled and cannot be added to cart.
  5. Listing loads the first page of results in under 2 seconds on a standard 4G connection.
- **Success Metric:** ≥80% of sessions include at least one product-detail-page view.

#### F3. Search
- **Description:** A search bar allowing customers to find products by name/keyword.
- **User Story:** As a customer, I want to search for a product by name so that I don't have to browse through categories.
- **Acceptance Criteria:**
  1. Search returns results matching product name or description text.
  2. Empty search results show a clear "no products found" state, not a blank screen.
  3. Search results respect the same stock/variant display rules as the main listing.
  4. Search responds within 1.5 seconds for catalogs up to 5,000 products.
- **Success Metric:** ≥30% of sessions use the search bar at least once.

#### F4. Filters & Sorting
- **Description:** Customers can filter product listings by price range and category, and sort by price or newest.
- **User Story:** As a customer, I want to filter products by price so that I only see items within my budget.
- **Acceptance Criteria:**
  1. Price range filter (min/max) updates the listing without a full page reload.
  2. Category filter can be combined with price filter simultaneously.
  3. Sort options include: price low-to-high, price high-to-low, newest first.
  4. Selected filters/sort persist while navigating back from a product detail page.
- **Success Metric:** ≥25% of browsing sessions use at least one filter or sort option.

#### F5. Cart Management
- **Description:** Customers can add products (with selected variant) to a cart, adjust quantity, and remove items. Cart persists locally and syncs to the account on login.
- **User Story:** As a customer, I want to add items to my cart and see them saved so that I can review before checkout.
- **Acceptance Criteria:**
  1. Adding a product with a selected variant creates a cart line item with correct price and quantity.
  2. Quantity cannot exceed available stock for that variant.
  3. Cart persists across app restarts for logged-out (local) and logged-in (synced) users.
  4. On login, a local guest cart merges with the account's saved cart without data loss.
  5. Removing an item updates the cart total immediately.
- **Success Metric:** Cart abandonment rate below 60% (see Success Metrics).

#### F6. Wishlist
- **Description:** Customers can save products to a wishlist for later purchase.
- **User Story:** As a customer, I want to save a product to my wishlist so that I can find it again later without searching.
- **Acceptance Criteria:**
  1. Wishlist icon on product card/detail page toggles save/unsave state.
  2. Wishlist screen lists all saved products with current price and stock status.
  3. Wishlist items can be moved directly to cart from the wishlist screen.
  4. Wishlist persists across sessions for logged-in users.
- **Success Metric:** ≥20% of registered customers use the wishlist within their first month.

#### F7. Saved Addresses
- **Description:** Customers can save multiple delivery addresses and select one at checkout.
- **User Story:** As a customer, I want to save my home and work addresses so that I can choose one quickly at checkout.
- **Acceptance Criteria:**
  1. Customer can add, edit, and delete addresses (name, phone, address lines, city, pincode).
  2. At least one address can be marked as default.
  3. Checkout screen defaults to the primary address but allows switching to any saved address.
  4. Address form validates required fields before saving.
- **Success Metric:** ≥95% of orders have a valid, complete address at time of placement.

#### F8. Checkout & Payment
- **Description:** A checkout flow collecting address, payment method, and optional coupon, supporting Stripe (test mode) and Cash on Delivery.
- **User Story:** As a customer, I want to complete checkout by selecting my address and payment method so that I can place my order.
- **Acceptance Criteria:**
  1. Checkout displays order summary (items, quantities, subtotal, shipping, total) before confirmation.
  2. Customer can choose between Stripe (card, test mode) and Cash on Delivery.
  3. Stripe payment failures show a clear error and do not create an order until payment succeeds.
  4. Coupon code field validates the code and applies discount to the order total before final confirmation.
  5. Successful checkout creates an order record and clears the cart.
- **Success Metric:** ≥70% cart-to-order completion rate.

#### F9. Coupons
- **Description:** Admin-created discount codes customers can apply at checkout.
- **User Story:** As a customer, I want to apply a coupon code so that I get a discount on my order.
- **Acceptance Criteria:**
  1. Valid, active coupon codes reduce the order total by the configured amount/percentage.
  2. Expired or invalid codes show a clear error and do not apply a discount.
  3. Coupon usage limits (if configured) are enforced — code cannot be reused beyond its limit.
  4. Applied coupon is visible in the order summary before and after order placement.
- **Success Metric:** Coupon-code error rate (invalid attempts) tracked; used to refine UX if above 20%.

#### F10. Order Placement, Status & Cancellation
- **Description:** Customers can view order history, see order status (pending → confirmed → shipped → delivered), and cancel while status is still pending/confirmed.
- **User Story:** As a customer, I want to track my order status so that I know when to expect delivery.
- **Acceptance Criteria:**
  1. Order history screen lists all past orders with date, items, total, and current status.
  2. Order detail screen shows a status timeline reflecting the current stage.
  3. "Cancel Order" button is available only while status is "pending" or "confirmed" and disappears once "shipped."
  4. Cancelling an order restores stock quantities for the cancelled items.
  5. Order status updates made by admin reflect in the customer app within 5 seconds (via Supabase Realtime).
- **Success Metric:** ≥95% of orders reach "delivered" without system-caused cancellation (Goal G3).

#### F11. Order Notifications
- **Description:** Customers receive in-app and email notifications when order status changes.
- **User Story:** As a customer, I want to be notified when my order ships so that I know it's on its way.
- **Acceptance Criteria:**
  1. Email notification is sent on order placement, shipment, and delivery.
  2. In-app notification/badge reflects unread status changes.
  3. Notification content includes order ID and new status.
  4. Failed email delivery does not block the order status update itself.
- **Success Metric:** ≥98% successful email delivery rate for status-change notifications.

#### F12. Product Reviews
- **Description:** Customers who can leave a star rating and text review on a product page.
- **User Story:** As a customer, I want to read and leave reviews so that I can make informed purchase decisions.
- **Acceptance Criteria:**
  1. Customer can submit a 1–5 star rating with optional text review per product.
  2. Product detail page displays average rating and list of reviews.
  3. A customer can edit or delete their own review.
  4. Reviews display reviewer name and date submitted.
- **Success Metric:** ≥10% of delivered orders result in a submitted review within 30 days.

#### F13. Admin: Product & Inventory Management
- **Description:** Admin web portal for creating/editing products, variants, images, categories, and stock levels.
- **User Story:** As the store admin, I want to add and edit products with variants and stock so that the catalog stays accurate.
- **Acceptance Criteria:**
  1. Admin can create a product with name, description, category, price, images, and one or more variants (size/color/weight) each with its own stock count.
  2. Admin can edit price, description, and stock for existing products.
  3. Stock automatically decrements when an order is placed and restores on cancellation.
  4. Admin sees a low-stock indicator when a variant's stock falls below a configurable threshold.
  5. Deleting/deactivating a product removes it from customer-facing listings without deleting historical order records.
- **Success Metric:** Admin can create a fully configured product (with variants, images, stock) in under 3 minutes (Goal G5).

#### F14. Admin: Order Management
- **Description:** Admin can view incoming orders, update order status, and process cancellations initiated by customers or the store.
- **User Story:** As the store admin, I want to see new orders and update their status so that customers know their delivery progress.
- **Acceptance Criteria:**
  1. Admin dashboard lists orders sorted by newest first, with filter by status.
  2. Admin can update status through the defined sequence (pending → confirmed → shipped → delivered), and this update reaches the customer app via Realtime within 5 seconds.
  3. Admin can view full order details: items, variants, customer info, address, payment method.
  4. Admin can mark an order as cancelled/refund-pending for COD or failed-delivery cases.
- **Success Metric:** Average admin response time (order placed → status moved to "confirmed") under 2 hours during business hours.

#### F15. Admin: Coupon Management
- **Description:** Admin can create, edit, and deactivate discount coupons.
- **User Story:** As the store admin, I want to create discount coupons so that I can run promotions.
- **Acceptance Criteria:**
  1. Admin can create a coupon with code, discount type (flat/percentage), value, expiry date, and usage limit.
  2. Admin can deactivate a coupon before its expiry date.
  3. Admin can view usage count per coupon.
- **Success Metric:** N/A (operational tool); tracked via coupon usage in F9 metric.

---

### P1 — Important (Post-MVP, near-term)

#### F16. Return / Exchange Requests
- **Description:** Customers can request a return or exchange for delivered orders within a configurable window (e.g., 7 days).
- **User Story:** As a customer, I want to request a return so that I can get a refund or replacement for an unwanted item.
- **Acceptance Criteria:**
  1. "Request Return" option appears on delivered orders within the return window.
  2. Customer selects reason and submits request; admin receives it in a dedicated queue.
  3. Admin can approve/reject the request and update status (return pending → picked up → refunded).
  4. Return window closes automatically after the configured number of days.
- **Success Metric:** Return-request-to-resolution time under 5 business days.

#### F17. Recently Viewed Products
- **Description:** A section showing products the customer recently viewed.
- **User Story:** As a customer, I want to see my recently viewed products so I can quickly return to them.
- **Acceptance Criteria:**
  1. Last 10 viewed products are tracked per session/account.
  2. Section displays on home screen or product detail page.
  3. List updates in real time as the customer browses.
- **Success Metric:** ≥15% click-through rate on recently-viewed items.

#### F18. Featured / Best-Seller Products
- **Description:** Admin-curated or sales-based highlighting of featured products on the home screen.
- **User Story:** As a customer, I want to see featured products so I can discover popular items quickly.
- **Acceptance Criteria:**
  1. Admin can manually flag a product as "featured."
  2. Home screen displays a featured-products carousel/section.
  3. Featured flag can be toggled on/off per product at any time.
- **Success Metric:** Featured-product click-through rate ≥2x the average product's click-through rate.

#### F19. Push Notifications
- **Description:** Mobile push notifications supplementing existing email/in-app notifications.
- **User Story:** As a customer, I want a push notification when my order ships so I don't have to open the app to check.
- **Acceptance Criteria:**
  1. Customer can opt in/out of push notifications from settings.
  2. Push notification is sent on order status change events matching F11.
  3. Tapping the notification deep-links to the relevant order detail screen.
- **Success Metric:** ≥40% push notification opt-in rate among mobile users.

#### F20. Multi-Admin Roles & Permissions
- **Description:** Support for additional admin/staff accounts with restricted permissions (e.g., order-only access).
- **User Story:** As the store owner, I want to give staff limited access so they can process orders without editing prices.
- **Acceptance Criteria:**
  1. Owner can invite a staff account and assign a role (e.g., "order manager," "full admin").
  2. Role restrictions are enforced at the database level (RLS), not just hidden in UI.
  3. Owner can revoke staff access at any time.
- **Success Metric:** N/A (operational/security feature).

---

### P2 — Nice-to-Have (Future / Backlog)

#### F21. Advanced Filters (Brand, Rating, Multiple Attributes)
- **Description:** Extend filtering beyond price/category to brand, rating, and combined attribute filters.
- **User Story:** As a customer, I want to filter by brand and rating so I can narrow results further.
- **Acceptance Criteria:** Filter UI supports multi-select brand and minimum-rating filters; combinable with existing filters; results update without full reload.
- **Success Metric:** Increase in filter-usage rate beyond the P0 baseline.

#### F22. Loyalty / Repeat-Customer Rewards
- **Description:** Points or discounts for repeat purchases.
- **User Story:** As a returning customer, I want to earn rewards for shopping again so I feel valued.
- **Acceptance Criteria:** Points accrue per order; redeemable as a discount at checkout; visible in customer profile.
- **Success Metric:** Repeat purchase rate increase, measured quarter-over-quarter.

#### F23. Live Order Tracking (Map-based)
- **Description:** Real-time delivery partner location shown on a map during "shipped" status.
- **User Story:** As a customer, I want to see my delivery on a map so I know exactly when it will arrive.
- **Acceptance Criteria:** Requires delivery-partner API integration; live location updates on order-tracking screen during transit.
- **Success Metric:** Reduction in "where is my order" support queries.

#### F24. Customer Support Chat
- **Description:** In-app chat or ticketing system for customer support.
- **User Story:** As a customer, I want to chat with support so I can resolve issues without leaving the app.
- **Acceptance Criteria:** In-app chat thread per customer; admin can respond from admin portal; chat history persists.
- **Success Metric:** Average support response time under 4 hours.

#### F25. Analytics Dashboard for Admin
- **Description:** Sales trends, best-sellers, and customer behavior analytics for the admin.
- **User Story:** As the store owner, I want to see sales trends so I can make better inventory decisions.
- **Acceptance Criteria:** Dashboard shows revenue over time, top products, and low-stock alerts in one view.
- **Success Metric:** N/A (operational insight tool).

---

## 6. Explicitly OUT OF SCOPE (v1)

The following are **not** being built in this release, and should not be assumed by any stakeholder:

1. **Guest checkout** — all purchases require a registered account.
2. **OTP-based verification or "Forgot Password" recovery** — password reset is only possible while logged in; there is no email/SMS-based account recovery flow.
3. **Multi-vendor marketplace functionality** — this is a single-vendor store; no third-party seller onboarding, seller dashboards, or commission handling.
4. **Delivery outside Ahmedabad** — no support for other cities, states, or international shipping in v1.
5. **Live GPS delivery tracking** — order status will be a manually/admin-updated stage indicator only, not real-time courier location (see F23, P2).
6. **In-app customer support chat** — support is handled outside the app (phone/WhatsApp) in v1 (see F24, P2).
7. **Loyalty points or rewards program** — not included in v1 (see F22, P2).
8. **Native push notifications** — v1 uses in-app and email notifications only (see F19, P1).
9. **Multiple admin roles/permissions** — v1 assumes a single admin role with full access (see F20, P1).
10. **SEO-optimized server-rendered web pages** — the Flutter web build will not be optimized for search-engine indexing in v1; organic search discovery is not a v1 goal.

---

## 7. User Scenarios

### Scenario 1: First-Time Purchase (Happy Path)

**Actor:** Priya (new customer)

**Steps:**
1. Priya opens the customer app, taps "Register," enters email/password, and creates an account.
2. She browses the "Electronics" category, uses the search bar to find a specific product.
3. She opens the product detail page, selects a variant (e.g., color), and adds it to her cart.
4. She opens her cart, reviews items, and proceeds to checkout.
5. She adds a new delivery address and saves it as default.
6. She selects "Cash on Delivery" as the payment method and applies a coupon code.
7. She confirms the order; the app shows an order confirmation screen with an order ID.
8. She receives an email confirmation and sees the order appear in her order history with status "Pending."

**Outcome:** Order is created in the system with correct items, address, discount applied, and stock decremented. Admin sees the new order in their dashboard.

**Edge Cases:**
- Selected variant goes out of stock between add-to-cart and checkout → checkout screen must re-validate stock and block confirmation with a clear message.
- Invalid/expired coupon code entered → error shown, order total unaffected, customer can proceed without the coupon.
- App loses network connectivity mid-checkout → order is not created until confirmation succeeds; customer sees a retry option, and cart contents are preserved.

---

### Scenario 2: Admin Processes and Ships an Order

**Actor:** Raj (admin)

**Steps:**
1. Raj logs into the admin web portal and sees a new order in the "Pending" queue.
2. He opens the order detail to confirm items, address, and payment method (COD).
3. He verifies stock is available (already reserved at order time) and updates status to "Confirmed."
4. He hands the package to the third-party delivery partner and updates status to "Shipped."
5. The customer's app reflects "Shipped" status within seconds via Realtime, and the customer receives an email notification.
6. Once delivered, Raj (or the delivery partner's confirmation) updates status to "Delivered."

**Outcome:** Order moves through all statuses with the customer notified at each stage; stock and order records remain consistent.

**Edge Cases:**
- Admin accidentally selects the wrong status (e.g., skips "Confirmed" and jumps to "Delivered") → system should allow status correction but log the change for audit purposes.
- Delivery partner reports the package undeliverable → admin needs a way to mark the order as "Failed Delivery," which should trigger a customer notification and potential refund/reorder flow.
- Two admins update the same order simultaneously (if multi-admin exists later) → last-write-wins is acceptable for v1 given single-admin assumption, but the system should not corrupt order data.

---

### Scenario 3: Customer Cancels an Order Before Shipment

**Actor:** Priya (existing customer)

**Steps:**
1. Priya opens her order history and finds an order still in "Pending" status.
2. She opens the order detail screen and taps "Cancel Order."
3. She confirms the cancellation in a confirmation dialog.
4. The order status updates to "Cancelled," and the reserved stock for the cancelled items is restored to available inventory.
5. If payment was made via Stripe, a refund process is initiated (manual or automated, depending on Stripe test-mode configuration); if COD, no financial transaction is needed.
6. Priya receives a cancellation confirmation notification.

**Outcome:** Order is cancelled, stock is restored, admin sees the updated status, and no delivery is dispatched.

**Edge Cases:**
- Customer attempts to cancel after status has already changed to "Shipped" → "Cancel" option must not be available; UI should reflect this in real time even if the customer had the screen open before the status changed.
- Cancellation request sent while offline → action should queue and retry, or clearly fail with a message asking the customer to retry once online, rather than silently failing.
- Partial cancellation (cancelling one item in a multi-item order) — **out of scope for v1**; cancellation applies to the entire order only.

---

## 8. Non-Functional Requirements

### Performance
- Product listing pages must load within 2 seconds on a standard 4G connection for catalogs up to 5,000 products.
- Search queries must return results within 1.5 seconds.
- Order status updates made by admin must propagate to the customer app within 5 seconds via Supabase Realtime.
- The app must support at least 500 concurrent active users without degraded response times, based on expected Ahmedabad-scale traffic.

### Security
- All payment processing must occur through Stripe's hosted/tokenized flow; raw card data must never be stored in the application database.
- Row Level Security (RLS) must be enforced on all Supabase tables containing customer data (orders, addresses, cart, wishlist) so that customers can only access their own records.
- Admin-only actions (product edits, order status changes, coupon management) must be enforced via RLS role checks at the database level, not solely via client-side UI restrictions.
- Passwords must be stored using Supabase Auth's built-in hashing; plaintext passwords must never be logged or stored.
- All API/database traffic must occur over HTTPS/TLS.

### Accessibility
- Text and interactive elements must meet a minimum contrast ratio of 4.5:1 (WCAG AA) against their background.
- All interactive elements (buttons, cart icons, filters) must have a minimum touch target size of 48x48 dp on mobile.
- Forms must provide clear, visible error messages tied to the specific invalid field, not generic top-of-page errors.
- The app must remain usable via screen readers for core flows (browse, cart, checkout) — all interactive elements must have appropriate semantic labels.

### Reliability & Data Integrity
- Stock levels must never go negative; concurrent order attempts on the last unit of a variant must be resolved so only one order succeeds (database-level constraint, not just client-side check).
- Failed payment attempts must never result in an order being marked as "confirmed" or stock being decremented.
- The system must maintain an audit trail (timestamped status history) for every order, for dispute resolution and admin review.

### Compatibility
- Customer app must run responsively across mobile (Android/iOS) and web, adapting layout at defined breakpoints (mobile <600px, tablet 600–1024px, desktop >1024px).
- Admin web app must be usable on standard desktop browser widths (≥1024px), with tablet support as a secondary consideration.
- The app must function correctly on the two most recent major versions of Chrome, Safari, and Firefox for web, and reasonably current Android/iOS OS versions for mobile.

---

## Open Items for Stakeholder Input

The following require your decision before or during development and are flagged rather than assumed:

- Exact product category/domain (electronics, apparel, groceries, etc.) — affects variant schema and UI design details.
- Low-stock threshold value for admin alerts (F13).
- Return/exchange window length in days (F16).
- Delivery radius/zones within Ahmedabad and associated shipping cost logic.
- Whether Stripe will move from test mode to a live production account before launch, and associated compliance/KYC requirements.