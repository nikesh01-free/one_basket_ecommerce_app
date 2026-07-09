import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/colors.dart';
import '../theme/shadows.dart';

// Admin Screens placeholder definitions

// Admin Screens
class AdminLoginScreen extends StatelessWidget {
  const AdminLoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Admin Login Screen')),
    );
  }
}

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Admin Dashboard Screen')),
    );
  }
}

class AdminProductsScreen extends StatelessWidget {
  const AdminProductsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Admin Products Screen')),
    );
  }
}

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Admin Orders Screen')),
    );
  }
}

class AdminCouponsScreen extends StatelessWidget {
  const AdminCouponsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Admin Coupons Screen')),
    );
  }
}

// Shell Scaffolding for bottom bar navigation
class CustomerShellScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const CustomerShellScaffold({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true, // Let screens draw behind the rounded floating navigation bar
      body: navigationShell,
      bottomNavigationBar: Container(
        height: 72.0,
        margin: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2722) : OBColors.neutral100,
          borderRadius: BorderRadius.circular(24.0),
          boxShadow: OBShadows.neomorphic(level: 3, isDarkMode: isDark),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, 0, Icons.home_outlined, Icons.home),
              _buildNavItem(context, 1, Icons.grid_view_outlined, Icons.grid_view),
              _buildNavItem(context, 2, Icons.shopping_cart_outlined, Icons.shopping_cart),
              _buildNavItem(context, 3, Icons.favorite_border, Icons.favorite),
              _buildNavItem(context, 4, Icons.person_outline, Icons.person),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData icon,
    IconData activeIcon,
  ) {
    final bool isSelected = navigationShell.currentIndex == index;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF1C1917) : OBColors.neutral200)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: isSelected
              ? OBShadows.neomorphic(level: 1, isDarkMode: isDark, pressed: true)
              : null,
        ),
        child: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected
              ? OBColors.primary500
              : (isDark ? OBColors.neutral400 : OBColors.neutral500),
          size: 24.0,
        ),
      ),
    );
  }
}
