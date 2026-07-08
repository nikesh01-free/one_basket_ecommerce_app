import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../theme/radius.dart';
import '../theme/shadows.dart';

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

// 1. Product Card Widget
class OBProductCard extends StatelessWidget {
  final String imageUrl;
  final String productName;
  final String priceText;
  final String? badgeText;
  final VoidCallback? onTap;
  final VoidCallback? onAddTap;

  const OBProductCard({
    super.key,
    required this.imageUrl,
    required this.productName,
    required this.priceText,
    this.badgeText,
    this.onTap,
    this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return OBCard(
      elevation: 3,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: isDark ? const Color(0xFF242426) : OBColors.neutral200,
                        child: const Center(
                          child: SizedBox(
                            width: 24.0,
                            height: 24.0,
                            child: CircularProgressIndicator(strokeWidth: 2.0),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: isDark ? Colors.black26 : OBColors.neutral200,
                        child: const Icon(Icons.broken_image_outlined, size: 40.0),
                      ),
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
              mainAxisSize: MainAxisSize.min,
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
