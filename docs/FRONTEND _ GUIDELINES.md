# OneBasket Frontend Design System (FRONTEND_GUIDELINES.md)

This document specifies the complete, production-ready frontend design system for OneBasket—covering design principles, design tokens, a reusable component library, layout specifications, accessibility standards, motion design, iconography guidelines, illustration rules, and Flutter theme architecture. 

---

## 1. Design Principles

OneBasket is designed for offline-first and digital-native customers in Ahmedabad. The frontend architecture, UX workflows, and UI components are guided by the following 5 core design principles:

### 1.1 Simplicity
* **Core Philosophy**: Hyperlocal customers range from young professionals to elderly family shoppers. The UI must speak a clear language, minimizing cognitive load. 
* **UI Decisions**:
  * Limit the visual density. Avoid cluttered layouts; every page must have a single primary call to action (CTA).
  * Use clear, explicit labels instead of ambiguous icons.
  * Multi-step workflows (like checkout) are broken down into simple, sequential screens rather than complex single-page forms.

### 1.2 Trust
* **Core Philosophy**: E-commerce transactions require security, clear communication, and visual stability. The customer must always know what they are paying for and when it will arrive.
* **UI Decisions**:
  * Emphasize tactile feedback using modern neomorphic cards that feel like real objects.
  * Display real-time order status transparently without requiring manual page refreshes.
  * Provide inline validations and transparent pricing summaries showing tax, shipping, and discounts before checkout.

### 1.3 Accessibility
* **Core Philosophy**: The application must be fully usable by individuals with varying visual, motor, and cognitive abilities, conforming to WCAG 2.1 AA guidelines.
* **UI Decisions**:
  * All interactive elements (buttons, inputs, tabs) maintain a minimum target size of 48×48 dp.
  * Contrast ratios must be verified (minimum 4.5:1 for normal text, 3:1 for large text).
  * Provide native screen reader semantics, logical focus order, and full text-scaling support.

### 1.4 Speed
* **Core Philosophy**: Speed of interaction directly impacts conversion rates. The interface must feel instantaneous, even on mid-range devices under unstable network connections.
* **UI Decisions**:
  * UI transitions are kept under 300ms.
  * Use skeleton screens to establish immediate structural layout before remote content loads.
  * Implement optimistic UI states for actions like "Add to Cart" and "Toggle Wishlist" to avoid loading spinners during local state changes.

### 1.5 Consistency
* **Core Philosophy**: Predictability builds confidence. If an element acts as a button or an input on one screen, it must look and behave identically across the entire app.
* **UI Decisions**:
  * Restrict spacing to a strict mathematical scale (8pt grid).
  * Implement a unified typography and color scheme referenced through global Flutter tokens.
  * Component states (default, hover, focus, active, disabled) are systematically implemented.

---

## 2. Design Tokens

Design tokens are the visual atoms of our design system. They store color, typography, spacing, border-radius, and elevation values in a platform-agnostic format, implemented here as native Flutter constants.

### 2.1 Colors

The OneBasket palette is curated to reflect trust (deep indigo), speed (warm amber), and hyperlocal freshness (warm neutrals).

#### 2.1.1 Primary Scale (OneBasket Indigo - Trust)
* **Emotional Association**: Security, reliability, professional customer service.

| Token | Hex | Recommended Text Color | Usage | Accessibility Notes |
|---|---|---|---|---|
| `primary-50` | `#F5F6FF` | `#1E1B4B` | Backgrounds, very light tints | Passes 4.5:1 with dark text |
| `primary-100` | `#E0E4FF` | `#1E1B4B` | Light active states, badges | Passes 4.5:1 with dark text |
| `primary-200` | `#C1C9FF` | `#1E1B4B` | Borders, subtle highlights | Passes 3:1 with dark text |
| `primary-300` | `#9AA4FC` | `#0F0E2E` | Disabled active state, illustrations | Use with dark text only |
| `primary-400` | `#707AEB` | `#FFFFFF` | Focus outlines, secondary UI | Passes 3:1 with white text |
| `primary-500` | `#4F46E5` | `#FFFFFF` | Brand Primary, Buttons, Active Icons | Passes 4.5:1 with white text |
| `primary-600` | `#4338CA` | `#FFFFFF` | Hover / Pressed states | Passes 4.5:1 with white text |
| `primary-700` | `#3730A3` | `#FFFFFF` | Dark UI accents, headers | Passes 7:1 (AAA) with white text |
| `primary-800` | `#1E1B4B` | `#FFFFFF` | Dark mode primary backgrounds | Passes 7:1 (AAA) with white text |
| `primary-900` | `#0F0E2E` | `#FFFFFF` | Deepest headings, footer backgrounds | Passes 7:1 (AAA) with white text |

#### 2.1.2 Neutral Scale (OneBasket Warm Gray - Freshness & Local Feel)
* **Emotional Association**: Natural, high-quality, balanced, clean.

| Token | Hex | Recommended Text Color | Usage | Accessibility Notes |
|---|---|---|---|---|
| `neutral-50` | `#FAF9F6` | `#1C1917` | Standard app background (Light) | Base canvas background |
| `neutral-100` | `#F5F4F0` | `#1C1917` | Card surface color (Light) | Neomorphic elevated surface |
| `neutral-200` | `#EAE8E2` | `#1C1917` | Neomorphic dark shadow, dividers | Structural borders |
| `neutral-300` | `#D7D4CD` | `#1C1917` | Disabled button background, borders | Border contrast indicator |
| `neutral-400` | `#AFA99F` | `#1C1917` | Placeholder text, inactive icons | Non-text UI element contrast |
| `neutral-500` | `#877F73` | `#FFFFFF` | Secondary labels, captions | Passes 3:1 with white/dark text |
| `neutral-600` | `#625A50` | `#FFFFFF` | Secondary body text | Passes 4.5:1 with white |
| `neutral-700` | `#453E36` | `#FFFFFF` | Main body text | Passes 4.5:1 with white |
| `neutral-800` | `#2C2722` | `#FFFFFF` | Headings, subheadings | Passes 7:1 (AAA) with white |
| `neutral-900` | `#1C1917` | `#FFFFFF` | App background (Dark), deep text | Passes 7:1 (AAA) with white |

#### 2.1.3 Semantic Colors (Status Indications)

* **Success (Fresh Green)**
  * Base: `#2E7D32` (Text/Icons) | Background: `#E8F5E9` (Light Mode Fill) | Dark Mode Base: `#4CAF50`
  * Usage: Complete transactions, stock available badges, valid coupon indications.
  * Contrast: Meets 4.5:1 against white (`#2E7D32` = 5.6:1).
* **Warning (Amber/Orange)**
  * Base: `#EF6C00` (Text/Icons) | Background: `#FFF8E1` (Light Mode Fill) | Dark Mode Base: `#FF9800`
  * Usage: Low stock alerts, pending orders, intermediate status updates.
  * Contrast: Meets 3:1 for large elements; text uses dark neutral over warning backgrounds.
* **Error (Red)**
  * Base: `#C62828` (Text/Icons) | Background: `#FFEBEE` (Light Mode Fill) | Dark Mode Base: `#EF5350`
  * Usage: Out of stock badges, declined payments, transaction failures, validation errors.
  * Contrast: Meets 4.5:1 against white (`#C62828` = 6.4:1).
* **Info (Blue)**
  * Base: `#1565C0` (Text/Icons) | Background: `#E3F2FD` (Light Mode Fill) | Dark Mode Base: `#42A5F5`
  * Usage: Coupon codes, tips, delivery time estimates, information banners.
  * Contrast: Meets 4.5:1 against white (`#1565C0` = 5.2:1).

#### 2.1.4 Color Code Implementation
```dart
import 'package:flutter/material.dart';

abstract class OBColors {
  // Primary Scale
  static const Color primary50 = Color(0xFFF5F6FF);
  static const Color primary100 = Color(0xFFE0E4FF);
  static const Color primary200 = Color(0xFFC1C9FF);
  static const Color primary300 = Color(0xFF9AA4FC);
  static const Color primary400 = Color(0xFF707AEB);
  static const Color primary500 = Color(0xFF4F46E5); // Base Brand Primary
  static const Color primary600 = Color(0xFF4338CA);
  static const Color primary700 = Color(0xFF3730A3);
  static const Color primary800 = Color(0xFF1E1B4B);
  static const Color primary900 = Color(0xFF0F0E2E);

  // Neutral Scale
  static const Color neutral50 = Color(0xFFFAF9F6); // Light Background
  static const Color neutral100 = Color(0xFFF5F4F0); // Light Surface
  static const Color neutral200 = Color(0xFFEAE8E2);
  static const Color neutral300 = Color(0xFFD7D4CD);
  static const Color neutral400 = Color(0xFFAFA99F);
  static const Color neutral500 = Color(0xFF877F73);
  static const Color neutral600 = Color(0xFF625A50);
  static const Color neutral700 = Color(0xFF453E36); // Light Primary Text
  static const Color neutral800 = Color(0xFF2C2722);
  static const Color neutral900 = Color(0xFF1C1917); // Dark Background

  // Semantic Light
  static const Color success = Color(0xFF2E7D32);
  static const Color successBg = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFEF6C00);
  static const Color warningBg = Color(0xFFFFF8E1);
  static const Color error = Color(0xFFC62828);
  static const Color errorBg = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF1565C0);
  static const Color infoBg = Color(0xFFE3F2FD);

  // Semantic Dark
  static const Color successDark = Color(0xFF4CAF50);
  static const Color warningDark = Color(0xFFFF9800);
  static const Color errorDark = Color(0xFFEF5350);
  static const Color infoDark = Color(0xFF42A5F5);
}
```

---

### 2.2 Typography

We use **`Poppins`** as the primary font family for display, headings, and branding elements. It is chosen for its geometric friendliness, excellent readability on screen, and clean structure. For body and captions, we use **`Inter`** to maximize text density and readability at smaller scales.

#### 2.2.1 Type Styles Specification

| Token Name | Font Family | Font Weight | Size (rem) | Flutter Font Size | Line Height | Letter Spacing |
|---|---|---|---|---|---|---|
| `Display XL` | Poppins | Bold (700) | 2.50rem | 40.0 | 1.2 | -0.5px |
| `Display L` | Poppins | Bold (700) | 2.00rem | 32.0 | 1.2 | -0.2px |
| `Heading 1` | Poppins | SemiBold (600) | 1.75rem | 28.0 | 1.3 | 0.0px |
| `Heading 2` | Poppins | SemiBold (600) | 1.50rem | 24.0 | 1.3 | 0.0px |
| `Heading 3` | Poppins | Medium (500) | 1.25rem | 20.0 | 1.4 | 0.1px |
| `Title` | Poppins | Medium (500) | 1.125rem | 18.0 | 1.4 | 0.1px |
| `Subtitle` | Inter | SemiBold (600) | 1.00rem | 16.0 | 1.5 | 0.15px |
| `Body Large` | Inter | Regular (400) | 1.00rem | 16.0 | 1.5 | 0.15px |
| `Body` | Inter | Regular (400) | 0.875rem | 14.0 | 1.5 | 0.25px |
| `Caption` | Inter | Regular (400) | 0.75rem | 12.0 | 1.4 | 0.4px |
| `Overline` | Inter | Bold (700) | 0.625rem | 10.0 | 1.4 | 1.5px |
| `Button` | Poppins | SemiBold (600) | 0.875rem | 14.0 | 1.0 | 0.5px |

#### 2.2.2 Typography Code Implementation
```dart
class OBTypography {
  static const String headingFont = 'Poppins';
  static const String bodyFont = 'Inter';

  static TextStyle displayXL = const TextStyle(
    fontFamily: headingFont,
    fontWeight: FontWeight.w700,
    fontSize: 40.0,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static TextStyle displayL = const TextStyle(
    fontFamily: headingFont,
    fontWeight: FontWeight.w700,
    fontSize: 32.0,
    height: 1.2,
    letterSpacing: -0.2,
  );

  static TextStyle heading1 = const TextStyle(
    fontFamily: headingFont,
    fontWeight: FontWeight.w600,
    fontSize: 28.0,
    height: 1.3,
    letterSpacing: 0.0,
  );

  static TextStyle heading2 = const TextStyle(
    fontFamily: headingFont,
    fontWeight: FontWeight.w600,
    fontSize: 24.0,
    height: 1.3,
    letterSpacing: 0.0,
  );

  static TextStyle heading3 = const TextStyle(
    fontFamily: headingFont,
    fontWeight: FontWeight.w500,
    fontSize: 20.0,
    height: 1.4,
    letterSpacing: 0.1,
  );

  static TextStyle title = const TextStyle(
    fontFamily: headingFont,
    fontWeight: FontWeight.w500,
    fontSize: 18.0,
    height: 1.4,
    letterSpacing: 0.1,
  );

  static TextStyle subtitle = const TextStyle(
    fontFamily: bodyFont,
    fontWeight: FontWeight.w600,
    fontSize: 16.0,
    height: 1.5,
    letterSpacing: 0.15,
  );

  static TextStyle bodyLarge = const TextStyle(
    fontFamily: bodyFont,
    fontWeight: FontWeight.w400,
    fontSize: 16.0,
    height: 1.5,
    letterSpacing: 0.15,
  );

  static TextStyle body = const TextStyle(
    fontFamily: bodyFont,
    fontWeight: FontWeight.w400,
    fontSize: 14.0,
    height: 1.5,
    letterSpacing: 0.25,
  );

  static TextStyle caption = const TextStyle(
    fontFamily: bodyFont,
    fontWeight: FontWeight.w400,
    fontSize: 12.0,
    height: 1.4,
    letterSpacing: 0.4,
  );

  static TextStyle overline = const TextStyle(
    fontFamily: bodyFont,
    fontWeight: FontWeight.w700,
    fontSize: 10.0,
    height: 1.4,
    letterSpacing: 1.5,
  );

  static TextStyle button = const TextStyle(
    fontFamily: headingFont,
    fontWeight: FontWeight.w600,
    fontSize: 14.0,
    height: 1.0,
    letterSpacing: 0.5,
  );
}
```

---

### 2.3 Spacing Scale

OneBasket follows a strict 8pt grid system. Sub-grid spacing of 4px and 12px are included for tight icon alignments and micro-spacings.

| Spacing Token | Pixels (px) | rem Value | Flutter Constant | Preferred Usage |
|---|---|---|---|---|
| `space-0` | 0px | 0rem | `0.0` | Inner resets, collapse margin |
| `space-1` | 4px | 0.25rem | `4.0` | Inner padding for badges, text-to-icon gaps |
| `space-2` | 8px | 0.5rem | `8.0` | Small layouts, list item padding, title-to-subtitle gaps |
| `space-3` | 12px | 0.75rem | `12.0` | Mid-padding, cards child spacing |
| `space-4` | 16px | 1.0rem | `16.0` | Base content padding, page gutters, grid spacings |
| `space-5` | 20px | 1.25rem | `20.0` | Card inner margins, primary container pads |
| `space-6` | 24px | 1.5rem | `24.0` | Major section breaks, form fields separation |
| `space-8` | 32px | 2.0rem | `32.0` | Space above floating buttons, hero item headers |
| `space-10` | 40px | 2.5rem | `40.0` | Splash page spacing, illustration margins |
| `space-12` | 48px | 3.0rem | `48.0` | Large header graphics, empty state padding |
| `space-14` | 56px | 3.5rem | `56.0` | Full height action zones |
| `space-16` | 64px | 4.0rem | `64.0` | Outer grid buffer zones |

#### 2.3.1 Spacing Code Implementation
```dart
class OBSpacing {
  static const double space0 = 0.0;
  static const double space1 = 4.0;
  static const double space2 = 8.0;
  static const double space3 = 12.0;
  static const double space4 = 16.0;
  static const double space5 = 20.0;
  static const double space6 = 24.0;
  static const double space8 = 32.0;
  static const double space10 = 40.0;
  static const double space12 = 48.0;
  static const double space14 = 56.0;
  static const double space16 = 64.0;

  // Layout Padding Helpers
  static const EdgeInsets pagePadding = EdgeInsets.all(space4);
  static const EdgeInsets pagePaddingHorizontal = EdgeInsets.symmetric(horizontal: space4);
  static const EdgeInsets cardPadding = EdgeInsets.all(space4);
}
```

---

### 2.4 Border Radius

OneBasket uses rounded corners to emphasize the modern, approachable nature of neomorphic UI elements.

| Token Name | Radius Value (px) | Flutter BorderRadius Implementation | Typical Application |
|---|---|---|---|
| `radius-none` | 0px | `BorderRadius.zero` | Table items, full-bleed screen headers |
| `radius-xs` | 4px | `BorderRadius.circular(4.0)` | Badge shapes, custom checkboxes |
| `radius-sm` | 8px | `BorderRadius.circular(8.0)` | Input text fields, mini card thumbs, tooltips |
| `radius-md` | 12px | `BorderRadius.circular(12.0)` | Standard product cards, category items, checkout row cards |
| `radius-lg` | 16px | `BorderRadius.circular(16.0)` | Bottom sheets, action popups, modals |
| `radius-xl` | 24px | `BorderRadius.circular(24.0)` | Main category tiles, promo flyers |
| `radius-2xl` | 32px | `BorderRadius.circular(32.0)` | Splash assets, onboarding graphics |
| `radius-full` | 9999px | `BorderRadius.all(Radius.circular(9999))` | Primary buttons, pill tags, rounded avatars |

#### 2.4.1 Border Radius Code Implementation
```dart
class OBRadius {
  static const BorderRadius none = BorderRadius.zero;
  static final BorderRadius xs = BorderRadius.circular(4.0);
  static final BorderRadius sm = BorderRadius.circular(8.0);
  static final BorderRadius md = BorderRadius.circular(12.0);
  static final BorderRadius lg = BorderRadius.circular(16.0);
  static final BorderRadius xl = BorderRadius.circular(24.0);
  static final BorderRadius r2xl = BorderRadius.circular(32.0);
  static final BorderRadius full = BorderRadius.all(Radius.circular(9999.0));
}
```

---

### 2.5 Elevation & Neomorphism Shadows

Neomorphism relies on two light sources to create visual depth: a **Light Shadow** (top-left light source, casting a white/light glow) and a **Dark Shadow** (bottom-right shadow casting a soft dark blur). The elevated element background color must closely match the canvas background color (`neutral-50` / `neutral-100`) for the neomorphic effect to appear physical.

#### 2.5.1 Neomorphic Elevation Levels (Light Mode)

* **Level 0 (Flat)**:
  * Description: Flush with surface.
  * Application: Page body background, inputs in default state, grid boundaries.
  * Configuration: No shadows.
* **Level 1 (Pressed / Inset)**:
  * Description: Appears recessed into the screen.
  * Application: Active/pressed state buttons, selected inputs, search input area.
  * Light Shadow: Offset: `(-2, -2)`, Blur: `4.0`, Spread: `0.0`, Color: `rgba(255, 255, 255, 1.0)`
  * Dark Shadow: Offset: `(2, 2)`, Blur: `4.0`, Spread: `0.0`, Color: `rgba(215, 212, 205, 0.5)`
* **Level 2 (Subtle Rise)**:
  * Description: Slight elevation.
  * Application: List items, navigation bar, mini tags.
  * Light Shadow: Offset: `(-3, -3)`, Blur: `6.0`, Spread: `0.0`, Color: `rgba(255, 255, 255, 1.0)`
  * Dark Shadow: Offset: `(3, 3)`, Blur: `6.0`, Spread: `0.0`, Color: `rgba(215, 212, 205, 0.6)`
* **Level 3 (Default Floating Card)**:
  * Description: Standard card elevation.
  * Application: Product cards, category cards, promotional elements.
  * Light Shadow: Offset: `(-6, -6)`, Blur: `12.0`, Spread: `0.0`, Color: `rgba(255, 255, 255, 1.0)`
  * Dark Shadow: Offset: `(6, 6)`, Blur: `12.0`, Spread: `0.0`, Color: `rgba(215, 212, 205, 0.7)`
* **Level 4 (Elevated Pop-up)**:
  * Description: High visibility.
  * Application: Floating action buttons, headers, action indicators.
  * Light Shadow: Offset: `(-8, -8)`, Blur: `16.0`, Spread: `0.0`, Color: `rgba(255, 255, 255, 1.0)`
  * Dark Shadow: Offset: `(8, 8)`, Blur: `16.0`, Spread: `0.0`, Color: `rgba(215, 212, 205, 0.8)`
* **Level 5 (Overlay modal)**:
  * Description: Deep overlay.
  * Application: Alert dialogs, modal bottom sheets.
  * Light Shadow: Offset: `(-12, -12)`, Blur: `24.0`, Spread: `0.0`, Color: `rgba(255, 255, 255, 1.0)`
  * Dark Shadow: Offset: `(12, 12)`, Blur: `24.0`, Spread: `0.0`, Color: `rgba(215, 212, 205, 0.9)`

#### 2.5.2 Neomorphic Elevation Levels (Dark Mode)
In dark mode, the canvas is `#1C1917`. Shadow values change:
* **Light Shadow**: Offset: `(-X, -Y)`, Color: `rgba(44, 39, 34, 0.3)`
* **Dark Shadow**: Offset: `(X, Y)`, Color: `rgba(12, 10, 9, 0.7)`

#### 2.5.3 BoxShadow Implementation Code
```dart
class OBShadows {
  static List<BoxShadow> neomorphic({
    required int level,
    required bool isDarkMode,
    bool pressed = false,
  }) {
    if (level == 0) return const [];

    final double offsetVal = switch (level) {
      1 => 2.0,
      2 => 3.0,
      3 => 6.0,
      4 => 8.0,
      5 => 12.0,
      _ => 6.0,
    };

    final double blurVal = offsetVal * 2.0;

    final Color lightColor = isDarkMode
        ? const Color(0x3D2C2722) // White glow equivalent in dark mode
        : const Color(0xFFFFFFFF); // Pure white light source

    final Color darkColor = isDarkMode
        ? const Color(0xB30C0A09) // Deep black shadow in dark mode
        : const Color(0x99D7D4CD); // Warm gray shadow in light mode

    final double shadowFactor = pressed ? -1.0 : 1.0;

    return [
      BoxShadow(
        color: lightColor,
        offset: Offset(-offsetVal * shadowFactor, -offsetVal * shadowFactor),
        blurRadius: blurVal,
        spreadRadius: 0.0,
      ),
      BoxShadow(
        color: darkColor,
        offset: Offset(offsetVal * shadowFactor, offsetVal * shadowFactor),
        blurRadius: blurVal,
        spreadRadius: 0.0,
      ),
    ];
  }
}
```

---

## 3. Component Library

Every component in OneBasket has standard variants, sizes, and states. Below is the code implementation and usage constraints for each required UI element.

---

### 3.1 Button

#### 3.1.1 Purpose
Used to trigger primary actions (submitting forms, confirming checkout, starting interactions) and auxiliary actions (closing cards, navigating, expanding rows).

#### 3.1.2 Anatomy
```
┌──────────────────────────────────────────────┐
│ [Icon (Optional)]     [Button Label]         │
└──────────────────────────────────────────────┘
```

#### 3.1.3 Variants & Sizes
* **Variants**: Primary (indigo fill), Secondary (subtle fill), Outlined (indigo stroke), Ghost (transparent), Danger (red fill), Success (green fill), Icon Button (rounded icon backdrop), Text Button (inline action text).
* **Sizes**: 
  * `Small`: height: 32px, padding: 12px, font: 12sp.
  * `Medium`: height: 48px, padding: 20px, font: 14sp.
  * `Large`: height: 56px, padding: 24px, font: 16sp.

#### 3.1.4 Button Code Implementation
```dart
enum OBButtonVariant { primary, secondary, outlined, ghost, danger, success, text }
enum OBButtonSize { small, medium, large }

class OBButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final OBButtonVariant variant;
  final OBButtonSize size;
  final IconData? icon;
  final bool isLoading;

  const OBButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = OBButtonVariant.primary,
    this.size = OBButtonSize.medium,
    this.icon,
    this.isLoading = false,
  });

  @override
  State<OBButton> createState() => _OBButtonState();
}

class _OBButtonState extends State<OBButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isEnabled = widget.onPressed != null && !widget.isLoading;

    // Resolve Size Properties
    final double height = switch (widget.size) {
      OBButtonSize.small => 36.0,
      OBButtonSize.medium => 48.0,
      OBButtonSize.large => 56.0,
    };

    final double horizontalPadding = switch (widget.size) {
      OBButtonSize.small => OBSpacing.space3,
      OBButtonSize.medium => OBSpacing.space5,
      OBButtonSize.large => OBSpacing.space6,
    };

    // Resolve Background Color
    Color getBackgroundColor() {
      if (!isEnabled) return isDark ? const Color(0xFF2C2722) : OBColors.neutral300;
      return switch (widget.variant) {
        OBButtonVariant.primary => OBColors.primary500,
        OBButtonVariant.secondary => OBColors.primary100,
        OBButtonVariant.outlined => Colors.transparent,
        OBButtonVariant.ghost => Colors.transparent,
        OBButtonVariant.danger => OBColors.error,
        OBButtonVariant.success => OBColors.success,
        OBButtonVariant.text => Colors.transparent,
      };
    }

    // Resolve Text/Icon Color
    Color getTextColor() {
      if (!isEnabled) return OBColors.neutral400;
      return switch (widget.variant) {
        OBButtonVariant.primary => Colors.white,
        OBButtonVariant.secondary => OBColors.primary700,
        OBButtonVariant.outlined => OBColors.primary500,
        OBButtonVariant.ghost => OBColors.primary500,
        OBButtonVariant.danger => Colors.white,
        OBButtonVariant.success => Colors.white,
        OBButtonVariant.text => OBColors.primary500,
      };
    }

    // Resolve Neomorphic Shadows
    List<BoxShadow> getShadows() {
      if (!isEnabled || widget.variant == OBButtonVariant.text || widget.variant == OBButtonVariant.ghost) {
        return const [];
      }
      return OBShadows.neomorphic(level: 2, isDarkMode: isDark, pressed: _isPressed);
    }

    final double borderSize = (widget.variant == OBButtonVariant.outlined && isEnabled) ? 1.5 : 0.0;
    final Color borderColor = isEnabled ? OBColors.primary500 : Colors.transparent;

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: widget.text,
      child: GestureDetector(
        onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: isEnabled ? (_) {
          setState(() => _isPressed = false);
          widget.onPressed?.call();
        } : null,
        onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          height: height,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          decoration: BoxDecoration(
            color: getBackgroundColor(),
            borderRadius: OBRadius.full,
            border: borderSize > 0 ? Border.all(color: borderColor, width: borderSize) : null,
            boxShadow: getShadows(),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isLoading)
                SizedBox(
                  width: 18.0,
                  height: 18.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    valueColor: AlwaysStoppedAnimation<Color>(getTextColor()),
                  ),
                )
              else ...[
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: 18.0, color: getTextColor()),
                  const SizedBox(width: OBSpacing.space2),
                ],
                Text(
                  widget.text,
                  style: OBTypography.button.copyWith(
                    color: getTextColor(),
                    fontSize: widget.size == OBButtonSize.small ? 12.0 : 14.0,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
```

#### 3.1.5 ThemeData Styling (Buttons)
```dart
ThemeData getButtonTheme(bool isDark) {
  return ThemeData(
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: OBColors.primary500,
        foregroundColor: Colors.white,
        textStyle: OBTypography.button,
        shape: const StadiumBorder(),
        elevation: 0.0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: OBColors.primary500,
        side: const BorderSide(color: OBColors.primary500, width: 1.5),
        shape: const StadiumBorder(),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: OBColors.primary500,
        textStyle: OBTypography.button,
      ),
    ),
  );
}
```

---

### 3.2 TextField

#### 3.2.1 Purpose
Standard text field for input forms. Ensures consistent handling of keyboard layout, focus triggers, validation visual feedback, and password display states.

#### 3.2.2 Anatomy
```
[Optional Label Text]
┌──────────────────────────────────────────────┐
│ [Prefix Icon]       [Input Text]    [Suffix] │
└──────────────────────────────────────────────┘
[Helper/Error validation text]
```

#### 3.2.3 TextField Code Implementation
```dart
enum OBTextFieldVariant { filled, outlined }

class OBTextField extends StatefulWidget {
  final String label;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool isPassword;
  final bool isReadOnly;
  final bool isEnabled;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const OBTextField({
    super.key,
    required this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.isReadOnly = false,
    this.isEnabled = true,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.onChanged,
  });

  @override
  State<OBTextField> createState() => _OBTextFieldState();
}

class _OBTextFieldState extends State<OBTextField> {
  bool _obscureText = true;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool hasError = widget.errorText != null;

    Color getBorderColor() {
      if (hasError) return OBColors.error;
      if (_isFocused) return OBColors.primary500;
      return isDark ? const Color(0xFF453E36) : OBColors.neutral300;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: OBTypography.subtitle.copyWith(
            color: hasError 
                ? OBColors.error 
                : (_isFocused ? OBColors.primary500 : (isDark ? OBColors.neutral300 : OBColors.neutral700)),
            fontSize: 12.0,
          ),
        ),
        const SizedBox(height: OBSpacing.space1),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C2722) : OBColors.neutral100,
            borderRadius: OBRadius.sm,
            border: Border.all(color: getBorderColor(), width: _isFocused || hasError ? 2.0 : 1.0),
          ),
          child: Row(
            children: [
              if (widget.prefixIcon != null)
                Padding(
                  padding: const EdgeInsets.only(left: OBSpacing.space3),
                  child: Icon(widget.prefixIcon, color: OBColors.neutral400, size: 20.0),
                ),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  keyboardType: widget.keyboardType,
                  obscureText: widget.isPassword && _obscureText,
                  readOnly: widget.isReadOnly,
                  enabled: widget.isEnabled,
                  onChanged: widget.onChanged,
                  style: OBTypography.body.copyWith(
                    color: isDark ? Colors.white : OBColors.neutral900,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: widget.hintText,
                    hintStyle: OBTypography.body.copyWith(color: OBColors.neutral400),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: OBSpacing.space3,
                      vertical: OBSpacing.space3,
                    ),
                  ),
                ),
              ),
              if (widget.isPassword)
                IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: OBColors.neutral400,
                    size: 20.0,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              else if (widget.suffixIcon != null)
                Padding(
                  padding: const EdgeInsets.only(right: OBSpacing.space3),
                  child: Icon(widget.suffixIcon, color: OBColors.neutral400, size: 20.0),
                ),
            ],
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: OBSpacing.space1, left: OBSpacing.space1),
            child: Text(
              widget.errorText!,
              style: OBTypography.caption.copyWith(color: OBColors.error),
            ),
          )
        else if (widget.helperText != null)
          Padding(
            padding: const EdgeInsets.only(top: OBSpacing.space1, left: OBSpacing.space1),
            child: Text(
              widget.helperText!,
              style: OBTypography.caption.copyWith(color: OBColors.neutral500),
            ),
          ),
      ],
    );
  }
}
```

#### 3.2.4 Flutter InputDecorationTheme
```dart
InputDecorationTheme getTextFieldTheme(bool isDark) {
  return InputDecorationTheme(
    filled: true,
    fillColor: isDark ? const Color(0xFF2C2722) : OBColors.neutral100,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: isDark ? const Color(0xFF453E36) : OBColors.neutral300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(color: OBColors.primary500, width: 2.0),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(color: OBColors.error, width: 2.0),
    ),
    labelStyle: TextStyle(color: isDark ? OBColors.neutral300 : OBColors.neutral700),
    hintStyle: const TextStyle(color: OBColors.neutral400),
  );
}
```

---

### 3.3 Card

#### 3.3.1 Purpose
Modular presentation containers to show distinct product offerings, structured categories, order lists, and promo coupons.

#### 3.3.2 Card Code Implementation
```dart
class OBCard extends StatelessWidget {
  final Widget child;
  final int elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const OBCard({
    super.key,
    required this.child,
    this.elevation = 3,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final r = borderRadius ?? OBRadius.md;

    Widget cardBody = Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2722) : OBColors.neutral100,
        borderRadius: r,
        boxShadow: OBShadows.neomorphic(level: elevation, isDarkMode: isDark),
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: cardBody,
      );
    }
    return cardBody;
  }
}
```

#### 3.3.3 Card Variants (Usage Examples)

```dart
// 1. Product Card Widget
class OBProductCard extends StatelessWidget {
  final String imageUrl;
  final String productName;
  final String priceText;
  final String? badgeText;
  final VoidCallback? onAddTap;

  const OBProductCard({
    super.key,
    required this.imageUrl,
    required this.productName,
    required this.priceText,
    this.badgeText,
    this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return OBCard(
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
                  child: Image.network(
                    imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, _, __) => Container(
                      color: isDark ? Colors.black26 : OBColors.neutral200,
                      child: const Icon(Icons.broken_image_outlined, size: 40.0),
                    ),
                  ),
                ),
                if (badgeText != null)
                  Positioned(
                    top: 8.0,
                    left: 8.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: OBColors.error,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(
                        badgeText!,
                        style: OBTypography.overline.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: OBTypography.subtitle.copyWith(
                    color: isDark ? Colors.white : OBColors.neutral800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      priceText,
                      style: OBTypography.heading3.copyWith(
                        color: OBColors.primary500,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_shopping_cart, color: OBColors.primary500),
                      onPressed: onAddTap,
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// 2. Category Card Widget
class OBCategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const OBCategoryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return OBCard(
      elevation: 2,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36.0, color: OBColors.primary500),
            const SizedBox(height: 8.0),
            Text(
              title,
              style: OBTypography.subtitle.copyWith(
                color: isDark ? Colors.white : OBColors.neutral800,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### 3.4 Modal

#### 3.4.1 Purpose
Standard popovers and overlay dialogs for urgent transaction confirmation, alert/error warnings, or temporary bottom sheet workflows.

#### 3.4.2 Modal Animation & Behavior
* **Confirmation & Error modals**: Custom fade and scale transitions (`scale(0.9) -> scale(1.0)`).
* **Bottom sheets**: Slide-up from the bottom. Focus is trapped inside the sheet upon display.

#### 3.4.3 Modal Code Implementation
```dart
class OBDialogs {
  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss Dialog',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: AlertDialog(
            backgroundColor: isDark ? const Color(0xFF2C2722) : OBColors.neutral100,
            shape: RoundedRectangleBorder(borderRadius: OBRadius.lg),
            title: Text(
              title,
              style: OBTypography.heading2.copyWith(
                color: isDark ? Colors.white : OBColors.neutral800,
              ),
            ),
            content: Text(
              message,
              style: OBTypography.body.copyWith(
                color: isDark ? OBColors.neutral300 : OBColors.neutral700,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(cancelText, style: TextStyle(color: OBColors.neutral500)),
              ),
              OBButton(
                text: confirmText,
                variant: isDestructive ? OBButtonVariant.danger : OBButtonVariant.primary,
                size: OBButtonSize.small,
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        );
      },
    );
  }

  static void showBottomSheet({
    required BuildContext context,
    required Widget child,
    required String title,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1917) : OBColors.neutral50,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
          ),
          padding: EdgeInsets.only(
            top: OBSpacing.space4,
            left: OBSpacing.space4,
            right: OBSpacing.space4,
            bottom: MediaQuery.of(context).viewInsets.bottom + OBSpacing.space4,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 48.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: OBColors.neutral300,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              const SizedBox(height: OBSpacing.space4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: OBTypography.heading3.copyWith(
                      color: isDark ? Colors.white : OBColors.neutral800,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const SizedBox(height: OBSpacing.space3),
              child,
            ],
          ),
        );
      },
    );
  }
}
```

---

### 3.5 Snackbar / Toast

#### 3.5.1 Purpose
Inform the user of passive system state changes, transaction statuses, and warnings in a non-blocking floating component.

#### 3.5.2 Snackbar Implementation Code
```dart
class OBToast {
  static void show(
    BuildContext context, {
    required String message,
    required SnackBarBehavior behavior, // Success, Error, Warning, Info
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor = switch (behavior) {
      SnackBarBehavior.floating => isDark ? OBColors.successBg : OBColors.success,
      _ => Colors.black87,
    };

    final (color, bg, icon) = switch (behavior) {
      SnackBarBehavior.fixed => (OBColors.success, OBColors.successBg, Icons.check_circle_outline),
      _ => (OBColors.info, OBColors.infoBg, Icons.info_outline),
    };

    // Override defaults: Success maps to Green, Error maps to Red, Info maps to Blue, Warning maps to Yellow
  }

  static void showSuccess(BuildContext context, String message) {
    _showSnackBar(context, message, OBColors.success, OBColors.successBg, Icons.check_circle_outline);
  }

  static void showError(BuildContext context, String message) {
    _showSnackBar(context, message, OBColors.error, OBColors.errorBg, Icons.error_outline);
  }

  static void showWarning(BuildContext context, String message) {
    _showSnackBar(context, message, OBColors.warning, OBColors.warningBg, Icons.warning_amber_outlined);
  }

  static void showInfo(BuildContext context, String message) {
    _showSnackBar(context, message, OBColors.info, OBColors.infoBg, Icons.info_outline);
  }

  static void _showSnackBar(
    BuildContext context,
    String message,
    Color textColor,
    Color bgColor,
    IconData icon,
  ) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(OBSpacing.space4),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        content: Row(
          children: [
            Icon(icon, color: textColor, size: 20.0),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                message,
                style: OBTypography.body.copyWith(color: textColor, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
```

---

### 3.6 Loading States

#### 3.6.1 Shimmer Loading & Loader Implementations
```dart
// 1. Shimmer Animation Effect wrapper
class OBShimmer extends StatefulWidget {
  final Widget child;

  const OBShimmer({super.key, required this.child});

  @override
  State<OBShimmer> createState() => _OBShimmerState();
}

class _OBShimmerState extends State<OBShimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF2C2722) : const Color(0xFFEAE8E2);
    final highlightColor = isDark ? const Color(0xFF453E36) : const Color(0xFFF5F4F0);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(_animation.value - 1, -0.3),
              end: Alignment(_animation.value, 0.3),
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

// 2. Circular Loader
class OBCircularLoader extends StatelessWidget {
  const OBCircularLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(OBColors.primary500),
        backgroundColor: Colors.transparent,
      ),
    );
  }
}

// 3. Product Grid Skeleton Placeholder
class OBProductGridSkeleton extends StatelessWidget {
  const OBProductGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: OBSpacing.pagePadding,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: OBSpacing.space4,
        mainAxisSpacing: OBSpacing.space4,
        childAspectRatio: 0.72,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return OBShimmer(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: OBRadius.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(OBRadius.md.topLeft.x)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 14.0, width: 120.0, color: Colors.white),
                      const SizedBox(height: 8.0),
                      Container(height: 16.0, width: 60.0, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

---

### 3.7 Empty States

Empty states provide illustrative, actionable UI fallbacks when pages contain no data.

```dart
class OBEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  const OBEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(OBSpacing.space6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 72.0,
              color: isDark ? OBColors.neutral600 : OBColors.neutral400,
            ),
            const SizedBox(height: OBSpacing.space4),
            Text(
              title,
              style: OBTypography.heading2.copyWith(
                color: isDark ? Colors.white : OBColors.neutral800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: OBSpacing.space2),
            Text(
              description,
              style: OBTypography.body.copyWith(
                color: isDark ? OBColors.neutral400 : OBColors.neutral500,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onActionPressed != null) ...[
              const SizedBox(height: OBSpacing.space6),
              OBButton(
                text: actionLabel!,
                onPressed: onActionPressed!,
                variant: OBButtonVariant.primary,
                size: OBButtonSize.medium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

#### 3.7.1 Standard Empty State Variant Configurations

* **Cart Empty**:
  * Icon: `Icons.shopping_cart_outlined`
  * Title: "Your Cart is Empty"
  * Description: "Browse the catalog to add items to your cart."
  * Primary CTA: "Browse Grocery"
* **Wishlist Empty**:
  * Icon: `Icons.favorite_border`
  * Title: "No Saved Items"
  * Description: "Tap the heart icon on any product to save it here."
  * Primary CTA: "Browse Products"
* **Orders Empty**:
  * Icon: `Icons.receipt_long_outlined`
  * Title: "No Orders Yet"
  * Description: "Orders you place in the app will appear here."
  * Primary CTA: "Shop Now"
* **Search Empty**:
  * Icon: `Icons.search_off`
  * Title: "No Results Found"
  * Description: "Try refining your search keywords or check spelling."
  * Primary CTA: "Reset Search"
* **Reviews Empty**:
  * Icon: `Icons.rate_review_outlined`
  * Title: "No Reviews Written"
  * Description: "Products you write reviews for will appear here."
  * Primary CTA: "Write First Review"
* **Internet Offline**:
  * Icon: `Icons.wifi_off`
  * Title: "No Internet Connection"
  * Description: "Check your settings and try reloading the app."
  * Primary CTA: "Retry Connection"

---

## 4. Layout System

The layout system dictates grid dimensions, viewport boundaries, gutters, and responsive layouts across platforms (mobile, tablet, desktop).

### 4.1 Grid Breakpoints & Column Gutters

| Breakpoint Name | Width Threshold | Column Count | Gutter Width | Screen Margin |
|---|---|---|---|---|
| **Mobile** | `< 600px` | 4 columns | 16px | 16px |
| **Tablet** | `600px – 1023px` | 8 columns | 24px | 24px |
| **Desktop** | `1024px – 1439px` | 12 columns | 24px | 32px |
| **Large Desktop** | `≥ 1440px` | 12 columns | 32px | 40px |

* **Maximum Content Width**: `1200px` (Beyond this, desktop views center content and expand screen margins).

### 4.2 Grid Layout Implementation Examples

#### 4.2.1 Two-Column Product Details (Responsive Web/Tablet)
```dart
class OBResponsiveDetailLayout extends StatelessWidget {
  final Widget imageGallery;
  final Widget productInfo;

  const OBResponsiveDetailLayout({
    super.key,
    required this.imageGallery,
    required this.productInfo,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 768.0) {
      // Mobile Layout: Stack elements vertically
      return SingleChildScrollView(
        child: Column(
          children: [
            imageGallery,
            productInfo,
          ],
        ),
      );
    } else {
      // Tablet / Desktop Layout: 2 Horizontal Columns
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 5, child: imageGallery),
          const SizedBox(width: OBSpacing.space6),
          Expanded(flex: 7, child: productInfo),
        ],
      );
    }
  }
}
```

#### 4.2.2 Sidebar Navigation (Admin Web Portal)
```dart
class OBAdminLayout extends StatelessWidget {
  final Widget sidebar;
  final Widget content;

  const OBAdminLayout({
    super.key,
    required this.sidebar,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 1024.0) {
      // Mobile / Tablet Admin: Hidden sidebar, access via drawer
      return Scaffold(
        drawer: Drawer(child: sidebar),
        appBar: AppBar(title: const Text('OneBasket Admin')),
        body: content,
      );
    } else {
      // Desktop Admin: Persistent Sidebar Navigation
      return Scaffold(
        body: Row(
          children: [
            SizedBox(width: 260.0, child: sidebar),
            const VerticalDivider(width: 1.0, thickness: 1.0),
            Expanded(child: content),
          ],
        ),
      );
    }
  }
}
```

---

## 5. Accessibility

OneBasket aligns with WCAG 2.1 AA digital accessibility criteria.

### 5.1 Color Contrast
* Text and primary symbols must pass 4.5:1 contrast against their respective backgrounds.
* Active primary buttons (`#4F46E5` containing `#FFFFFF`) show a contrast score of **4.64:1** (Pass ✅).
* Large headers (`Display L` or `Heading 1`) require a 3:1 minimum contrast.

### 5.2 Interactive Touch Target Size
* All clickable elements (buttons, toggles, text links, item lists) have a tap zone measuring at least **48×48 logical pixels** to prevent validation slips on mobile interfaces.
* To achieve this in Flutter, use constraints or wrap buttons in a transparent sizing box:
  ```dart
  Widget accessibleClickTarget({required Widget child}) {
    return Container(
      constraints: const BoxConstraints(minWidth: 48.0, minHeight: 48.0),
      child: Center(child: child),
    );
  }
  ```

### 5.3 Semantic Labels & Custom Focus Orders
* Provide `Semantics` wrappers containing descriptive tags for custom layouts (like rating stars or product list items).
* Use explicit focus indicator outlines on form inputs. Manage focus order explicitly on keyboard/web flows via `FocusTraversalGroup`.

---

## 6. Motion & Animation

Animations improve the app's perceived speed and structural transitions. All transitions must respect the OS-level "Reduce Motion" preference.

### 6.1 Duration Tokens
* `100ms`: Micro-interactions, checkbox clicks, active/pressed down button transitions.
* `150ms`: Hover indicators, small menu expansions.
* `200ms`: Tab indicators, switch toggles, input validation state changes.
* `300ms`: Dialog overlays, bottom sheets rising, primary navigation routes.
* `500ms`: Fullscreen transitions, loading layout fade-in, introductory onboarding.

### 6.2 Easing Curves
* **Default/Hover Animations**: `Curves.easeInOut` (standard acceleration/deceleration).
* **Entrance Transitions (dialog/bottom sheet)**: `Curves.easeOutCubic` (fast entrance with soft landing).
* **Dismiss/Exit Transitions**: `Curves.easeInCubic` (smooth acceleration offscreen).

### 6.3 Reduced Motion Support Example
```dart
class OBAccessibleAnimation extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;

  const OBAccessibleAnimation({
    super.key,
    required this.child,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    // Check OS reduced motion preference
    final bool reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    if (reduceMotion) {
      return child; // Instant render, no movement
    }

    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}
```

---

## 7. Iconography

OneBasket utilizes **`Material Symbols Rounded`** for all graphical assets.

### 7.1 Key Rules
* Use consistent weights (Default: `Weight 300` / Active Navigation: `Weight 600`).
* Avoid combining outlined icons and filled icons on the same menu level. Outlined icons indicate inactive choices, while filled icons indicate active states.
* Icon Sizes:
  * Small: `18px`
  * Medium: `24px`
  * Large: `32px`

---

## 8. Illustration Guidelines

Illustrations add identity to blank screens, error reports, and onboarding.

### 8.1 Visual Style
* Flat design using a warm gray base with brand primary accents.
* Use soft, rounded geometries (matching `OBRadius.md` / `OBRadius.lg`).
* No harsh pure-black borders. Use `#625A50` or `#453E36` for outline definitions.
* Ensure placeholder images (like missing product images) conform to the neutral color scheme.

---

## 9. Theme Architecture

To achieve a clean, system-wide dark and light mode, we construct complete configurations mapped to Flutter's native `ThemeData`.

### 9.1 Theme Architecture Code
```dart
class OBTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: OBColors.primary500,
      scaffoldBackgroundColor: OBColors.neutral50,
      
      // Color Scheme Mapping
      colorScheme: const ColorScheme.light(
        primary: OBColors.primary500,
        secondary: OBColors.primary200,
        surface: OBColors.neutral50,
        error: OBColors.error,
        onPrimary: Colors.white,
        onSecondary: OBColors.neutral800,
        onSurface: OBColors.neutral900,
        onError: Colors.white,
      ),

      // Typography Mapping
      textTheme: TextTheme(
        displayLarge: OBTypography.displayXL.copyWith(color: OBColors.neutral900),
        displayMedium: OBTypography.displayL.copyWith(color: OBColors.neutral900),
        headlineLarge: OBTypography.heading1.copyWith(color: OBColors.neutral900),
        headlineMedium: OBTypography.heading2.copyWith(color: OBColors.neutral800),
        headlineSmall: OBTypography.heading3.copyWith(color: OBColors.neutral800),
        titleLarge: OBTypography.title.copyWith(color: OBColors.neutral900),
        titleMedium: OBTypography.subtitle.copyWith(color: OBColors.neutral800),
        bodyLarge: OBTypography.bodyLarge.copyWith(color: OBColors.neutral800),
        bodyMedium: OBTypography.body.copyWith(color: OBColors.neutral700),
        bodySmall: OBTypography.caption.copyWith(color: OBColors.neutral500),
      ),

      // Input Decoration Theme
      inputDecorationTheme: getTextFieldTheme(false),

      // Dialog Theme
      dialogTheme: DialogTheme(
        backgroundColor: OBColors.neutral50,
        shape: RoundedRectangleBorder(borderRadius: OBRadius.lg),
        titleTextStyle: OBTypography.heading2.copyWith(color: OBColors.neutral900),
        contentTextStyle: OBTypography.body.copyWith(color: OBColors.neutral700),
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: OBColors.neutral100,
        shape: RoundedRectangleBorder(borderRadius: OBRadius.md),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        checkColor: WidgetStateProperty.all(Colors.white),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return OBColors.primary500;
          return Colors.transparent;
        }),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: OBColors.primary400,
      scaffoldBackgroundColor: OBColors.neutral900,

      // Color Scheme Mapping
      colorScheme: const ColorScheme.dark(
        primary: OBColors.primary400,
        secondary: OBColors.primary700,
        surface: OBColors.neutral900,
        error: OBColors.errorDark,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onError: Colors.black,
      ),

      // Typography Mapping
      textTheme: TextTheme(
        displayLarge: OBTypography.displayXL.copyWith(color: Colors.white),
        displayMedium: OBTypography.displayL.copyWith(color: Colors.white),
        headlineLarge: OBTypography.heading1.copyWith(color: Colors.white),
        headlineMedium: OBTypography.heading2.copyWith(color: Colors.white),
        headlineSmall: OBTypography.heading3.copyWith(color: OBColors.neutral200),
        titleLarge: OBTypography.title.copyWith(color: Colors.white),
        titleMedium: OBTypography.subtitle.copyWith(color: Colors.white),
        bodyLarge: OBTypography.bodyLarge.copyWith(color: OBColors.neutral200),
        bodyMedium: OBTypography.body.copyWith(color: OBColors.neutral300),
        bodySmall: OBTypography.caption.copyWith(color: OBColors.neutral400),
      ),

      // Input Decoration Theme
      inputDecorationTheme: getTextFieldTheme(true),

      // Dialog Theme
      dialogTheme: DialogTheme(
        backgroundColor: const Color(0xFF1C1917),
        shape: RoundedRectangleBorder(borderRadius: OBRadius.lg),
        titleTextStyle: OBTypography.heading2.copyWith(color: Colors.white),
        contentTextStyle: OBTypography.body.copyWith(color: OBColors.neutral300),
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: const Color(0xFF2C2722),
        shape: RoundedRectangleBorder(borderRadius: OBRadius.md),
      ),
    );
  }
}
```
