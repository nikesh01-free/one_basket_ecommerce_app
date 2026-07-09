<h1 align="center">🛒 OneBasket — Hyperlocal E-Commerce App</h1>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white"/>
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white"/>
  <img src="https://img.shields.io/badge/Supabase-2.6.0-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white"/>
  <img src="https://img.shields.io/badge/Stripe-10.2.0-635BFF?style=for-the-badge&logo=stripe&logoColor=white"/>
  <img src="https://img.shields.io/badge/Riverpod-2.5.1-0553B1?style=for-the-badge"/>
</p>

<p align="center">
  A full-featured, hyperlocal e-commerce Flutter application targeting delivery within a defined city radius. Built with clean architecture, Riverpod state management, Supabase backend, and Stripe payments.
</p>

---

## 📱 Features

| Module | Description |
|---|---|
| 🔐 **Authentication** | Email/password login, registration, splash screen, password change |
| 🛍️ **Catalog** | Home feed, product listing, product detail, category browsing |
| 🛒 **Cart** | Add/remove items, quantity control, real-time total calculation |
| 💳 **Checkout** | Stripe payment integration, order placement, order confirmation |
| 📦 **Orders** | Order history list, order detail view |
| ❤️ **Wishlist** | Save favourite products, sync across sessions |
| 🏠 **Addresses** | Add and manage delivery addresses |
| 🔔 **Notifications** | In-app notification screen |
| ⭐ **Reviews** | Product review and ratings screen |
| 👤 **Profile & Settings** | Edit profile, change password, theme toggle |
| 🌐 **Offline Support** | Graceful offline screen when no internet connection |
| 🌙 **Dark Mode** | Full light/dark theme support via Riverpod |

---

## 🏗️ Architecture

```
lib/
├── core/
│   ├── models/           # Shared data models
│   ├── network/          # Mock repositories & API layer
│   ├── routing/          # go_router navigation setup
│   ├── theme/            # App theme (light/dark) + ThemeProvider
│   └── widgets/          # Reusable UI components (buttons, cards, text fields)
│
└── features/
    ├── auth/             # Login, Register, Splash, Profile, Settings
    ├── catalog/          # Home, Product List, Product Detail, Categories
    ├── cart/             # Cart screen + CartProvider
    ├── checkout/         # Checkout screen + Order Confirmation
    ├── orders/           # Orders list + Order Detail
    ├── wishlist/         # Wishlist screen + WishlistProvider
    ├── addresses/        # Addresses screen + AddressProvider
    ├── notifications/    # Notifications screen
    └── reviews/          # Reviews screen
```

**State Management:** [Riverpod](https://riverpod.dev/) (flutter_riverpod 2.5.1)  
**Navigation:** [go_router](https://pub.dev/packages/go_router) 14.2.0  
**Backend:** [Supabase](https://supabase.com/) (Auth + Database + Storage)  
**Payments:** [Stripe](https://stripe.com/) via flutter_stripe

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `^3.x` ([Install Flutter](https://docs.flutter.dev/get-started/install))
- Dart SDK `^3.11.5`
- A [Supabase](https://supabase.com/) project
- A [Stripe](https://stripe.com/) account (test keys work fine)

### 1. Clone the Repository

```bash
git clone https://github.com/nikesh01-free/one_basket_ecommerce_app.git
cd one_basket_ecommerce_app
```

### 2. Set Up Environment Variables

```bash
cp .env.example .env
```

Open `.env` and fill in your credentials:

```env
# Supabase — https://supabase.com/dashboard → Project → Settings → API
SUPABASE_URL=https://<your-project-ref>.supabase.co
SUPABASE_ANON_KEY=<your-anon-public-key>

# Stripe — https://dashboard.stripe.com/apikeys
STRIPE_PUBLISHABLE_KEY=pk_test_<your-stripe-publishable-key>

# Hyperlocal Config
DELIVERY_CITY=Ahmedabad
DELIVERY_RADIUS_KM=15.0
MIN_ORDER_AMOUNT=150.00
FLAT_DELIVERY_CHARGE=30.00

# Support
SUPPORT_PHONE=+91XXXXXXXXXX
SUPPORT_EMAIL=support@yourapp.in
```

> ⚠️ **Never commit `.env`** — it is already listed in `.gitignore`.

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Run the App

```bash
# Android / iOS
flutter run

# Specific device
flutter run -d <device-id>
```

---

## 📦 Dependencies

### Core
| Package | Version | Purpose |
|---|---|---|
| `supabase_flutter` | 2.6.0 | Backend — Auth, DB, Storage |
| `flutter_riverpod` | 2.5.1 | State management |
| `go_router` | 14.2.0 | Declarative navigation |
| `flutter_stripe` | 10.2.0 | Payment processing |
| `dio` | 5.5.0 | HTTP client |
| `flutter_dotenv` | 5.1.0 | Environment variable loading |

### UI & Utilities
| Package | Version | Purpose |
|---|---|---|
| `cached_network_image` | 3.3.1 | Efficient image loading & caching |
| `flutter_svg` | 2.0.10 | SVG asset rendering |
| `fl_chart` | 0.68.0 | Charts & data visualisation |
| `image_picker` | 1.1.2 | Camera / gallery image selection |
| `flutter_image_compress` | 2.3.0 | Image compression before upload |
| `shared_preferences` | 2.2.3 | Local key-value persistence |
| `intl` | 0.19.0 | Internationalisation & date/number formatting |
| `uuid` | 4.4.0 | UUID generation |

### Dev Dependencies
| Package | Purpose |
|---|---|
| `build_runner` | Code generation runner |
| `freezed` | Immutable data classes |
| `json_serializable` | JSON serialization |
| `mocktail` | Mocking for unit tests |
| `flutter_lints` | Lint rules |

---

## 🔐 Security

- All secrets live in `.env` which is **gitignored** and never committed
- `.env.example` provides a safe template for new contributors
- `android/local.properties`, keystore files, and `google-services.json` are all gitignored
- Supabase Row Level Security (RLS) should be enabled on all tables

---

## 🗺️ Roadmap

- [ ] Admin panel (product & order management)
- [ ] Push notifications (FCM)
- [ ] Real-time order tracking
- [ ] Multi-language support (i18n)
- [ ] Google / Apple sign-in
- [ ] Play Store & App Store release

---

## 🤝 Contributing

1. Fork the repo
2. Create your branch: `git checkout -b feature/your-feature`
3. Copy and fill `.env`: `cp .env.example .env`
4. Commit your changes: `git commit -m 'feat: add your feature'`
5. Push to the branch: `git push origin feature/your-feature`
6. Open a Pull Request

---

## 📄 License

This project is for personal/portfolio use. All rights reserved © Nikesh Prajapati.
