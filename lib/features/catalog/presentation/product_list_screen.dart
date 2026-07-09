import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'catalog_provider.dart';
import '../../cart/presentation/cart_provider.dart';
import '../../wishlist/presentation/wishlist_provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/radius.dart';
import '../../../core/widgets/cards.dart';
import '../../../core/widgets/text_fields.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  void _showFilterBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1C1917)
          : OBColors.neutral50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(OBRadius.lg.topLeft.x))),
      builder: (context) {
        return const FilterSheetContent();
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final productsAsync = ref.watch(filteredProductsFutureProvider);
    final categoryId = ref.watch(selectedCategoryIdProvider);
    final categoriesAsync = ref.watch(categoriesFutureProvider);
    final cart = ref.watch(cartProvider);
    final wishlist = ref.watch(wishlistProvider);

    String categoryTitle = 'All Products';
    if (categoryId != null && categoriesAsync.hasValue) {
      final match = categoriesAsync.value!.firstWhere((c) => c.id == categoryId);
      categoryTitle = match.name;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Reset category and search filters when leaving listing
            ref.read(selectedCategoryIdProvider.notifier).state = null;
            ref.read(searchQueryProvider.notifier).state = '';
            context.pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => _showFilterBottomSheet(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: OBSpacing.space4, vertical: OBSpacing.space2),
            child: OBSearchField(
              hintText: 'Search products in $categoryTitle...',
              onChanged: (val) {
                ref.read(searchQueryProvider.notifier).state = val;
              },
            ),
          ),
          Expanded(
            child: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(OBSpacing.space4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search_off_outlined, size: 72.0, color: OBColors.neutral400),
                    const SizedBox(height: OBSpacing.space4),
                    Text(
                      'No Products Found',
                      style: OBTypography.heading2.copyWith(color: isDark ? Colors.white : OBColors.neutral800),
                    ),
                    const SizedBox(height: OBSpacing.space2),
                    const Text('Try adjusting your filters or search terms.'),
                  ],
                ),
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.only(
              left: OBSpacing.space4,
              right: OBSpacing.space4,
              top: OBSpacing.space3,
              bottom: 100.0,
            ),
             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
               crossAxisCount: 2,
               crossAxisSpacing: OBSpacing.space3,
               mainAxisSpacing: OBSpacing.space3,
               childAspectRatio: 0.61,
             ),
             itemCount: products.length,
             itemBuilder: (context, index) {
               final product = products[index];
               final variant = product.variants.isNotEmpty ? product.variants.first : null;

               // Cart quantities and items checking
               final cartItem = (variant != null && cart.items.any((item) => item.variant.id == variant.id))
                   ? cart.items.firstWhere((item) => item.variant.id == variant.id)
                   : null;
               final int cartQty = cartItem?.quantity ?? 0;

               // Wishlist checking
               final bool isWishlisted = wishlist.any((item) => item.product.id == product.id);

               // Stock indicator string
               final String stockStatus = variant == null || variant.stockQty == 0
                   ? 'Out of Stock'
                   : (variant.stockQty <= 5 ? 'Only ${variant.stockQty} left' : 'In Stock');

               // Rating calculation
               final double mockRating = 4.0 + ((product.name.length % 10) / 10.0);

               return OBProductCard(
                 imageUrl: product.primaryImageUrl ?? '',
                 productName: product.name,
                 priceText: variant != null ? '₹${variant.price}' : '',
                 badgeText: variant == null || variant.stockQty == 0 ? 'OUT OF STOCK' : null,
                 cartQuantity: cartQty,
                 isWishlisted: isWishlisted,
                 stockStatus: stockStatus,
                 rating: mockRating,
                 storeName: 'Amdavadi Organic Hub',
                 deliveryTime: '⏱ 15 mins',
                 onTap: () {
                   context.push('/home/product/${product.id}');
                 },
                 onWishlistTap: () {
                   ref.read(wishlistProvider.notifier).toggleWishlist(product.id);
                 },
                 onAddTap: () {
                   if (variant != null && variant.stockQty > 0) {
                     if (cartQty == 0) {
                       ref.read(cartProvider.notifier).addToCart(variant.id, 1);
                     } else if (cartQty < variant.stockQty) {
                       ref.read(cartProvider.notifier).updateQuantity(cartItem!.id, cartQty + 1);
                     }
                   }
                 },
                 onRemoveTap: () {
                   if (cartItem != null) {
                     if (cartQty > 1) {
                       ref.read(cartProvider.notifier).updateQuantity(cartItem.id, cartQty - 1);
                     } else {
                       ref.read(cartProvider.notifier).removeFromCart(cartItem.id);
                     }
                   }
                 },
               );
             },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
          ),
        ],
      ),
    );
  }
}

// Interactive filter sheet content
class FilterSheetContent extends ConsumerWidget {
  const FilterSheetContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maxPrice = ref.watch(priceRangeProvider) ?? 1000.0;
    final sortBy = ref.watch(sortByProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(OBSpacing.space4),
      height: 380.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sort & Filter', style: OBTypography.heading2.copyWith(color: isDark ? Colors.white : OBColors.neutral800)),
          const SizedBox(height: OBSpacing.space4),

          // Price range slider
          Text('Max Price: ₹${maxPrice.toInt()}', style: OBTypography.subtitle.copyWith(color: isDark ? Colors.white : OBColors.neutral700)),
          Slider(
            min: 0.0,
            max: 1000.0,
            divisions: 10,
            activeColor: OBColors.primary500,
            value: maxPrice,
            onChanged: (val) {
              ref.read(priceRangeProvider.notifier).state = val;
            },
          ),
          const SizedBox(height: OBSpacing.space4),

          // Sorting choices
          Text('Sort By', style: OBTypography.subtitle.copyWith(color: isDark ? Colors.white : OBColors.neutral700)),
          const SizedBox(height: OBSpacing.space2),
          Wrap(
            spacing: OBSpacing.space3,
            children: [
              FilterChip(
                label: const Text('Newest'),
                selected: sortBy == 'newest',
                onSelected: (val) {
                  ref.read(sortByProvider.notifier).state = 'newest';
                },
              ),
              FilterChip(
                label: const Text('Price: Low to High'),
                selected: sortBy == 'price_asc',
                onSelected: (val) {
                  ref.read(sortByProvider.notifier).state = 'price_asc';
                },
              ),
              FilterChip(
                label: const Text('Price: High to Low'),
                selected: sortBy == 'price_desc',
                onSelected: (val) {
                  ref.read(sortByProvider.notifier).state = 'price_desc';
                },
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(priceRangeProvider.notifier).state = null;
                    ref.read(sortByProvider.notifier).state = 'newest';
                    Navigator.pop(context);
                  },
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: OBSpacing.space3),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OBColors.primary500,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
