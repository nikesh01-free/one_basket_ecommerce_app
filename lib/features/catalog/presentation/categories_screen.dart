import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'catalog_provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/widgets/buttons.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesFutureProvider);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Neomorphic backgrounds
    final Color backgroundColor = isDark ? const Color(0xFF181818) : const Color(0xFFF7F8FA);
    final Color surfaceColor = isDark ? const Color(0xFF242424) : const Color(0xFFFBFBFC);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Floating Custom Glassmorphic App Bar
            CategoriesHeader(
              isDark: isDark,
              surfaceColor: surfaceColor,
              onBackTap: () => context.pop(),
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(categoriesFutureProvider);
                },
                child: ListView(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    top: 12.0,
                    bottom: 120.0, // extra padding for bottom navigation
                  ),
                  children: [
                    // 2. Hero Header Banner
                    const HeroBanner(),
                    const SizedBox(height: 16.0),

                    // 3. Search Bar
                    SearchBar(
                      hintText: 'Search categories...',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 24.0),

                    // 4. Featured horizontal scroll categories list
                    const Text(
                      'Featured Today',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    const FeaturedCategoriesRow(),
                    const SizedBox(height: 24.0),

                    // 5. Main Categories Grid Section
                    const Text(
                      'All Categories',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    categoriesAsync.when(
                      data: (categories) {
                        if (categories.isEmpty) {
                          return EmptyCategoryView(
                            surfaceColor: surfaceColor,
                            isDark: isDark,
                            onRetry: () => ref.invalidate(categoriesFutureProvider),
                          );
                        }
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16.0,
                            mainAxisSpacing: 16.0,
                            childAspectRatio: 0.95,
                          ),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            // Mock product count numbers dynamically
                            final int mockProductCount = 80 + (category.name.length * 4);

                            return PremiumCategoryCard(
                              imageUrl: category.imageUrl,
                              title: category.name,
                              productCount: mockProductCount,
                              surfaceColor: surfaceColor,
                              isDark: isDark,
                              onTap: () {
                                ref.read(selectedCategoryIdProvider.notifier).state = category.id;
                                context.push('/home/products');
                              },
                            );
                          },
                        );
                      },
                      loading: () => SkeletonCategoryGrid(isDark: isDark, surfaceColor: surfaceColor),
                      error: (err, stack) => ErrorCategoryView(
                        errorMessage: err.toString(),
                        isDark: isDark,
                        surfaceColor: surfaceColor,
                        onRetry: () => ref.invalidate(categoriesFutureProvider),
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // 6. Popular / Trending Carousel
                    const Text(
                      'Trending This Week',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    const TrendingCategoryCarousel(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------
// Reusable Categories Components
// --------------------------------------------------------------------

// 1. Categories Header custom App Bar
class CategoriesHeader extends StatelessWidget {
  final bool isDark;
  final Color surfaceColor;
  final VoidCallback onBackTap;

  const CategoriesHeader({
    super.key,
    required this.isDark,
    required this.surfaceColor,
    required this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24.0)),
        boxShadow: OBShadows.neomorphic(level: 2, isDarkMode: isDark),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onBackTap,
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1C1917) : OBColors.neutral100,
                    shape: BoxShape.circle,
                    boxShadow: OBShadows.neomorphic(level: 1, isDarkMode: isDark),
                  ),
                  child: Icon(Icons.arrow_back, size: 20.0, color: isDark ? Colors.white : Colors.black),
                ),
              ),
              const SizedBox(width: 14.0),
              const Text(
                'Categories',
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1917) : OBColors.neutral100,
              shape: BoxShape.circle,
              boxShadow: OBShadows.neomorphic(level: 1, isDarkMode: isDark),
            ),
            child: const Icon(Icons.filter_list_outlined, color: OBColors.primary500, size: 20.0),
          ),
        ],
      ),
    );
  }
}

// 2. Hero banner title plate
class HeroBanner extends StatelessWidget {
  const HeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What are you shopping for today?',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'Browse fresh groceries by category',
            style: TextStyle(
              fontSize: 13.5,
              color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

// 3. Search Bar Widget
class SearchBar extends StatelessWidget {
  final String hintText;
  final bool isDark;

  const SearchBar({
    super.key,
    required this.hintText,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52.0,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1917) : OBColors.neutral100,
        borderRadius: BorderRadius.circular(26.0),
        boxShadow: OBShadows.neomorphic(level: 2, isDarkMode: isDark, pressed: true),
        border: Border.all(
          color: isDark ? Colors.white10 : OBColors.neutral200,
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_outlined, color: OBColors.neutral400, size: 22.0),
          const SizedBox(width: 10.0),
          Expanded(
            child: Text(
              hintText,
              style: const TextStyle(
                fontSize: 14.0,
                color: OBColors.neutral400,
              ),
            ),
          ),
          Icon(
            Icons.mic_none_outlined,
            color: isDark ? Colors.white38 : OBColors.neutral500,
            size: 20.0,
          ),
        ],
      ),
    );
  }
}

// 4. Featured category horizontal chips row
class FeaturedCategoriesRow extends StatelessWidget {
  const FeaturedCategoriesRow({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardBg = isDark ? const Color(0xFF242424) : const Color(0xFFFBFBFC);

    return SizedBox(
      height: 84.0,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildChip('🥬 Vegetables', '140+ Items', cardBg, isDark),
          _buildChip('🍎 Fruits', '80+ Items', cardBg, isDark),
          _buildChip('🥛 Dairy & Milk', '50+ Items', cardBg, isDark),
          _buildChip('🍞 Bakery', '64+ Items', cardBg, isDark),
          _buildChip('🥤 Beverages', '110+ Items', cardBg, isDark),
        ],
      ),
    );
  }

  Widget _buildChip(String label, String count, Color cardBg, bool isDark) {
    return Container(
      width: 120.0,
      margin: const EdgeInsets.only(right: 12.0, bottom: 4.0),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18.0),
        boxShadow: OBShadows.neomorphic(level: 2, isDarkMode: isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4.0),
          Text(
            count,
            style: const TextStyle(fontSize: 10.0, color: OBColors.neutral500),
          ),
        ],
      ),
    );
  }
}

// 5. Premium Category Card Widget
class PremiumCategoryCard extends StatefulWidget {
  final String? imageUrl;
  final String title;
  final int productCount;
  final Color surfaceColor;
  final bool isDark;
  final VoidCallback onTap;

  const PremiumCategoryCard({
    super.key,
    this.imageUrl,
    required this.title,
    required this.productCount,
    required this.surfaceColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<PremiumCategoryCard> createState() => _PremiumCategoryCardState();
}

class _PremiumCategoryCardState extends State<PremiumCategoryCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          decoration: BoxDecoration(
            color: widget.surfaceColor,
            borderRadius: BorderRadius.circular(24.0),
            boxShadow: OBShadows.neomorphic(
              level: 2,
              isDarkMode: widget.isDark,
              pressed: _isPressed,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image frame
              Container(
                width: 72.0,
                height: 72.0,
                decoration: BoxDecoration(
                  color: widget.isDark ? const Color(0xFF1C1917) : OBColors.neutral100,
                  shape: BoxShape.circle,
                  boxShadow: OBShadows.neomorphic(level: 1, isDarkMode: widget.isDark, pressed: true),
                ),
                child: ClipOval(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: widget.imageUrl != null
                        ? Image.network(
                            widget.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (c, o, s) => const Icon(Icons.category_outlined, color: OBColors.primary500, size: 28.0),
                          )
                        : const Icon(Icons.category_outlined, color: OBColors.primary500, size: 28.0),
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              Text(
                widget.title.split(' & ').first,
                style: const TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2.0),
              Text(
                '${widget.productCount} Products',
                style: const TextStyle(fontSize: 11.0, color: OBColors.neutral500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 6. Popular / Trending categories horizontal carousel
class TrendingCategoryCarousel extends StatelessWidget {
  const TrendingCategoryCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardBg = isDark ? const Color(0xFF242424) : const Color(0xFFFBFBFC);

    return SizedBox(
      height: 94.0,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildTrendingCard('🌽 Organic Staples', 'High Demand', cardBg, isDark),
          _buildTrendingCard('🥚 Eggs & Broth', 'Top Pick', cardBg, isDark),
          _buildTrendingCard('🍪 Sweet Biscuits', 'Best Seller', cardBg, isDark),
          _buildTrendingCard('🧴 Hand Wash', 'Fresh Stock', cardBg, isDark),
        ],
      ),
    );
  }

  Widget _buildTrendingCard(String label, String badge, Color cardBg, bool isDark) {
    return Container(
      width: 140.0,
      margin: const EdgeInsets.only(right: 14.0, bottom: 4.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: OBShadows.neomorphic(level: 2, isDarkMode: isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
            decoration: BoxDecoration(
              color: OBColors.successBg,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              badge,
              style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: OBColors.success),
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            label,
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// 7. Loading Shimmer Skeletons
class SkeletonCategoryGrid extends StatelessWidget {
  final bool isDark;
  final Color surfaceColor;

  const SkeletonCategoryGrid({
    super.key,
    required this.isDark,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 0.95,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(24.0),
            boxShadow: OBShadows.neomorphic(level: 1, isDarkMode: isDark),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72.0,
                height: 72.0,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : OBColors.neutral200,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 12.0),
              Container(
                width: 80.0,
                height: 12.0,
                color: isDark ? Colors.white10 : OBColors.neutral200,
              ),
              const SizedBox(height: 6.0),
              Container(
                width: 40.0,
                height: 8.0,
                color: isDark ? Colors.white10 : OBColors.neutral200,
              ),
            ],
          ),
        );
      },
    );
  }
}

// 8. Empty Category View panel
class EmptyCategoryView extends StatelessWidget {
  final Color surfaceColor;
  final bool isDark;
  final VoidCallback onRetry;

  const EmptyCategoryView({
    super.key,
    required this.surfaceColor,
    required this.isDark,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: OBShadows.neomorphic(level: 3, isDarkMode: isDark),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1917) : OBColors.neutral100,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off_outlined, size: 64.0, color: OBColors.primary500),
          ),
          const SizedBox(height: 20.0),
          const Text(
            'No Categories Found',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          const Text(
            'We couldn\'t load shopping categories. Check your internet connection.',
            style: TextStyle(fontSize: 13.0, color: OBColors.neutral500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20.0),
          OBButton(
            text: 'Retry Load',
            onPressed: onRetry,
            size: OBButtonSize.medium,
          ),
        ],
      ),
    );
  }
}

// 9. Error view panel
class ErrorCategoryView extends StatelessWidget {
  final String errorMessage;
  final bool isDark;
  final Color surfaceColor;
  final VoidCallback onRetry;

  const ErrorCategoryView({
    super.key,
    required this.errorMessage,
    required this.isDark,
    required this.surfaceColor,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: OBShadows.neomorphic(level: 3, isDarkMode: isDark),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 48.0, color: OBColors.error),
          const SizedBox(height: 16.0),
          const Text(
            'Failed to Load Categories',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6.0),
          Text(
            errorMessage,
            style: const TextStyle(fontSize: 12.0, color: OBColors.neutral500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20.0),
          OBButton(
            text: 'Retry Load',
            onPressed: onRetry,
            size: OBButtonSize.medium,
          ),
        ],
      ),
    );
  }
}
