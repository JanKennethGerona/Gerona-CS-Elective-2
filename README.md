# Bricked — LEGO Shop Browser
**CS Elective 2: Mobile Application Development — Prelim Exam**

An e-commerce Flutter application centering on a premium LEGO product browsing experience. Demonstrates Core Widgets, Navigation 2.0 (`go_router`), Stateless vs. Stateful Widgets, Design Theming, and Responsive & Adaptive Design.

---

## 1. User Flow

```
Home (Product Grid) ──> Product Detail ──> Add to Cart ──> Cart ──> Checkout Confirmation
```

- **Home Screen (`/`)**: Displays all collector LEGO sets in a responsive grid. Includes a light/dark mode toggle and live cart badge in the AppBar.
- **Product Detail Screen (`/product/:id`)**: Reached via Navigation 2.0 with deep linking. Shows detailed specifications (price, piece count, set #, age, description) and interactive "Add to Cart" button.
- **Cart Screen (`/cart`)**: Lists added items with subtotals, stateful `+`/`-` quantity controls, empty cart state, and live running total.
- **Checkout Confirmation Screen (`/checkout`)**: Route-guarded final screen showing itemized order summary, subtotals, grand total, and confirmation message.

---

## 2. Stateless vs. Stateful Justification

| Widget | Type | Justification |
|---|---|---|
| `ProductCard` | **StatelessWidget** | Renders static product information; never changes after initial build. |
| `ProductGrid` | **StatelessWidget** | Computes column count via `LayoutBuilder` based on parent constraints without local mutable state. |
| `ProductDetailScreen` | **StatelessWidget** | Displays static product details; mutations are delegated to `CartModel`. |
| `CartItemTile` | **StatelessWidget** | Pure presentation of an item row in the cart; delegates modifications to `CartModel`. |
| `QuantitySelector` | **StatefulWidget** | Manages local button interaction states and provides immediate visual feedback during `+`/`-` taps before updating the cart. |
| `AddToCartButton` | **StatefulWidget** | Manages local animated confirmation feedback (*"Added to Cart!"* with checkmark) before reverting to standard state. |
| `BrickedApp` | **StatefulWidget** | Initializes and preserves the `GoRouter` instance across rebuilds. |
| `CartModel` / `ThemeModel` | **ChangeNotifier** | Cross-screen mutable shared state managed via `provider`. |

---

## 3. Design Theming & Color Palette

The color scheme is directly inspired by official LEGO branding:

| Color | Hex | Role |
|---|---|---|
| **Lego Red** | `#C8102E` | Primary brand color, light mode AppBar |
| **Lego Yellow** | `#FFD500` | Brand accent, dark mode primary accents & buttons |
| **Lego Orange** | `#FFA300` | Secondary accent, primary action buttons |
| **Lego Blue** | `#004B93` | Tertiary accent |
| **Dark Navy** | `#0E3A5F` | Dark theme background and surfaces |

- **Material 3 Theming**: Single `ThemeData` applied at the `MaterialApp` level. Zero hardcoded colors inside individual widget files.
- **Light/Dark Mode Toggle**: Working toggle button in the AppBar that instantly transitions the entire app between light and dark modes.

---

## 4. Responsive Design

`ProductGrid` uses `LayoutBuilder` to adapt column counts based on screen width:
- **Phone (< 600 dp)**: 2 columns
- **Tablet (600 dp – 950 dp)**: 3 columns
- **Desktop / Wide Screen (≥ 950 dp)**: 4 columns

---

## 5. Navigation 2.0 & Route Guard

Configured using `go_router`:
- `/`: `HomeScreen`
- `/product/:id`: `ProductDetailScreen`
- `/cart`: `CartScreen`
- `/checkout`: `CheckoutConfirmationScreen`
- **Route Guard**: Direct navigation to `/checkout` is blocked if the cart is empty (`cartModel.isEmpty`), automatically redirecting the user to `/cart`.

---

## 6. Getting Started

### Prerequisites
- Flutter SDK (≥ 3.12.0)
- Dart SDK

### Installation
```bash
flutter pub get
```

### Run Analysis & Tests
```bash
# Run static analyzer (0 issues)
flutter analyze

# Run unit and widget test suite (all tests passing)
flutter test
```

### Run the App
```bash
flutter run
```
