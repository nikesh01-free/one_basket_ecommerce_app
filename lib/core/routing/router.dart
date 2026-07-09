import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Concrete Screen Imports
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/profile_screen.dart';
import '../../features/auth/presentation/settings_screen.dart';
import '../../features/catalog/presentation/home_screen.dart';
import '../../features/catalog/presentation/categories_screen.dart';
import '../../features/catalog/presentation/product_list_screen.dart';
import '../../features/catalog/presentation/product_detail_screen.dart';
import '../../features/cart/presentation/cart_screen.dart';
import '../../features/wishlist/presentation/wishlist_screen.dart';
import '../../features/checkout/presentation/checkout_screen.dart';
import '../../features/checkout/presentation/order_confirmation_screen.dart';
import '../../features/orders/presentation/orders_list_screen.dart';
import '../../features/orders/presentation/order_detail_screen.dart';
import '../../features/reviews/presentation/reviews_screen.dart';
import '../../features/addresses/presentation/addresses_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';

// Shared shell navigation
import 'placeholder_screens.dart'; // Holds CustomerShellScaffold & Admin Placeholders

final routerProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    routes: [
      // Splash screen
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      // Login & Register
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Customer Main Shell Route
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return CustomerShellScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'product/:id',
                    builder: (context, state) {
                      final id = state.pathParameters['id'] ?? '';
                      return ProductDetailScreen(productId: id);
                    },
                    routes: [
                      GoRoute(
                        path: 'review',
                        builder: (context, state) {
                          final id = state.pathParameters['id'] ?? '';
                          return ReviewsScreen(productId: id);
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'products',
                    builder: (context, state) => const ProductListScreen(),
                  ),
                ],
              ),
            ],
          ),
          // Categories
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/categories',
                builder: (context, state) => const CategoriesScreen(),
              ),
            ],
          ),
          // Cart
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cart',
                builder: (context, state) => const CartScreen(),
                routes: [
                  GoRoute(
                    path: 'checkout',
                    builder: (context, state) => const CheckoutScreen(),
                  ),
                  GoRoute(
                    path: 'confirmation/:orderId',
                    builder: (context, state) {
                      final orderId = state.pathParameters['orderId'] ?? '';
                      return OrderConfirmationScreen(orderId: orderId);
                    },
                  ),
                ],
              ),
            ],
          ),
          // Wishlist
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/wishlist',
                builder: (context, state) => const WishlistScreen(),
              ),
            ],
          ),
          // Profile/Account
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'orders',
                    builder: (context, state) => const OrdersListScreen(),
                  ),
                  GoRoute(
                    path: 'order/:orderId',
                    builder: (context, state) {
                      final orderId = state.pathParameters['orderId'] ?? '';
                      return OrderDetailScreen(orderId: orderId);
                    },
                  ),
                  GoRoute(
                    path: 'addresses',
                    builder: (context, state) => const AddressesScreen(),
                  ),
                  GoRoute(
                    path: 'settings',
                    builder: (context, state) => const SettingsScreen(),
                  ),
                  GoRoute(
                    path: 'notifications',
                    builder: (context, state) => const NotificationsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // Admin portal routes
      GoRoute(
        path: '/admin/login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/products',
        builder: (context, state) => const AdminProductsScreen(),
      ),
      GoRoute(
        path: '/admin/orders',
        builder: (context, state) => const AdminOrdersScreen(),
      ),
      GoRoute(
        path: '/admin/coupons',
        builder: (context, state) => const AdminCouponsScreen(),
      ),
    ],
  );
});
