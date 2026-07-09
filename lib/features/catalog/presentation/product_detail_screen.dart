import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'catalog_provider.dart';
import '../../cart/presentation/cart_provider.dart';
import '../../wishlist/presentation/wishlist_provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/widgets/buttons.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _selectedVariantIndex = 0;
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final productsAsync = ref.watch(productsFutureProvider);
    final wishlist = ref.watch(wishlistProvider);

    final Color backgroundColor = isDark ? const Color(0xFF181818) : const Color(0xFFF7F8FA);
    final Color surfaceColor = isDark ? const Color(0xFF242424) : const Color(0xFFFBFBFC);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: productsAsync.when(
        data: (products) {
          final productIndex = products.indexWhere((p) => p.id == widget.productId);
          if (productIndex < 0) {
            return _ProductNotFoundView(isDark: isDark, surfaceColor: surfaceColor, onBack: () => context.pop());
          }
          final product = products[productIndex];
          final variant = product.variants.isNotEmpty ? product.variants[_selectedVariantIndex] : null;
          final isOutOfStock = variant == null || variant.stockQty == 0;
          final isWishlisted = wishlist.any((item) => item.product.id == widget.productId);

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // ---- Floating Transparent App Bar ----
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0.0,
                    pinned: false,
                    floating: true,
                    leading: GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        margin: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: surfaceColor.withValues(alpha: 0.90),
                          shape: BoxShape.circle,
                          boxShadow: OBShadows.neomorphic(level: 2, isDarkMode: isDark),
                        ),
                        child: Icon(Icons.arrow_back, size: 20.0, color: isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                    actions: [
                      // Wishlist button
                      GestureDetector(
                        onTap: () => ref.read(wishlistProvider.notifier).toggleWishlist(widget.productId),
                        child: Container(
                          margin: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: surfaceColor.withValues(alpha: 0.90),
                            shape: BoxShape.circle,
                            boxShadow: OBShadows.neomorphic(level: 2, isDarkMode: isDark),
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              isWishlisted ? Icons.favorite : Icons.favorite_border,
                              key: ValueKey(isWishlisted),
                              size: 20.0,
                              color: isWishlisted ? const Color(0xFFEF4444) : OBColors.neutral500,
                            ),
                          ),
                        ),
                      ),
                      // Share button
                      Container(
                        margin: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 12.0, left: 8.0),
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: surfaceColor.withValues(alpha: 0.90),
                          shape: BoxShape.circle,
                          boxShadow: OBShadows.neomorphic(level: 2, isDarkMode: isDark),
                        ),
                        child: Icon(Icons.share_outlined, size: 20.0, color: isDark ? Colors.white70 : Colors.black54),
                      ),
                    ],
                  ),

                  // ---- Hero Product Image Gallery ----
                  SliverToBoxAdapter(
                    child: ProductGallery(
                      imageUrl: product.primaryImageUrl,
                      isDark: isDark,
                      surfaceColor: surfaceColor,
                    ),
                  ),

                  // ---- Scrollable Content ----
                  SliverPadding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      top: 0.0,
                      bottom: 160.0,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // 1. Product Name + Rating Card
                        FloatingProductCard(
                          productName: product.name,
                          isDark: isDark,
                          surfaceColor: surfaceColor,
                        ),
                        const SizedBox(height: 16.0),

                        // 2. Price Section
                        if (variant != null) ...[
                          PriceCard(
                            price: variant.price,
                            isDark: isDark,
                            surfaceColor: surfaceColor,
                          ),
                          const SizedBox(height: 16.0),
                        ],

                        // 3. Delivery Info Card
                        PDPDeliveryInfoCard(
                          isDark: isDark,
                          surfaceColor: surfaceColor,
                        ),
                        const SizedBox(height: 16.0),

                        // 4. Variant Selection
                        if (product.variants.isNotEmpty) ...[
                          const Text(
                            'Select Variant',
                            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12.0),
                          VariantSelector(
                            variants: product.variants,
                            selectedIndex: _selectedVariantIndex,
                            isDark: isDark,
                            surfaceColor: surfaceColor,
                            onSelect: (index) {
                              setState(() {
                                _selectedVariantIndex = index;
                                _quantity = 1; // Reset quantity on variant change
                              });
                            },
                          ),
                          const SizedBox(height: 16.0),
                        ],

                        // 5. Product Highlights
                        ProductHighlights(isDark: isDark, surfaceColor: surfaceColor),
                        const SizedBox(height: 16.0),

                        // 6. Description
                        ExpandableDescription(
                          description: product.description ?? 'No description available for this product.',
                          isDark: isDark,
                          surfaceColor: surfaceColor,
                        ),
                        const SizedBox(height: 16.0),

                        // 7. Reviews Section
                        ReviewsSection(isDark: isDark, surfaceColor: surfaceColor),
                      ]),
                    ),
                  ),
                ],
              ),

              // ---- Sticky Bottom Purchase Bar ----
              Positioned(
                bottom: kBottomNavigationBarHeight, // sit above the bottom nav bar
                left: 0.0,
                right: 0.0,
                child: StickyPurchaseBar(
                  variant: variant,
                  quantity: _quantity,
                  isOutOfStock: isOutOfStock,
                  productName: product.name,
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  onDecrement: () {
                    if (_quantity > 1) setState(() => _quantity--);
                  },
                  onIncrement: () {
                    if (variant != null && _quantity < variant.stockQty) setState(() => _quantity++);
                  },
                  onAddToCart: variant == null
                      ? null
                      : () {
                          ref.read(cartProvider.notifier).addToCart(variant.id, _quantity);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.name} added to cart!'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                  onBuyNow: variant == null
                      ? null
                      : () {
                          ref.read(cartProvider.notifier).addToCart(variant.id, _quantity);
                          context.push('/cart/checkout');
                        },
                ),
              ),
            ],
          );
        },
        loading: () => ProductSkeletonLoader(isDark: isDark, surfaceColor: surfaceColor),
        error: (err, stack) => _ProductErrorView(
          errorMessage: err.toString(),
          isDark: isDark,
          surfaceColor: surfaceColor,
          onRetry: () => ref.invalidate(productsFutureProvider),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Reusable Product Detail Components
// ──────────────────────────────────────────────────────────────────────────────

// 1. Hero Image Gallery Viewer
class ProductGallery extends StatelessWidget {
  final String? imageUrl;
  final bool isDark;
  final Color surfaceColor;

  const ProductGallery({
    super.key,
    this.imageUrl,
    required this.isDark,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height * 0.42;

    return Container(
      height: height,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1917) : OBColors.neutral100,
        borderRadius: BorderRadius.circular(28.0),
        boxShadow: OBShadows.neomorphic(level: 3, isDarkMode: isDark),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28.0),
        child: Stack(
          children: [
            // Product Image
            SizedBox.expand(
              child: imageUrl != null
                  ? Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (ctx, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: isDark ? const Color(0xFF1C1917) : OBColors.neutral200,
                        );
                      },
                      errorBuilder: (c, o, s) => const Center(
                        child: Icon(Icons.broken_image_outlined, size: 72.0, color: OBColors.neutral400),
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.image_outlined, size: 72.0, color: OBColors.neutral400),
                    ),
            ),
            // Freshness badge
            Positioned(
              top: 14.0,
              left: 14.0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: const Text(
                  '🌿 Farm Fresh',
                  style: TextStyle(fontSize: 11.0, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            // Page dot indicator (single image placeholder)
            Positioned(
              bottom: 14.0,
              left: 0.0,
              right: 0.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 20.0,
                    height: 4.0,
                    decoration: BoxDecoration(
                      color: OBColors.primary500,
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                  const SizedBox(width: 4.0),
                  Container(
                    width: 6.0,
                    height: 4.0,
                    decoration: BoxDecoration(
                      color: Colors.white54,
                      borderRadius: BorderRadius.circular(2.0),
                    ),
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

// 2. Floating Product Info Card
class FloatingProductCard extends StatelessWidget {
  final String productName;
  final bool isDark;
  final Color surfaceColor;

  const FloatingProductCard({
    super.key,
    required this.productName,
    required this.isDark,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: OBShadows.neomorphic(level: 3, isDarkMode: isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Verified badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Text(
                  '✓ Verified Seller',
                  style: TextStyle(fontSize: 10.0, fontWeight: FontWeight.bold, color: Color(0xFF22C55E)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                decoration: BoxDecoration(
                  color: OBColors.primary500.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Text(
                  '⚡ 15 MINS',
                  style: TextStyle(fontSize: 10.0, fontWeight: FontWeight.bold, color: OBColors.primary500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          // Product name
          Text(
            productName,
            style: const TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.4,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10.0),
          // Rating row
          Row(
            children: [
              Row(
                children: List.generate(5, (i) => Icon(
                  i < 4 ? Icons.star_rounded : Icons.star_half_rounded,
                  color: const Color(0xFFF59E0B),
                  size: 16.0,
                )),
              ),
              const SizedBox(width: 6.0),
              const Text(
                '4.5',
                style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 4.0),
              const Text(
                '(248 reviews)',
                style: TextStyle(fontSize: 12.0, color: OBColors.neutral500),
              ),
              const Spacer(),
              const Icon(Icons.people_outline, size: 14.0, color: OBColors.neutral400),
              const SizedBox(width: 4.0),
              const Text(
                '34 viewing',
                style: TextStyle(fontSize: 11.0, color: OBColors.neutral500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 3. Premium Price Card
class PriceCard extends StatelessWidget {
  final double price;
  final bool isDark;
  final Color surfaceColor;

  const PriceCard({
    super.key,
    required this.price,
    required this.isDark,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    final double originalPrice = price * 1.18; // simulate MRP
    final double saving = originalPrice - price;
    final int discountPct = ((saving / originalPrice) * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: OBShadows.neomorphic(level: 3, isDarkMode: isDark),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '₹${price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                    color: OBColors.primary500,
                  ),
                ),
                const SizedBox(height: 2.0),
                Row(
                  children: [
                    Text(
                      'MRP ₹${originalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: OBColors.neutral400,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      'Save ₹${saving.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF22C55E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2.0),
                const Text(
                  'Inclusive of all taxes',
                  style: TextStyle(fontSize: 10.5, color: OBColors.neutral400),
                ),
              ],
            ),
          ),
          // Discount badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14.0),
            ),
            child: Text(
              '$discountPct% OFF',
              style: const TextStyle(
                fontSize: 13.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFFEF4444),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 4. PDP Delivery Info Card
class PDPDeliveryInfoCard extends StatelessWidget {
  final bool isDark;
  final Color surfaceColor;

  const PDPDeliveryInfoCard({
    super.key,
    required this.isDark,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: OBShadows.neomorphic(level: 2, isDarkMode: isDark),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: OBColors.primary500.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on_outlined, color: OBColors.primary500, size: 18.0),
          ),
          const SizedBox(width: 12.0),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Deliver to Ahmedabad',
                  style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2.0),
                Text(
                  '15–20 mins • FREE Delivery on orders above ₹200',
                  style: TextStyle(fontSize: 11.5, color: OBColors.neutral500),
                ),
              ],
            ),
          ),
          const Text(
            'Change',
            style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold, color: OBColors.primary500),
          ),
        ],
      ),
    );
  }
}

// 5. Variant Selector Cards
class VariantSelector extends StatelessWidget {
  final List<dynamic> variants;
  final int selectedIndex;
  final bool isDark;
  final Color surfaceColor;
  final ValueChanged<int> onSelect;

  const VariantSelector({
    super.key,
    required this.variants,
    required this.selectedIndex,
    required this.isDark,
    required this.surfaceColor,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10.0,
      runSpacing: 10.0,
      children: List.generate(variants.length, (index) {
        final v = variants[index];
        final bool isSelected = index == selectedIndex;
        final bool outOfStock = v.stockQty == 0;

        return GestureDetector(
          onTap: outOfStock ? null : () => onSelect(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: isSelected ? OBColors.primary500.withValues(alpha: 0.10) : surfaceColor,
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(
                color: isSelected ? OBColors.primary500 : (isDark ? Colors.white12 : OBColors.neutral200),
                width: isSelected ? 2.0 : 1.0,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: OBColors.primary500.withValues(alpha: 0.15), blurRadius: 8.0, offset: const Offset(0, 2))]
                  : OBShadows.neomorphic(level: 1, isDarkMode: isDark),
            ),
            child: Column(
              children: [
                Text(
                  v.name,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? OBColors.primary500 : (outOfStock ? OBColors.neutral400 : null),
                    decoration: outOfStock ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (outOfStock)
                  const Text(
                    'Out of Stock',
                    style: TextStyle(fontSize: 9.0, color: OBColors.error),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// 6. Product Highlights Card
class ProductHighlights extends StatelessWidget {
  final bool isDark;
  final Color surfaceColor;

  const ProductHighlights({
    super.key,
    required this.isDark,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: OBShadows.neomorphic(level: 2, isDarkMode: isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Why You\'ll Love It',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12.0),
          const Row(
            children: [
              Expanded(child: _HighlightItem(emoji: '🌿', label: '100% Fresh')),
              Expanded(child: _HighlightItem(emoji: '🚚', label: '15 Min Delivery')),
            ],
          ),
          const SizedBox(height: 8.0),
          const Row(
            children: [
              Expanded(child: _HighlightItem(emoji: '❄', label: 'Cold Stored')),
              Expanded(child: _HighlightItem(emoji: '♻', label: 'Eco Packing')),
            ],
          ),
        ],
      ),
    );
  }
}

class _HighlightItem extends StatelessWidget {
  final String emoji;
  final String label;

  const _HighlightItem({required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18.0)),
        const SizedBox(width: 6.0),
        Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// 7. Expandable Description Card
class ExpandableDescription extends StatefulWidget {
  final String description;
  final bool isDark;
  final Color surfaceColor;

  const ExpandableDescription({
    super.key,
    required this.description,
    required this.isDark,
    required this.surfaceColor,
  });

  @override
  State<ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<ExpandableDescription> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: widget.surfaceColor,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: OBShadows.neomorphic(level: 2, isDarkMode: widget.isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product Description',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10.0),
          AnimatedCrossFade(
            firstChild: Text(
              widget.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14.0, color: OBColors.neutral500, height: 1.5),
            ),
            secondChild: Text(
              widget.description,
              style: const TextStyle(fontSize: 14.0, color: OBColors.neutral500, height: 1.5),
            ),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
          const SizedBox(height: 8.0),
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Text(
              _isExpanded ? 'Show Less ↑' : 'Read More ↓',
              style: const TextStyle(
                fontSize: 13.0,
                fontWeight: FontWeight.bold,
                color: OBColors.primary500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 8. Reviews Section Card
class ReviewsSection extends StatelessWidget {
  final bool isDark;
  final Color surfaceColor;

  const ReviewsSection({
    super.key,
    required this.isDark,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: OBShadows.neomorphic(level: 2, isDarkMode: isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Customer Reviews', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600)),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 16.0),
                  const SizedBox(width: 4.0),
                  const Text('4.5', style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14.0),
          // Sample review cards
          _buildReviewCard(isDark, surfaceColor, 'Ramesh Patel', 4, '2 days ago',
              'Very fresh and fast delivery! Highly recommended for grocery shoppers in Ahmedabad.'),
          const SizedBox(height: 10.0),
          _buildReviewCard(isDark, surfaceColor, 'Priya Shah', 5, '1 week ago',
              'Loved the quality! Will definitely order again. Packaging was perfect.'),
        ],
      ),
    );
  }

  Widget _buildReviewCard(bool isDark, Color surfaceColor, String name, int stars, String time, String text) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1917) : OBColors.neutral100,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: OBShadows.neomorphic(level: 1, isDarkMode: isDark, pressed: true),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 14.0,
                    backgroundColor: OBColors.primary500.withValues(alpha: 0.15),
                    child: Text(
                      name[0],
                      style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold, color: OBColors.primary500),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Text(name, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 6.0),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E).withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: const Text('✓ Verified', style: TextStyle(fontSize: 8.5, color: Color(0xFF22C55E), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              Text(time, style: const TextStyle(fontSize: 11.0, color: OBColors.neutral400)),
            ],
          ),
          const SizedBox(height: 6.0),
          Row(
            children: List.generate(5, (i) => Icon(
              i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
              color: const Color(0xFFF59E0B),
              size: 13.0,
            )),
          ),
          const SizedBox(height: 6.0),
          Text(text, style: const TextStyle(fontSize: 13.0, color: OBColors.neutral500, height: 1.4)),
        ],
      ),
    );
  }
}

// 9. Sticky Purchase Bottom Bar
class StickyPurchaseBar extends StatelessWidget {
  final dynamic variant;
  final int quantity;
  final bool isOutOfStock;
  final String productName;
  final bool isDark;
  final Color surfaceColor;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback? onAddToCart;
  final VoidCallback? onBuyNow;

  const StickyPurchaseBar({
    super.key,
    required this.variant,
    required this.quantity,
    required this.isOutOfStock,
    required this.productName,
    required this.isDark,
    required this.surfaceColor,
    required this.onDecrement,
    required this.onIncrement,
    required this.onAddToCart,
    required this.onBuyNow,
  });

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0 + bottomInset),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.06),
            blurRadius: 20.0,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isOutOfStock && variant != null) ...[
            // Quantity row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Quantity',
                  style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                ),
                Container(
                  height: 36.0,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1C1917) : OBColors.neutral100,
                    borderRadius: BorderRadius.circular(18.0),
                    boxShadow: OBShadows.neomorphic(level: 1, isDarkMode: isDark, pressed: true),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: onDecrement,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.0),
                          child: Icon(Icons.remove, size: 16.0),
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
                        child: Text(
                          '$quantity',
                          key: ValueKey(quantity),
                          style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                      GestureDetector(
                        onTap: onIncrement,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.0),
                          child: Icon(Icons.add, size: 16.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
          ],
          // Action Buttons
          if (isOutOfStock)
            SizedBox(
              width: double.infinity,
              child: OBButton(
                text: 'Notify When Available',
                onPressed: null,
                size: OBButtonSize.large,
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OBButton(
                    text: 'Add to Cart',
                    variant: OBButtonVariant.secondary,
                    onPressed: onAddToCart,
                    size: OBButtonSize.large,
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: OBButton(
                    text: 'Buy Now',
                    variant: OBButtonVariant.primary,
                    onPressed: onBuyNow,
                    size: OBButtonSize.large,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// 10. Product Skeleton Loader
class ProductSkeletonLoader extends StatelessWidget {
  final bool isDark;
  final Color surfaceColor;

  const ProductSkeletonLoader({
    super.key,
    required this.isDark,
    required this.surfaceColor,
  });

  Widget _bone(double width, double height) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.only(bottom: 6.0),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : OBColors.neutral200,
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Image skeleton
          Container(
            height: screenHeight * 0.42,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : OBColors.neutral200,
              borderRadius: BorderRadius.circular(28.0),
            ),
          ),
          const SizedBox(height: 16.0),
          _bone(double.infinity, 28.0),
          _bone(180.0, 18.0),
          _bone(120.0, 14.0),
          const SizedBox(height: 12.0),
          _bone(double.infinity, 90.0),
          const SizedBox(height: 12.0),
          _bone(double.infinity, 60.0),
        ],
      ),
    );
  }
}

// ── Internal Error/NotFound views ────────────────────────────────────────────

class _ProductNotFoundView extends StatelessWidget {
  final bool isDark;
  final Color surfaceColor;
  final VoidCallback onBack;

  const _ProductNotFoundView({required this.isDark, required this.surfaceColor, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(24.0),
            boxShadow: OBShadows.neomorphic(level: 3, isDarkMode: isDark),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off_outlined, size: 64.0, color: OBColors.neutral400),
              const SizedBox(height: 16.0),
              const Text('Product Not Found', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8.0),
              const Text(
                'The product you are looking for is unavailable or has been removed.',
                textAlign: TextAlign.center,
                style: TextStyle(color: OBColors.neutral500),
              ),
              const SizedBox(height: 20.0),
              OBButton(text: 'Go Back', onPressed: onBack, size: OBButtonSize.medium),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductErrorView extends StatelessWidget {
  final String errorMessage;
  final bool isDark;
  final Color surfaceColor;
  final VoidCallback onRetry;

  const _ProductErrorView({
    required this.errorMessage,
    required this.isDark,
    required this.surfaceColor,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(24.0),
            boxShadow: OBShadows.neomorphic(level: 3, isDarkMode: isDark),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64.0, color: OBColors.error),
              const SizedBox(height: 16.0),
              const Text('Failed to Load Product', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8.0),
              Text(errorMessage, textAlign: TextAlign.center, style: const TextStyle(color: OBColors.neutral500)),
              const SizedBox(height: 20.0),
              OBButton(text: 'Retry', onPressed: onRetry, size: OBButtonSize.medium),
            ],
          ),
        ),
      ),
    );
  }
}
