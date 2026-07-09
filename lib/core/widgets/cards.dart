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
class OBProductCard extends StatefulWidget {
  final String imageUrl;
  final String productName;
  final String priceText;
  final String? badgeText;
  final VoidCallback? onTap;
  final VoidCallback? onAddTap;
  final VoidCallback? onRemoveTap;
  final int cartQuantity;
  final bool isWishlisted;
  final VoidCallback? onWishlistTap;
  final String storeName;
  final String deliveryTime;
  final String stockStatus;
  final double rating;

  const OBProductCard({
    super.key,
    required this.imageUrl,
    required this.productName,
    required this.priceText,
    this.badgeText,
    this.onTap,
    this.onAddTap,
    this.onRemoveTap,
    this.cartQuantity = 0,
    this.isWishlisted = false,
    this.onWishlistTap,
    this.storeName = 'Fresh Organic Store',
    this.deliveryTime = '⏱ 10 mins',
    this.stockStatus = 'In Stock',
    this.rating = 4.8,
  });

  @override
  State<OBProductCard> createState() => _OBProductCardState();
}

class _OBProductCardState extends State<OBProductCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Parse price to create a mock strikethrough MRP (e.g. sale price + 25%)
    double parsedPrice = 0.0;
    try {
      final cleanedPrice = widget.priceText.replaceAll('₹', '').trim();
      parsedPrice = double.tryParse(cleanedPrice) ?? 0.0;
    } catch (_) {}
    
    final double mockMrp = parsedPrice > 0 ? (parsedPrice * 1.25) : 0.0;
    final double savings = mockMrp - parsedPrice;
    final bool isOutOfStock = widget.stockStatus.toLowerCase().contains('out');

    // Tactile Neomorphic Shadows (pure neomorphism)
    final cardShadows = OBShadows.neomorphic(
      level: 3,
      isDarkMode: isDark,
      pressed: _isPressed,
    );

    // Determine stock color
    Color getStockColor() {
      if (isOutOfStock) return OBColors.error;
      if (widget.stockStatus.toLowerCase().contains('only')) return Colors.orange;
      return OBColors.neutral500;
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0.0, _isPressed ? 2.0 : 0.0, 0.0),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C2722) : OBColors.neutral100,
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: cardShadows,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image and Floating elements Stack
              Expanded(
                child: Stack(
                  children: [
                    // Product Image (Breathing space with 8px inset)
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                          child: Container(
                            color: isDark ? const Color(0xFF252528) : OBColors.neutral100,
                            child: widget.imageUrl.isNotEmpty
                                ? AnimatedScale(
                                    scale: _isPressed ? 1.04 : 1.0,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOutCubic,
                                    child: CachedNetworkImage(
                                      imageUrl: widget.imageUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: isDark ? const Color(0xFF242426) : OBColors.neutral200,
                                        child: const Center(
                                          child: SizedBox(
                                            width: 20.0,
                                            height: 20.0,
                                            child: CircularProgressIndicator(strokeWidth: 2.0),
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: isDark 
                                                ? [const Color(0xFF3E2D20), const Color(0xFF2C1E15)] 
                                                : [OBColors.primary100, Colors.white],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                        ),
                                        child: const Icon(Icons.restaurant_menu, size: 36.0, color: OBColors.primary500),
                                      ),
                                    ),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: isDark 
                                            ? [const Color(0xFF3E2D20), const Color(0xFF2C1E15)] 
                                            : [OBColors.primary100, Colors.white],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: const Icon(Icons.restaurant_menu, size: 36.0, color: OBColors.primary500),
                                  ),
                          ),
                        ),
                      ),
                    ),

                    // Floating Discount tag (Top Left)
                    if (widget.badgeText != null)
                      Positioned(
                        top: 14.0,
                        left: 14.0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: OBColors.error,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Text(
                            widget.badgeText!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                    else if (parsedPrice > 0 && savings > 0)
                      Positioned(
                        top: 14.0,
                        left: 14.0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: OBColors.success,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: const Text(
                            '20% OFF',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                    // Floating Glassmorphism Wishlist Heart (Top Right)
                    Positioned(
                      top: 14.0,
                      right: 14.0,
                      child: GestureDetector(
                        onTap: widget.onWishlistTap,
                        child: Container(
                          width: 32.0,
                          height: 32.0,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.black45 : Colors.white.withValues(alpha: 0.85),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? Colors.white10 : Colors.white60,
                              width: 1.0,
                            ),
                          ),
                          child: Center(
                            child: TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 1.0, end: widget.isWishlisted ? 1.2 : 1.0),
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOutBack,
                              builder: (context, val, child) {
                                return Transform.scale(
                                  scale: val,
                                  child: Icon(
                                    widget.isWishlisted ? Icons.favorite : Icons.favorite_border,
                                    color: widget.isWishlisted ? OBColors.error : (isDark ? Colors.white : OBColors.neutral600),
                                    size: 16.0,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Floating Rating Badge (Below Heart)
                    Positioned(
                      top: 52.0,
                      right: 14.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1C1917) : Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: isDark ? Colors.white10 : OBColors.neutral200,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 10.0),
                            const SizedBox(width: 2.0),
                            Text(
                              widget.rating.toStringAsFixed(1),
                              style: TextStyle(
                                color: isDark ? Colors.white : OBColors.neutral800,
                                fontSize: 10.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Content Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Product Title (Max 2 lines, Bold 700)
                    SizedBox(
                      height: 38.0,
                      child: Text(
                        widget.productName,
                        style: OBTypography.body.copyWith(
                          color: isDark ? Colors.white : OBColors.neutral800,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.0,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4.0),

                    // Store Name (Small gray text)
                    Text(
                      widget.storeName,
                      style: OBTypography.caption.copyWith(
                        color: OBColors.neutral500,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2.0),

                    // Delivery Time
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_filled,
                          size: 11.0,
                          color: isDark ? OBColors.neutral400 : OBColors.neutral500,
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          widget.deliveryTime,
                          style: OBTypography.caption.copyWith(
                            color: isDark ? OBColors.neutral400 : OBColors.neutral500,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),

                    // Price Section & Quick Add Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Price displays
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Text(
                                  widget.priceText,
                                  key: ValueKey<String>(widget.priceText),
                                  style: OBTypography.subtitle.copyWith(
                                    color: OBColors.primary500,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16.5,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  if (mockMrp > 0)
                                    Text(
                                      '₹${mockMrp.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        color: OBColors.neutral400,
                                        decoration: TextDecoration.lineThrough,
                                        fontSize: 11.0,
                                      ),
                                    ),
                                  if (savings > 0) ...[
                                    const SizedBox(width: 4.0),
                                    Text(
                                      'Save ₹${savings.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        color: OBColors.success,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 9.5,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Quick Add Button/Stepper morphing
                        SizedBox(
                          height: 32.0,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return ScaleTransition(scale: child.key == const ValueKey('stepper') 
                                  ? animation 
                                  : Tween<double>(begin: 0.95, end: 1.0).animate(animation), 
                                child: FadeTransition(opacity: animation, child: child));
                            },
                            child: isOutOfStock
                                ? const SizedBox()
                                : widget.cartQuantity == 0
                                    ? GestureDetector(
                                        key: const ValueKey('add_btn'),
                                        onTap: widget.onAddTap,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14.0),
                                          decoration: BoxDecoration(
                                            color: isDark ? const Color(0xFF2C2722) : Colors.white,
                                            borderRadius: BorderRadius.circular(14.0),
                                            border: Border.all(
                                              color: OBColors.primary500.withValues(alpha: 0.4),
                                              width: 1.0,
                                            ),
                                            boxShadow: OBShadows.neomorphic(
                                              level: 1,
                                              isDarkMode: isDark,
                                              pressed: false,
                                            ),
                                          ),
                                          child: const Center(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  'ADD',
                                                  style: TextStyle(
                                                    color: OBColors.primary500,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 11.5,
                                                  ),
                                                ),
                                                SizedBox(width: 4.0),
                                                Icon(
                                                  Icons.add,
                                                  size: 11.5,
                                                  color: OBColors.primary500,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(
                                        key: const ValueKey('stepper'),
                                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                        decoration: BoxDecoration(
                                          color: OBColors.primary500,
                                          borderRadius: BorderRadius.circular(14.0),
                                          boxShadow: OBShadows.neomorphic(
                                            level: 1,
                                            isDarkMode: isDark,
                                            pressed: false,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            GestureDetector(
                                              onTap: widget.onRemoveTap,
                                              child: const Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                                                child: Icon(Icons.remove, size: 13.0, color: Colors.white),
                                              ),
                                            ),
                                            Text(
                                              '${widget.cartQuantity}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11.5,
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: widget.onAddTap,
                                              child: const Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                                                child: Icon(Icons.add, size: 13.0, color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6.0),

                    // Stock Status Indicator
                    Text(
                      widget.stockStatus,
                      style: TextStyle(
                        color: getStockColor(),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
