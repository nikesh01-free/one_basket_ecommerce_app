# App Flow Documentation: OneBasket

**Document Version:** 1.0
**Date:** July 8, 2026
**Companion to:** PRD.md (Local Ahmedabad Ecommerce Platform)
**App Description:** OneBasket is a hyperlocal ecommerce platform for an existing offline retail store in Ahmedabad, Gujarat. It consists of a customer-facing app (Flutter, mobile + web) for browsing, purchasing, and tracking products, and an admin web portal for managing inventory, orders, and coupons. Payments support Stripe (test mode) and Cash on Delivery (COD); backend is Supabase (Auth, Database with RLS, Realtime).

---

## 1. Entry Points

| # | Entry Point | Platform | Description |
|---|---|---|---|
| E1 | App icon launch (cold start) | Mobile (Android/iOS) | User taps the OneBasket app icon from home screen. |
| E2 | Direct URL / bookmarked link | Web | User navigates to the web app root URL. |
| E3 | Deep link — product | Mobile + Web | Link shared via WhatsApp/social pointing to `/product/:id`. |
| E4 | Deep link — order detail | Mobile + Web | Link from an email notification pointing to `/orders/:id`. |
| E5 | Email notification link | Mobile + Web | Order confirmation/shipment/delivery emails contain a "View Order" link (see F11). |
| E6 | Session resume | Mobile + Web | App reopened while a valid session persists (see F1, AC5). |
| E7 | Admin portal URL | Web (desktop) | Raj navigates to `/admin` login page. |
| E8 | Push notification tap | Mobile (P1, F19 — not in v1 MVP) | Reserved for post-MVP; not active in this release. |

**IF-THEN — Entry Routing:**
- IF a valid session token exists on launch → THEN route directly to Home (skip Login/Register).
- IF no valid session exists and entry point is a deep link (E3/E4/E5) → THEN show the target content in "guest preview" mode where allowed (product pages only), and prompt login/registration when the user attempts a restricted action (add to cart, view order, checkout). Guest checkout is explicitly out of scope, so cart/order actions always require login.
- IF entry point is `/admin` (E7) → THEN route to the Admin Login screen, entirely separate from the customer auth flow.

---

## 2. Core User Flows

### 2.1 Onboarding / Registration (F1)

**Happy Path**

| Step | Screen → Element | User Action | System Response | Next Step |
|---|---|---|---|---|
| 1 | Landing → "Register" button | Taps "Register" | Navigates to Registration screen | Step 2 |
| 2 | Registration screen: Email field, Password field, Confirm Password field, "Create Account" button | Enters email, password (≥8 chars), confirm password | Client-side validation runs on blur/submit | Step 3 |
| 3 | Registration screen | Taps "Create Account" | System checks email uniqueness via Supabase Auth; creates account | Step 4 |
| 4 | Registration screen | — | Account created; session token issued | Redirect to Home (logged in) |

**Error States**

| Condition | System Response | Message Shown |
|---|---|---|
| Password < 8 characters | Field-level error, submit blocked | "Password must be at least 8 characters." |
| Password ≠ Confirm Password | Field-level error, submit blocked | "Passwords do not match." |
| Email already registered | Submit blocked, error tied to email field | "An account with this email already exists. Try logging in instead." |
| Invalid email format | Field-level error, submit blocked | "Enter a valid email address." |
| Network failure during submit | Non-blocking retry banner | "Couldn't connect. Check your internet and try again." |
| Server error (5xx) | Generic error banner, form data preserved | "Something went wrong on our end. Please try again." |

**Edge Cases**

- IF the user abandons registration mid-form (navigates away) → THEN form data is not persisted; returning to Registration starts blank (no auto-save, per v1 scope).
- IF the user double-taps "Create Account" → THEN the button is disabled after first tap until a response returns, preventing duplicate submission.
- IF the app is backgrounded during account creation and resumed → THEN the app re-checks auth state on resume; if account creation succeeded server-side, the user lands on Home; if it failed, they return to Registration with fields cleared.

**Login (sub-flow of F1)**

| Step | Screen → Element | User Action | System Response | Next Step |
|---|---|---|---|---|
| 1 | Landing → "Login" button | Taps "Login" | Navigates to Login screen | Step 2 |
| 2 | Login screen: Email, Password, "Log In" button | Enters credentials, taps "Log In" | Supabase Auth verifies credentials | Step 3 |
| 3a | — | — | IF credentials valid → session created, local guest cart merges with account cart (F5, AC4) | Redirect to Home |
| 3b | — | — | IF credentials invalid → error shown, no session created | Remain on Login screen |

**Error message wording (Login):** "Incorrect email or password." (Deliberately non-specific about which field is wrong, to avoid confirming registered emails to attackers.)

**Note:** There is no "Forgot Password" link on the Login screen in v1 — this is explicitly out of scope (PRD §6, item 2). Password changes are only possible while logged in (see §2.3 Account Management).

---

### 2.2 Main Feature Usage: Browse → Cart → Checkout → Track (F2–F11)

This is OneBasket's primary task chain, mirroring PRD Scenario 1.

#### 2.2.1 Product Browsing & Search (F2, F3, F4)

**Happy Path**

| Step | Screen → Element | User Action | System Response | Next Step |
|---|---|---|---|---|
| 1 | Home → Category nav bar | Taps a category | Loads paginated product listing filtered by category (<2s target) | Product Listing screen |
| 2 | Product Listing → Search bar | Types keyword, submits | Returns name/description matches (<1.5s target) | Listing updates in place |
| 3 | Product Listing → Filter panel | Sets price min/max, selects category, chooses sort order | Listing re-queries without full page reload | Listing updates in place |
| 4 | Product Listing → Product card | Taps a product card | Navigates to Product Detail screen | Product Detail screen |
| 5 | Product Detail → Variant selector | Selects size/color/weight variant | Price and stock status update for selected variant | Ready to add to cart |

**Error States**

| Condition | System Response | Message Shown |
|---|---|---|
| Search returns no matches | Empty-state illustration, not a blank screen | "No products found for '\{query\}'. Try a different search." |
| Listing fails to load (network/server) | Error state with retry button | "Couldn't load products. Tap to retry." |
| Variant is out of stock | Variant option visibly disabled, cannot be selected/added | "Out of stock" label on the disabled variant |
| Filters return zero results | Empty state, filters remain visible/editable | "No products match your filters. Try adjusting them." |

**Edge Cases**

- IF the user navigates back from Product Detail to Listing → THEN previously applied filters/sort persist (F4, AC4).
- IF stock changes (goes to zero) while the user is viewing the Listing screen → THEN the product's stock badge updates on next fetch/refresh, but is authoritatively re-validated at add-to-cart and checkout regardless of what the UI shows.
- IF the catalog has zero categories/products (new store setup) → THEN Home shows an empty-state message rather than an error.

#### 2.2.2 Cart Management (F5)

**Happy Path**

| Step | Screen → Element | User Action | System Response | Next Step |
|---|---|---|---|---|
| 1 | Product Detail → "Add to Cart" button | Taps after selecting variant | Creates/updates cart line item locally (and in Supabase if logged in) | Cart badge count increments |
| 2 | Cart screen → Quantity stepper | Increases/decreases quantity | Validates against available stock for that variant; updates line total | Cart total recalculates |
| 3 | Cart screen → "Remove" icon | Taps remove on a line item | Removes item, recalculates cart total immediately (F5, AC5) | Cart updates in place |
| 4 | Cart screen → "Proceed to Checkout" button | Taps button | Navigates to Checkout screen | Checkout screen |

**Error States**

| Condition | System Response | Message Shown |
|---|---|---|
| Quantity requested exceeds stock | Stepper blocked at max available; input rejected | "Only \{n\} left in stock." |
| Cart is empty | Empty-state screen, "Proceed to Checkout" disabled/hidden | "Your cart is empty. Browse products to get started." |
| Guest cart merge conflict (same variant in both local and account cart) on login | Quantities are summed, capped at available stock | No error shown; merge is silent per F5 AC4 |

**Edge Cases**

- IF the user is logged out and adds items, then logs in later → THEN the local guest cart merges into the account's synced cart without data loss (F5, AC4).
- IF the app is closed and reopened → THEN cart persists (locally for guests, synced for logged-in users) (F5, AC3).
- IF a cart item's variant is deactivated by admin while sitting in cart → THEN the item is flagged unavailable in Cart and excluded from checkout total until removed or re-selected.

#### 2.2.3 Checkout & Payment (F7, F8, F9)

**Happy Path**

| Step | Screen → Element | User Action | System Response | Next Step |
|---|---|---|---|---|
| 1 | Checkout → Address section | Selects a saved address, or taps "Add New Address" | If adding new: form for name/phone/address lines/city/pincode | Address confirmed |
| 2 | Checkout → Payment method selector | Chooses "Stripe (Card)" or "Cash on Delivery" | UI updates to show relevant fields | Step 3 |
| 3 | Checkout → Coupon field | Enters coupon code, taps "Apply" | System validates code, applies discount to total (F9, AC1) | Order summary updates |
| 4 | Checkout → Order summary | Reviews items, subtotal, shipping, discount, total | Re-validates stock for all cart items before allowing confirmation | Step 5 |
| 5 | Checkout → "Confirm Order" button | Taps to confirm | IF COD: order created directly. IF Stripe: payment sheet opens, processes tokenized payment | Step 6 |
| 6 | — | — | On success: order record created, cart cleared, stock decremented | Order Confirmation screen |

**Error States**

| Condition | System Response | Message Shown |
|---|---|---|
| Variant went out of stock between add-to-cart and checkout | Checkout blocked at final confirmation step (F8 edge case) | "\{Product name\} is no longer available in your selected option. Please update your cart." |
| Invalid/expired coupon | Error shown; order total unaffected; user can proceed without it | "This coupon code is invalid or has expired." |
| Coupon usage limit reached | Error shown, code not applied | "This coupon has reached its usage limit." |
| Stripe payment fails (card declined, etc.) | Clear error; no order created; cart preserved | "Payment failed. Please check your card details and try again." |
| Network lost mid-checkout | Order NOT created until confirmation succeeds; retry option shown | "You're offline. We'll retry once you're reconnected." (or explicit "Retry" button) |
| Address form incomplete | Field-level errors, save blocked | "Please fill in all required fields." |

**Edge Cases**

- IF the customer loses connectivity mid-checkout → THEN no order is created; cart contents are preserved; a retry option is presented once connectivity returns (Scenario 1, edge case).
- IF the customer applies a coupon, then removes an item that made them ineligible → THEN the coupon is re-validated and removed if no longer applicable, with a notice shown.
- IF Stripe is in test mode and a test card is used → THEN behavior mirrors production flow but no real charge occurs (relevant to the "Stripe test-to-live" open item in PRD §Open Items).

#### 2.2.4 Order Status, Tracking & Cancellation (F10, F11)

**Happy Path**

| Step | Screen → Element | User Action | System Response | Next Step |
|---|---|---|---|---|
| 1 | Order Confirmation → "View Order" | Taps link | Navigates to Order Detail screen showing status "Pending" | Order Detail screen |
| 2 | Order History (list of past orders) | Taps any order row | Navigates to Order Detail for that order | Order Detail screen |
| 3 | Order Detail → Status timeline | — (passive) | Displays current stage: Pending → Confirmed → Shipped → Delivered; updates via Supabase Realtime within 5 seconds of admin action | Timeline advances live |
| 4 | Order Detail → "Cancel Order" button (visible only if status = Pending or Confirmed) | Taps "Cancel Order" | Confirmation dialog appears | Step 5 |
| 5 | Confirmation dialog → "Yes, Cancel" | Confirms | Status → "Cancelled"; stock restored; refund initiated if Stripe, none needed if COD | Cancellation Confirmed state |
| 6 | — | — | Email + in-app notification sent (F11) | Order Detail reflects "Cancelled" |

**Error States**

| Condition | System Response | Message Shown |
|---|---|---|
| Cancel attempted after status already changed to "Shipped" | "Cancel Order" button hidden/disabled in real time, even if screen was already open | "This order can no longer be cancelled — it has already shipped." |
| Cancellation request sent while offline | Action queues for retry, or fails clearly | "You're offline. We'll cancel this order once you're back online." or "Couldn't cancel — please try again." |
| Email notification fails to send | Order status update proceeds regardless (F11, AC4); no user-facing error | (silent — does not block status update) |

**Edge Cases**

- IF the customer has the Order Detail screen open and the admin ships the order at that exact moment → THEN the "Cancel Order" button must disappear in real time via Realtime subscription, not just on next screen load (Scenario 3 edge case).
- IF the customer attempts to cancel only one item in a multi-item order → THEN this is out of scope for v1; cancellation always applies to the entire order (PRD §7, Scenario 3).
- IF a "Failed Delivery" is marked by admin → THEN the customer receives a notification and the order enters a refund/reorder path (Scenario 2 edge case).

#### 2.2.5 Wishlist (F6)

**Happy Path:** Product card/detail heart icon → tap toggles saved state → Wishlist screen lists saved items with live price/stock → "Move to Cart" button transfers item directly into cart.

**Error States:** IF a wishlisted item goes out of stock → THEN it remains listed but "Move to Cart" is disabled with an "Out of stock" label.

**Edge Cases:** IF the user is not logged in → THEN wishlist actions prompt login first, since wishlist persistence requires an account (F6, AC4).

#### 2.2.6 Product Reviews (F12)

**Happy Path:** Order reaches "Delivered" → Product Detail page shows "Write a Review" option (for purchasers) → user selects 1–5 stars, optional text → submits → review appears on product page with reviewer name and date.

**Error States:** IF review text exceeds any configured length limit → THEN inline validation error shown before submit is allowed. IF submission fails (network) → THEN error banner with retry, draft text preserved in the field.

**Edge Cases:** IF a customer edits or deletes their own review → THEN the average rating recalculates immediately (F12, AC3).

---

### 2.3 Account Management (F1, F7)

**Happy Path — Change Password**

| Step | Screen → Element | User Action | System Response | Next Step |
|---|---|---|---|---|
| 1 | Account/Settings screen → "Change Password" | Taps option | Navigates to Change Password screen | Step 2 |
| 2 | Change Password screen: New Password, Confirm New Password fields | Enters new password (≥8 chars), confirms | Client validation | Step 3 |
| 3 | Change Password screen → "Save" button | Taps "Save" | Supabase Auth updates password hash | Success confirmation |
| 4 | — | — | — | Returns to Account/Settings with success toast |

**Happy Path — Manage Addresses (F7)**

| Step | Screen → Element | User Action | System Response | Next Step |
|---|---|---|---|---|
| 1 | Account → "My Addresses" | Taps option | Lists all saved addresses | Address List screen |
| 2 | Address List → "Add New Address" | Taps, fills form (name, phone, address lines, city, pincode) | Validates required fields | Address saved |
| 3 | Address List → "Set as Default" toggle | Taps on any saved address | Updates default flag; only one address can be default at a time | List reflects new default |
| 4 | Address List → "Edit" / "Delete" | Taps on any address | Edit opens pre-filled form; Delete prompts confirmation | Address updated/removed |

**Error States**

| Condition | System Response | Message Shown |
|---|---|---|
| New password < 8 characters | Field-level error, save blocked | "Password must be at least 8 characters." |
| New Password ≠ Confirm | Field-level error, save blocked | "Passwords do not match." |
| Address form missing required field | Field-level error tied to that field | "This field is required." |
| Invalid pincode format | Field-level error | "Enter a valid pincode." |
| Deleting the only saved / default address | Confirmation warns this will leave no default address | "This is your default address. Add another before deleting, or set a new default first." |

**Edge Cases**

- IF the user has zero saved addresses at checkout → THEN Checkout routes them into the "Add New Address" form inline rather than showing an empty address selector.
- IF the user changes their password → THEN the current session remains active (no forced re-login), per F1 AC4 scope (no session invalidation behavior specified).

---

### 2.4 Error Recovery (Cross-Cutting)

This flow applies across all customer and admin screens.

**Happy Path (Recovery from Transient Error)**

| Step | Trigger | System Response | User Action | Next Step |
|---|---|---|---|---|
| 1 | Network request fails (timeout/offline) | Non-blocking error banner or inline retry control appears | Taps "Retry" | Step 2 |
| 2 | Retry triggered | Request re-sent | — | IF success → normal flow resumes; IF failure again → banner persists with retry still available |

**Error States by Type**

| Error Type | Trigger Example | Message Shown | Recovery Action |
|---|---|---|---|
| Offline / no connectivity | Any action requiring network while device is offline | "You're offline. Check your connection and try again." | Auto-retry on reconnect where safe (e.g., status polling); manual retry button for user-initiated actions (checkout, cancel) |
| Timeout | Server takes too long to respond | "This is taking longer than expected. Please try again." | Manual retry button |
| 404 (resource not found) | Deep link to a deleted/deactivated product or order | "We couldn't find what you're looking for." | "Back to Home" button |
| 500 / server error | Backend exception | "Something went wrong on our end. Please try again shortly." | Manual retry button; no data loss (form inputs preserved where applicable) |
| Session expired | Auth token invalid/expired mid-session | "Your session has ended. Please log in again." | Redirect to Login; return to prior screen after successful re-login where feasible |
| Validation error | Any form field failing rules | Field-specific inline message (see individual flows above) | Correct field and resubmit |

**Edge Cases**

- IF a network error occurs during a state-changing action (checkout confirmation, order cancellation) → THEN the system must NOT assume success; it re-checks server state before showing any success confirmation, to avoid false-positive UI states.
- IF the user's session expires while mid-checkout → THEN cart contents are preserved locally; after re-login, the user is returned to Checkout with cart intact rather than routed to Home.
- IF an error banner is dismissed by the user without retrying → THEN the underlying action is considered abandoned; no background retry occurs for user-initiated actions (only for passive data fetches).

---

### 2.5 Admin Flows (F13, F14, F15)

#### 2.5.1 Admin Login

**Happy Path:** Admin navigates to `/admin` → enters email/password → Supabase Auth verifies + RLS role check confirms admin role → redirected to Admin Dashboard.

**Error States:** Invalid credentials → "Incorrect email or password." Non-admin account attempting `/admin` login → "This account does not have admin access."

#### 2.5.2 Product & Inventory Management (F13)

**Happy Path**

| Step | Screen → Element | User Action | System Response | Next Step |
|---|---|---|---|---|
| 1 | Admin Dashboard → "Products" → "Add Product" | Taps button | Opens Add Product form | Step 2 |
| 2 | Add Product form: name, description, category, price, images, variants | Fills fields, uploads images, adds one or more variants each with stock count | Validates required fields | Step 3 |
| 3 | Add Product form → "Save" | Taps "Save" | Product created; appears in customer-facing catalog immediately (if active) | Product List (admin) |
| 4 | Product List → "Edit" on any product | Adjusts price/description/stock | Saves changes | Live catalog updates |
| 5 | Product List → "Deactivate" | Deactivates a product | Removed from customer listings; historical orders referencing it remain intact (F13, AC5) | Product marked inactive |

**Error States**

| Condition | System Response | Message Shown |
|---|---|---|
| Required field missing (name, price, category) | Field-level error, save blocked | "This field is required." |
| Variant stock below configured low-stock threshold | Non-blocking low-stock indicator on the product row | "Low stock: \{n\} left" |
| Image upload fails | Inline error on the image field, other fields unaffected | "Image upload failed. Please try again." |

**Edge Cases**

- IF an order is placed for a product while admin is mid-edit on that same product → THEN stock decrements are applied at the database level (not blocked by the admin's open edit session); admin sees updated stock on save/refresh.
- IF admin deactivates a product that's currently in a customer's cart → THEN that cart line item becomes unavailable for checkout (see §2.2.2 edge cases).

#### 2.5.3 Order Management (F14)

**Happy Path**

| Step | Screen → Element | User Action | System Response | Next Step |
|---|---|---|---|---|
| 1 | Admin Dashboard → Orders tab (filterable by status) | Views "Pending" queue | Lists orders newest-first | Step 2 |
| 2 | Order Detail (admin) → items, address, payment method | Reviews details | — | Step 3 |
| 3 | Order Detail → Status dropdown/buttons | Updates status: Pending → Confirmed → Shipped → Delivered | Propagates to customer app via Realtime within 5 seconds; audit log entry created | Customer notified (F11) |

**Error States**

| Condition | System Response | Message Shown |
|---|---|---|
| Admin attempts to skip statuses (e.g., Pending → Delivered) | Allowed, but change is logged for audit (Scenario 2 edge case) | Confirmation prompt: "This will skip intermediate stages. Continue?" |
| Delivery partner reports undeliverable package | Admin marks "Failed Delivery" | Triggers customer notification and refund/reorder path |
| Two status updates submitted near-simultaneously (future multi-admin) | Last-write-wins in v1; no data corruption | No error shown to admin (documented limitation, not user-facing) |

#### 2.5.4 Coupon Management (F15)

**Happy Path:** Admin → "Coupons" → "Create Coupon" → sets code, discount type (flat/percentage), value, expiry date, usage limit → "Save" → coupon becomes active immediately → usage count visible per coupon → admin can deactivate before expiry.

**Error States:** Duplicate coupon code → "This coupon code already exists." Missing required field → "This field is required." Expiry date in the past → "Expiry date must be in the future."

---

## 3. Navigation Map

```
OneBasket
│
├── (Unauthenticated)
│   ├── Landing / Splash
│   ├── Login
│   └── Registration
│
├── Customer App (Authenticated + limited guest browsing)
│   ├── Home
│   │   ├── Category Navigation
│   │   └── (Featured section — P1, not in v1)
│   ├── Product Listing
│   │   ├── Filter Panel
│   │   └── Sort Controls
│   ├── Search Results
│   ├── Product Detail
│   │   ├── Variant Selector
│   │   ├── Reviews Section
│   │   │   └── Write/Edit Review
│   │   └── Add to Cart
│   ├── Cart
│   ├── Wishlist
│   ├── Checkout
│   │   ├── Address Selection
│   │   │   └── Add/Edit Address
│   │   ├── Payment Method Selection
│   │   │   └── Stripe Payment Sheet
│   │   └── Coupon Entry
│   ├── Order Confirmation
│   ├── Order History
│   │   └── Order Detail
│   │       ├── Status Timeline
│   │       ├── Cancel Order (conditional)
│   │       └── Request Return (P1 — not in v1)
│   └── Account / Settings
│       ├── Profile
│       ├── Change Password
│       ├── My Addresses
│       │   └── Add/Edit Address
│       └── Logout
│
└── Admin Web Portal (Authenticated, admin role only)
    ├── Admin Login
    ├── Admin Dashboard (overview)
    ├── Products
    │   ├── Product List
    │   ├── Add Product
    │   └── Edit Product
    ├── Orders
    │   ├── Order Queue (filterable by status)
    │   └── Order Detail (admin view)
    └── Coupons
        ├── Coupon List
        ├── Create Coupon
        └── Edit Coupon
```

---

## 4. Screen Inventory

| Screen | Route | Access Level | Purpose | Key Elements | Actions → Destination | State Variants |
|---|---|---|---|---|---|---|
| Landing/Splash | `/` | Public | Entry routing | Logo, Login/Register buttons | Login → `/login`; Register → `/register` | Loading (session check) |
| Login | `/login` | Public | Authenticate customer | Email, Password, "Log In" | Submit → `/home` (success) or stays (error) | Default, Error, Loading |
| Registration | `/register` | Public | Create customer account | Email, Password, Confirm Password | Submit → `/home` | Default, Error, Loading |
| Home | `/home` | Customer (some guest browsing) | Landing after login; category entry | Category nav, search bar | Category tap → `/products?category=` | Loading, Empty (no categories), Success |
| Product Listing | `/products` | Customer/Guest | Browse/filter/sort products | Product cards, filter panel, sort dropdown | Product tap → `/product/:id` | Loading, Empty, Error, Success |
| Search Results | `/search?q=` | Customer/Guest | Keyword search results | Search bar, result cards | Product tap → `/product/:id` | Loading, Empty ("no products found"), Success |
| Product Detail | `/product/:id` | Customer/Guest (add-to-cart requires login) | View item, select variant, read/write reviews | Images, variant selector, price, stock, reviews, Add to Cart, Wishlist icon | Add to Cart → cart updates; Wishlist toggle | Loading, Out-of-Stock variant, Error (404), Success |
| Cart | `/cart` | Customer (login required) | Review items before checkout | Line items, quantity stepper, total, "Proceed to Checkout" | Checkout → `/checkout` | Empty, Loading, Success |
| Wishlist | `/wishlist` | Customer (login required) | Saved-for-later items | Saved product cards, "Move to Cart" | Move to Cart → cart updates | Empty, Loading, Success |
| Checkout | `/checkout` | Customer (login required) | Complete purchase | Address selector, payment method, coupon field, order summary, Confirm button | Confirm → `/order-confirmation/:id` or error | Loading, Validation Error, Payment Error, Stock-Conflict Error |
| Order Confirmation | `/order-confirmation/:id` | Customer | Confirms successful order | Order ID, summary, "View Order" | View Order → `/orders/:id` | Success only |
| Order History | `/orders` | Customer (login required) | List past orders | Order rows (date, items, total, status) | Row tap → `/orders/:id` | Empty, Loading, Success |
| Order Detail | `/orders/:id` | Customer (own orders only, RLS-enforced) | Track/cancel a specific order | Status timeline, items, Cancel button (conditional) | Cancel → confirmation dialog → status update | Pending, Confirmed, Shipped, Delivered, Cancelled, Loading, Error (404) |
| Account/Settings | `/account` | Customer (login required) | Manage profile/password | Profile info, "Change Password", "My Addresses", Logout | Navigates to sub-screens | Default |
| Change Password | `/account/password` | Customer (login required) | Update password | New/Confirm Password fields | Save → success toast | Default, Error, Loading |
| My Addresses | `/account/addresses` | Customer (login required) | Manage saved addresses | Address list, Add/Edit/Delete, Set Default | Add/Edit → form | Empty, Loading, Success |
| Admin Login | `/admin/login` | Public (routes to admin only) | Authenticate admin | Email, Password | Submit → `/admin/dashboard` | Default, Error, Loading |
| Admin Dashboard | `/admin/dashboard` | Admin only (RLS-enforced) | Overview/navigation hub | Summary stats, nav to Products/Orders/Coupons | Nav taps | Loading, Success |
| Product List (admin) | `/admin/products` | Admin only | Manage catalog | Product rows, low-stock indicators, "Add Product" | Add → form; row tap → edit | Empty, Loading, Success |
| Add/Edit Product | `/admin/products/new`, `/admin/products/:id` | Admin only | Create/update product | Name, description, category, price, images, variants+stock | Save → returns to list | Default, Validation Error, Loading |
| Order Queue (admin) | `/admin/orders` | Admin only | View/manage incoming orders | Order rows, status filter | Row tap → order detail | Empty, Loading, Success |
| Order Detail (admin) | `/admin/orders/:id` | Admin only | Update status, view full details | Items, customer info, address, payment method, status control | Update status → propagates via Realtime | Loading, Success, Skip-Stage Confirmation |
| Coupon List (admin) | `/admin/coupons` | Admin only | Manage discount codes | Coupon rows, usage counts | Add → form; row tap → edit | Empty, Loading, Success |
| Add/Edit Coupon | `/admin/coupons/new`, `/admin/coupons/:id` | Admin only | Create/update coupon | Code, discount type, value, expiry, usage limit | Save → returns to list | Default, Validation Error, Loading |

---

## 5. Decision Points

- IF a valid session token exists on app launch → THEN route to Home; ELSE route to Landing.
- IF the user attempts to add an item to cart while logged out → THEN prompt login/registration first; guest checkout is not supported.
- IF a selected variant's stock is 0 → THEN disable the variant option and block "Add to Cart" for it.
- IF cart quantity requested > available stock → THEN cap at available stock and show a stock-limit message.
- IF a guest cart exists at login time → THEN merge it into the account cart, summing quantities and capping at stock (F5, AC4).
- IF any cart item goes out of stock between add-to-cart and final checkout confirmation → THEN block confirmation and require cart update.
- IF a coupon code is invalid, expired, or over its usage limit → THEN show the corresponding error and proceed with the order at full price (no coupon applied).
- IF payment method = Stripe and payment fails → THEN do not create an order record or decrement stock.
- IF payment method = COD → THEN create the order directly without a payment step.
- IF network connectivity is lost during final order confirmation → THEN do not create the order; preserve cart; show retry option.
- IF order status = "Pending" or "Confirmed" → THEN show "Cancel Order"; IF status = "Shipped" or later → THEN hide/disable it, updating in real time even on an already-open screen.
- IF an order is cancelled → THEN restore stock for its items; IF payment was via Stripe → THEN initiate refund; IF COD → THEN no financial action needed.
- IF admin updates order status → THEN propagate to the customer's app within 5 seconds via Supabase Realtime and log the change to the audit trail.
- IF admin skips a status stage (e.g., Pending → Delivered directly) → THEN allow it but log it for audit and prompt confirmation.
- IF a product/variant is deactivated by admin while present in a customer's cart → THEN mark that cart line as unavailable and exclude it from checkout totals until resolved.
- IF a variant's stock falls below the configured low-stock threshold → THEN show a low-stock indicator to admin.
- IF two admins (future multi-admin) update the same order concurrently → THEN apply last-write-wins without corrupting the record (documented limitation, not a v1-visible error).
- IF a customer's session expires mid-checkout → THEN preserve cart locally and return them to Checkout after re-login rather than to Home.
- IF a delivered order is within the return window (P1, not v1) → THEN show "Request Return"; this branch is inactive in v1 per PRD scope.

---

## 6. Error Handling

### 6.1 404 — Resource Not Found
- **Triggers:** Deep link to a deleted/deactivated product, a cancelled-and-purged reference, or a mistyped route.
- **What displays:** Dedicated "Not Found" state with an explanatory message and a "Back to Home" action — never a blank screen or raw error code.
- **Message:** "We couldn't find what you're looking for."
- **User actions available:** Return to Home; retry navigation (for deep links, in case of a transient sync delay).
- **System recovery:** No automatic recovery beyond re-routing; the underlying resource is not restored.

### 6.2 500 / Server Errors
- **Triggers:** Backend exceptions during any read/write operation (product fetch, order creation, status update, etc.).
- **What displays:** Non-destructive error banner or full-screen error state depending on severity; any in-progress form input is preserved, not cleared.
- **Message:** "Something went wrong on our end. Please try again shortly."
- **User actions available:** Manual retry; navigate away without losing unsaved input where technically feasible.
- **System recovery:** No state-changing action (order creation, payment, status update) is assumed successful until the server confirms it — the client re-checks state before showing any success screen.

### 6.3 Network Offline
- **Triggers:** Device loses connectivity during any network-dependent action.
- **What displays:** Persistent, non-blocking banner ("You're offline") while offline; blocking retry prompts specifically for state-changing actions (checkout confirmation, order cancellation) so the user cannot assume an action succeeded.
- **Message:** "You're offline. Check your connection and try again." (checkout/cancellation specifically: "You're offline. We'll retry once you're reconnected," with cart/action state preserved.)
- **User actions available:** Manual retry button; passive screens (listings, order status) auto-refresh once connectivity returns.
- **System recovery:** Passive data (product listings, order status via Realtime) reconnects and refreshes automatically; user-initiated state changes require explicit retry, never silent background resubmission of a payment or order action.

### 6.4 Session Expiry
- **Triggers:** Auth token expires or is invalidated mid-session.
- **What displays:** Redirect to Login with a explanatory message; cart/checkout-in-progress data preserved locally where possible.
- **Message:** "Your session has ended. Please log in again."
- **User actions available:** Re-authenticate via Login screen.
- **System recovery:** After successful re-login, return the user to their prior screen/context (e.g., Checkout with cart intact) rather than defaulting to Home.

---

## 7. Responsive Behavior

Per PRD Non-Functional Requirements — Compatibility: mobile breakpoint <600px, tablet 600–1024px, desktop >1024px.

| Aspect | Mobile (<600px) | Tablet (600–1024px) | Desktop (>1024px, incl. Admin) |
|---|---|---|---|
| Navigation | Bottom nav bar / hamburger menu | Side drawer or top nav, collapsible | Persistent top/side navigation |
| Product Listing | Single-column card list | 2-column grid | 3–4 column grid |
| Filters | Slide-up bottom sheet | Slide-out side panel | Persistent left sidebar |
| Product Detail | Stacked: image → info → variants → reviews | Two-column: image left, info right | Two-column, wider image gallery |
| Cart / Checkout | Full-screen single-column steps | Single-column, wider margins | Single-column form with summary sidebar |
| Admin Portal | Not primary target; basic responsive fallback only (tablet as secondary consideration per NFR) | Secondary support — functional but not optimized | Primary target (≥1024px) — full dashboard layout |
| Touch Targets | Minimum 48×48dp on all interactive elements (buttons, cart icons, filters) per accessibility NFR | Same 48×48dp minimum retained | Standard cursor-based sizing; 48×48dp still respected for touch-capable desktop/hybrid devices |
| Realtime Status Updates | Same 5-second propagation target regardless of device | Same | Same |

**IF-THEN — Layout Switching**
- IF viewport width < 600px → THEN render mobile layout (single column, bottom navigation).
- IF viewport width is between 600–1024px → THEN render tablet layout (adaptive grid, side panels).
- IF viewport width > 1024px → THEN render desktop layout (multi-column, persistent navigation); Admin Portal requires this breakpoint as its primary supported width.
- IF the Admin Portal is accessed below 1024px → THEN a functional but non-optimized fallback layout is shown, per NFR (tablet is "secondary consideration," no support below that is specified).

---

*Screen names, feature IDs (F1–F25), and acceptance criteria referenced throughout this document match PRD.md exactly. Features marked P1/P2 (e.g., Return/Exchange, Push Notifications, Recently Viewed, Featured Products, Multi-Admin Roles) are documented only where they intersect with v1 flows (e.g., conditional "Request Return" placeholder) and are otherwise out of scope for this release.*