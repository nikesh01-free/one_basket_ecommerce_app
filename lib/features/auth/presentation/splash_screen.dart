import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/shadows.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  // Staggered animation triggers
  bool _showBackground = false;
  bool _showLogo = false;
  bool _showFloating = false;
  bool _showText = false;
  bool _showLoader = false;

  @override
  void initState() {
    super.initState();
    _startAnimationSequence();
    _navigateToNext();
  }

  void _startAnimationSequence() {
    // 0ms: background fades in
    Future.delayed(Duration.zero, () {
      if (mounted) setState(() => _showBackground = true);
    });
    // 300ms: logo scales in
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _showLogo = true);
    });
    // 700ms: floating elements move in
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _showFloating = true);
    });
    // 1200ms: text titles slide up
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _showText = true);
    });
    // 1600ms: loading dot pulse shows up
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _showLoader = true);
    });
  }

  Future<void> _navigateToNext() async {
    // Artificial splash delay of 1800ms
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    final user = ref.read(authProvider);
    if (user != null) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SplashBackground(
        visible: _showBackground,
        isDark: isDark,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Center Logo block and Floating icons
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 240.0,
                    height: 240.0,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Floating surrounding items (Leaf, Fruits, Bag)
                        FloatingElements(
                          visible: _showFloating,
                          isDark: isDark,
                        ),
                        // Soft neomorphic center logo container
                        AnimatedLogo(
                          visible: _showLogo,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10.0),

                  // Brand name and subtitle
                  BrandTitle(
                    visible: _showText,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 32.0),

                  // Subtle pulsing dots loader
                  PremiumLoader(
                    visible: _showLoader,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------
// Reusable Splash Components
// --------------------------------------------------------------------

// 1. Splash Background with soft gradients
class SplashBackground extends StatelessWidget {
  final bool visible;
  final bool isDark;
  final Widget child;

  const SplashBackground({
    super.key,
    required this.visible,
    required this.isDark,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = isDark ? const Color(0xFF181818) : const Color(0xFFF7F8FA);
    
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: visible ? 1.0 : 0.0,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: bgColor,
          gradient: RadialGradient(
            colors: [
              isDark ? const Color(0xFF222222) : const Color(0xFFFFFFFF),
              bgColor,
            ],
            radius: 1.2,
            center: Alignment.center,
          ),
        ),
        child: Stack(
          children: [
            // Decorative background neomorphic blobs (Nothing OS / Apple visual)
            Positioned(
              top: -60.0,
              left: -60.0,
              child: _buildBlob(180.0, isDark),
            ),
            Positioned(
              bottom: -80.0,
              right: -80.0,
              child: _buildBlob(240.0, isDark),
            ),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildBlob(double size, bool isDark) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            OBColors.primary500.withValues(alpha: isDark ? 0.06 : 0.03),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

// 2. Center Animated Neomorphic Logo Container
class AnimatedLogo extends StatelessWidget {
  final bool visible;
  final bool isDark;

  const AnimatedLogo({
    super.key,
    required this.visible,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 600),
      scale: visible ? 1.0 : 0.75,
      curve: Curves.elasticOut,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        opacity: visible ? 1.0 : 0.0,
        child: Container(
          width: 110.0,
          height: 110.0,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C2722) : OBColors.neutral100,
            borderRadius: BorderRadius.circular(28.0),
            boxShadow: OBShadows.neomorphic(level: 3, isDarkMode: isDark),
          ),
          child: const Center(
            child: Icon(
              Icons.shopping_basket_outlined,
              size: 52.0,
              color: OBColors.primary500,
            ),
          ),
        ),
      ),
    );
  }
}

// 3. Floating Surrounding Grocery Elements
class FloatingElements extends StatelessWidget {
  final bool visible;
  final bool isDark;

  const FloatingElements({
    super.key,
    required this.visible,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Leaf (Top Right)
        AnimatedPositioned(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          top: visible ? 20.0 : 50.0,
          right: visible ? 20.0 : 50.0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 400),
            opacity: visible ? 1.0 : 0.0,
            child: _buildItem(Icons.spa_outlined, const Color(0xFF22C55E)),
          ),
        ),
        // Fruit (Bottom Left)
        AnimatedPositioned(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          bottom: visible ? 20.0 : 50.0,
          left: visible ? 20.0 : 50.0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 400),
            opacity: visible ? 1.0 : 0.0,
            child: _buildItem(Icons.apple_outlined, const Color(0xFFEF4444)),
          ),
        ),
        // Delivery Pin (Top Left)
        AnimatedPositioned(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          top: visible ? 24.0 : 50.0,
          left: visible ? 24.0 : 50.0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 400),
            opacity: visible ? 1.0 : 0.0,
            child: _buildItem(Icons.location_on_outlined, OBColors.primary500),
          ),
        ),
      ],
    );
  }

  Widget _buildItem(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF242424) : Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(icon, size: 16.0, color: color),
    );
  }
}

// 4. Brand Name & Subtitle
class BrandTitle extends StatelessWidget {
  final bool visible;
  final bool isDark;

  const BrandTitle({
    super.key,
    required this.visible,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final Color mutedColor = isDark ? const Color(0xFFBDBDBD) : const Color(0xFF6B7280);

    return AnimatedPadding(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(top: visible ? 0.0 : 20.0),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        opacity: visible ? 1.0 : 0.0,
        child: Column(
          children: [
            Text(
              'OneBasket',
              style: TextStyle(
                fontSize: 40.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: textColor,
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              'Fresh groceries delivered in minutes',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                color: mutedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 5. Apple-style pulsing dots loader
class PremiumLoader extends StatelessWidget {
  final bool visible;
  final bool isDark;

  const PremiumLoader({
    super.key,
    required this.visible,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: visible ? 1.0 : 0.0,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _LoadingDot(delayMs: 0),
          SizedBox(width: 6.0),
          _LoadingDot(delayMs: 150),
          SizedBox(width: 6.0),
          _LoadingDot(delayMs: 300),
        ],
      ),
    );
  }
}

// Loading dot with self-repeating breathing scale
class _LoadingDot extends StatefulWidget {
  final int delayMs;

  const _LoadingDot({required this.delayMs});

  @override
  State<_LoadingDot> createState() => _LoadingDotState();
}

class _LoadingDotState extends State<_LoadingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scale = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Stagger start using artificial delay
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (context, child) {
        return Transform.scale(
          scale: _scale.value,
          child: child,
        );
      },
      child: Container(
        width: 6.0,
        height: 6.0,
        decoration: const BoxDecoration(
          color: OBColors.primary500,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
