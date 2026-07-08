import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'placeholder_screens.dart';

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
