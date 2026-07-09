import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'wishlist_provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/cards.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final wishlist = ref.watch(wishlistProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wishlist'),
      ),
      body: wishlist.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(OBSpacing.space6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.favorite_border,
                      size: 80.0,
                      color: OBColors.neutral400,
                    ),
                    const SizedBox(height: OBSpacing.space4),
                    Text(
                      'Your wishlist is empty',
                      style: OBTypography.heading2.copyWith(
                        color: isDark ? Colors.white : OBColors.neutral800,
                      ),
                    ),
                    const SizedBox(height: OBSpacing.space2),
                    Text(
                      'Tap the heart icon on any product page to save it for later.',
                      style: OBTypography.body.copyWith(color: OBColors.neutral500),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: OBSpacing.space6),
                    OBButton(
                      text: 'Go to Catalog',
                      onPressed: () => context.go('/home'),
                    ),
                  ],
                ),
              ),
            )
          : GridView.builder(
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
                childAspectRatio: 0.65,
              ),
              itemCount: wishlist.length,
              itemBuilder: (context, index) {
                final item = wishlist[index];
                final product = item.product;
                final variant = product.variants.isNotEmpty ? product.variants.first : null;
                final isOutOfStock = variant == null || variant.stockQty == 0;

                return OBCard(
                  elevation: 2,
                  onTap: () {
                    context.push('/home/product/${product.id}');
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Product Image Thumbnail
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
                          child: Container(
                            color: isDark ? Colors.black26 : OBColors.neutral200,
                            child: product.primaryImageUrl != null
                                ? Image.network(
                                    product.primaryImageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image_outlined),
                                  )
                                : const Icon(Icons.image),
                          ),
                        ),
                      ),

                      // Details
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
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
                                  variant != null ? '₹${variant.price}' : '',
                                  style: OBTypography.body.copyWith(
                                    color: OBColors.primary500,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 18.0),
                                  onPressed: () {
                                    ref.read(wishlistProvider.notifier).toggleWishlist(product.id);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            OBButton(
                              text: isOutOfStock ? 'Out of Stock' : 'Move to Cart',
                              size: OBButtonSize.small,
                              variant: OBButtonVariant.primary,
                              onPressed: isOutOfStock
                                  ? null
                                  : () async {
                                      await ref.read(wishlistProvider.notifier).moveToCart(item, variant.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('${product.name} moved to cart!')),
                                      );
                                    },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
