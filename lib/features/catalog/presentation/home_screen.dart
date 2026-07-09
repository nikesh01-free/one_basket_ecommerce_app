import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'catalog_provider.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../cart/presentation/cart_provider.dart';
import '../../wishlist/presentation/wishlist_provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/widgets/cards.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late PageController _bannerController;
  int _activeBannerIndex = 0;
  Timer? _bannerTimer;

  // Mock Promo Banners
  final List<Map<String, String>> _banners = [
    {
      'title': 'Ahmedabad Hyperlocal Express 🚚',
      'subtitle': 'Groceries delivered in under 45 minutes.',
      'badge': 'SUPER FAST',
      'colors': 'orange_gold'
    },
    {
      'title': 'Get Flat ₹50 Off on first order! 🎉',
      'subtitle': 'Use code WELCOME50 at checkout. Min ₹200.',
      'badge': 'WELCOME OFFER',
      'colors': 'green_emerald'
    },
    {
      'title': 'Local Farm Fresh Specials 🌽',
      'subtitle': 'Directly sourced from rural Gujarat farms.',
      'badge': '100% ORGANIC',
      'colors': 'blue_indigo'
    },
  ];

  // Deals countdown state
  Duration _timeLeft = const Duration(hours: 2, minutes: 14, seconds: 45);
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _bannerController = PageController(initialPage: 0);
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_bannerController.hasClients) {
        setState(() {
          _activeBannerIndex = (_activeBannerIndex + 1) % _banners.length;
        });
        _bannerController.animateToPage(
          _activeBannerIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft.inSeconds > 0) {
        setState(() {
          _timeLeft = _timeLeft - const Duration(seconds: 1);
        });
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => d.inSeconds <= 0 ? '00' : n.toString().padLeft(2, '0');
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider);
    final categoriesAsync = ref.watch(categoriesFutureProvider);
    final productsAsync = ref.watch(productsFutureProvider);
    final cart = ref.watch(cartProvider);
    final wishlist = ref.watch(wishlistProvider);

    // Color Theme settings
    final Color backgroundColor = isDark ? const Color(0xFF181818) : const Color(0xFFF7F8FA);
    final Color surfaceColor = isDark ? const Color(0xFF242424) : const Color(0xFFFBFBFC);

    // Calculate cart totals for FloatingCartBar
    final double cartTotal = cart.items.fold(0.0, (sum, item) => sum + (item.variant.price * item.quantity));
    final int cartItemsCount = cart.items.fold(0, (sum, item) => sum + item.quantity);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(categoriesFutureProvider);
                ref.invalidate(productsFutureProvider);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 10.0,
                  bottom: 140.0, // extra padding for sticky cart bar & navigation
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Hero Header Card
                    HomeHeader(
                      userName: user?.fullName ?? 'Guest',
                      surfaceColor: surfaceColor,
                      isDark: isDark,
                      onNotificationTap: () => context.push('/profile/notifications'),
                    ),
                    const SizedBox(height: 16.0),

                    // 2. Neomorphic Search Input Bar
                    HomeSearchBar(
                      hintText: 'Search fresh milk, rice, cow ghee...',
                      isDark: isDark,
                      surfaceColor: surfaceColor,
                      onTap: () => context.push('/home/products'),
                    ),
                    const SizedBox(height: 20.0),

                    // 3. Quick Services Showcase (Groceries, Veggies, Fruits etc.)
                    const QuickServicesRow(),
                    const SizedBox(height: 20.0),

                    // 4. Promo Carousel Banner
                    PromoCarousel(
                      banners: _banners,
                      bannerController: _bannerController,
                      activeIndex: _activeBannerIndex,
                    ),
                    const SizedBox(height: 24.0),

                    // 5. Shop by Category chips
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Shop by Category',
                          style: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/categories'),
                          child: const Text('See All', style: TextStyle(color: OBColors.primary500)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    categoriesAsync.when(
                      data: (categories) {
                        final maxCategories = categories.length > 8 ? 8 : categories.length;
                        return SizedBox(
                          height: 94.0,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: maxCategories,
                            itemBuilder: (context, index) {
                              final category = categories[index];
                              return CategoryChip(
                                imageUrl: category.imageUrl,
                                categoryName: category.name,
                                surfaceColor: surfaceColor,
                                isDark: isDark,
                                onTap: () {
                                  ref.read(selectedCategoryIdProvider.notifier).state = category.id;
                                  context.push('/home/products');
                                },
                              );
                            },
                          ),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Text('Error loading categories: $err'),
                    ),
                    const SizedBox(height: 24.0),

                    // 6. Flash Sale ("Lightning Deals ⚡")
                    FlashSaleSection(
                      timeLeft: _timeLeft,
                      formattedTime: _formatDuration(_timeLeft),
                      isDark: isDark,
                      productsAsync: productsAsync,
                    ),
                    const SizedBox(height: 24.0),

                    // 7. Amdavadi Favorites (Hero Special Card)
                    LocalSpecialCard(
                      surfaceColor: surfaceColor,
                      isDark: isDark,
                      onTap: () {
                        ref.read(selectedCategoryIdProvider.notifier).state = 'cat_1'; // Snacks category
                        context.push('/home/products');
                      },
                    ),
                    const SizedBox(height: 24.0),

                    // 8. Best Sellers Product Grid
                    const Text(
                      'Best Sellers',
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    productsAsync.when(
                      data: (products) {
                        if (products.isEmpty) {
                          return const Center(child: Text('No products available.'));
                        }
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16.0,
                            mainAxisSpacing: 16.0,
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
                      error: (err, stack) => Text('Error loading products: $err'),
                    ),
                  ],
                ),
              ),
            ),

            // 9. Floating Cart Bar (Visible when cart has items)
            if (cartItemsCount > 0)
              Positioned(
                bottom: 94.0, // Floating above bottom nav bar
                left: 16.0,
                right: 16.0,
                child: FloatingCartBar(
                  itemsCount: cartItemsCount,
                  totalPrice: cartTotal,
                  onTap: () => context.push('/cart'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------
// Reusable Dashboard Widgets
// --------------------------------------------------------------------

// 1. Home Header Widget
class HomeHeader extends ConsumerWidget {
  final String userName;
  final Color surfaceColor;
  final bool isDark;
  final VoidCallback onNotificationTap;

  const HomeHeader({
    super.key,
    required this.userName,
    required this.surfaceColor,
    required this.isDark,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: OBShadows.neomorphic(level: 3, isDarkMode: isDark),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Neomorphic Location Marker Icon
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C1917) : OBColors.neutral100,
                  shape: BoxShape.circle,
                  boxShadow: OBShadows.neomorphic(level: 1, isDarkMode: isDark, pressed: true),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: OBColors.primary500,
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 12.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Ahmedabad Express',
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4.0),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Text(
                          '15 mins',
                          style: TextStyle(
                            fontSize: 9.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF22C55E),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    'Namaste, $userName 👋',
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: OBColors.neutral500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              // Notifications
              GestureDetector(
                onTap: onNotificationTap,
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1C1917) : OBColors.neutral100,
                    shape: BoxShape.circle,
                    boxShadow: OBShadows.neomorphic(level: 1, isDarkMode: isDark),
                  ),
                  child: Icon(
                    Icons.notifications_none_outlined,
                    size: 20.0,
                    color: isDark ? Colors.white70 : OBColors.neutral800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 2. Neomorphic SearchBar Widget
class HomeSearchBar extends StatelessWidget {
  final String hintText;
  final bool isDark;
  final Color surfaceColor;
  final VoidCallback onTap;

  const HomeSearchBar({
    super.key,
    required this.hintText,
    required this.isDark,
    required this.surfaceColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              Icons.qr_code_scanner_outlined,
              color: isDark ? Colors.white38 : OBColors.neutral500,
              size: 20.0,
            ),
          ],
        ),
      ),
    );
  }
}

// 3. Quick Services grid row
class QuickServicesRow extends StatelessWidget {
  const QuickServicesRow({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardBg = isDark ? const Color(0xFF242424) : const Color(0xFFFBFBFC);

    return SizedBox(
      height: 74.0,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildServiceCard('Groceries', Icons.shopping_basket_outlined, const Color(0xFFF97316), cardBg, isDark),
          _buildServiceCard('Veggies', Icons.eco_outlined, const Color(0xFF22C55E), cardBg, isDark),
          _buildServiceCard('Fruits', Icons.apple_outlined, const Color(0xFFEF4444), cardBg, isDark),
          _buildServiceCard('Dairy & Eggs', Icons.egg_alt_outlined, const Color(0xFFF59E0B), cardBg, isDark),
          _buildServiceCard('Snacks', Icons.cookie_outlined, const Color(0xFF8B5CF6), cardBg, isDark),
        ],
      ),
    );
  }

  Widget _buildServiceCard(String label, IconData icon, Color tintColor, Color cardBg, bool isDark) {
    return Container(
      width: 100.0,
      margin: const EdgeInsets.only(right: 12.0, bottom: 4.0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: OBShadows.neomorphic(level: 2, isDarkMode: isDark),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20.0, color: tintColor),
          const SizedBox(height: 6.0),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// 4. Promo Carousel Banner Widget
class PromoCarousel extends StatelessWidget {
  final List<Map<String, String>> banners;
  final PageController bannerController;
  final int activeIndex;

  const PromoCarousel({
    super.key,
    required this.banners,
    required this.bannerController,
    required this.activeIndex,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        SizedBox(
          height: 140.0,
          child: PageView.builder(
            controller: bannerController,
            itemCount: banners.length,
            itemBuilder: (context, index) {
              final b = banners[index];
              final grad = switch (b['colors']) {
                'orange_gold' => const LinearGradient(
                    colors: [Color(0xFFF97316), Color(0xFFFBBF24)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                'green_emerald' => const LinearGradient(
                    colors: [Color(0xFF22C55E), Color(0xFF34D399)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                _ => const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF818CF8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
              };

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  gradient: grad,
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10.0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        b['badge']!,
                        style: const TextStyle(
                          fontSize: 9.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      b['title']!,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      b['subtitle']!,
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10.0),
        // Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(banners.length, (index) {
            final isActive = index == activeIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 14.0 : 6.0,
              height: 6.0,
              margin: const EdgeInsets.symmetric(horizontal: 2.0),
              decoration: BoxDecoration(
                color: isActive ? OBColors.primary500 : (isDark ? Colors.white12 : OBColors.neutral300),
                borderRadius: BorderRadius.circular(3.0),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// 5. Category Chips Widget
class CategoryChip extends StatefulWidget {
  final String? imageUrl;
  final String categoryName;
  final Color surfaceColor;
  final bool isDark;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    this.imageUrl,
    required this.categoryName,
    required this.surfaceColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<CategoryChip> {
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
          width: 82.0,
          margin: const EdgeInsets.only(right: 12.0, bottom: 4.0),
          decoration: BoxDecoration(
            color: widget.surfaceColor,
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: OBShadows.neomorphic(
              level: 2,
              isDarkMode: widget.isDark,
              pressed: _isPressed,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44.0,
                height: 44.0,
                decoration: BoxDecoration(
                  color: widget.isDark ? const Color(0xFF1C1917) : OBColors.neutral100,
                  shape: BoxShape.circle,
                  boxShadow: OBShadows.neomorphic(level: 1, isDarkMode: widget.isDark, pressed: true),
                ),
                child: ClipOval(
                  child: widget.imageUrl != null
                      ? Image.network(
                          widget.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (c, o, s) => const Icon(Icons.category, color: OBColors.primary500, size: 18.0),
                        )
                      : const Icon(Icons.category, color: OBColors.primary500, size: 18.0),
                ),
              ),
              const SizedBox(height: 6.0),
              Text(
                widget.categoryName.split(' & ').first,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 10.0,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 6. Flash Sale (Lightning Deals) Section
class FlashSaleSection extends StatelessWidget {
  final Duration timeLeft;
  final String formattedTime;
  final bool isDark;
  final AsyncValue<List<dynamic>> productsAsync;

  const FlashSaleSection({
    super.key,
    required this.timeLeft,
    required this.formattedTime,
    required this.isDark,
    required this.productsAsync,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  'Lightning Deals ⚡',
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10.0),
                // Neomorphic Countdown Box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1C1917) : OBColors.neutral100,
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: OBShadows.neomorphic(level: 1, isDarkMode: isDark, pressed: true),
                  ),
                  child: Text(
                    formattedTime,
                    style: const TextStyle(
                      fontFamily: OBTypography.bodyFont,
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: OBColors.error,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12.0),
        productsAsync.when(
          data: (products) {
            final dealsProducts = products.take(3).toList();
            return SizedBox(
              height: 172.0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dealsProducts.length,
                itemBuilder: (context, index) {
                  final product = dealsProducts[index];
                  final variant = product.variants.isNotEmpty ? product.variants.first : null;
                  if (variant == null) return const SizedBox();

                  return Container(
                    width: 134.0,
                    margin: const EdgeInsets.only(right: 14.0, bottom: 4.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF242424) : const Color(0xFFFBFBFC),
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: OBShadows.neomorphic(level: 2, isDarkMode: isDark),
                    ),
                    child: GestureDetector(
                      onTap: () => context.push('/home/product/${product.id}'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14.0),
                              child: Container(
                                width: double.infinity,
                                color: isDark ? Colors.black26 : OBColors.neutral200,
                                child: product.primaryImageUrl != null
                                    ? Image.network(
                                        product.primaryImageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, o, s) => const Icon(Icons.image),
                                      )
                                    : const Icon(Icons.image),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            product.name,
                            style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '₹${variant.price}',
                                style: const TextStyle(
                                  color: OBColors.primary500,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.0,
                                ),
                              ),
                              Text(
                                '₹${(variant.price * 1.25).toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: OBColors.neutral400,
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 10.0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const SizedBox(),
          error: (e, s) => const SizedBox(),
        ),
      ],
    );
  }
}

// 7. Amdavadi Favorites (Local Specials Hero Card)
class LocalSpecialCard extends StatelessWidget {
  final Color surfaceColor;
  final bool isDark;
  final VoidCallback onTap;

  const LocalSpecialCard({
    super.key,
    required this.surfaceColor,
    required this.isDark,
    required this.onTap,
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
      child: Row(
        children: [
          // Neomorphic Store Icon container
          Container(
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1917) : OBColors.neutral100,
              shape: BoxShape.circle,
              boxShadow: OBShadows.neomorphic(level: 1, isDarkMode: isDark, pressed: true),
            ),
            child: const Icon(
              Icons.storefront_outlined,
              color: OBColors.success,
              size: 34.0,
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Amdavadi Specials',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6.0),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                      decoration: BoxDecoration(
                        color: OBColors.successBg,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Text(
                        'LOCAL',
                        style: TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold, color: OBColors.success),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4.0),
                const Text(
                  'Fresh Induben Khakhra, sweets, and local dairy favorites from Ahmedabad stores.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: OBColors.neutral500,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          // Arrow button
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1917) : OBColors.neutral100,
                shape: BoxShape.circle,
                boxShadow: OBShadows.neomorphic(level: 2, isDarkMode: isDark),
              ),
              child: Icon(
                Icons.arrow_forward_outlined,
                size: 18.0,
                color: isDark ? Colors.white70 : OBColors.neutral800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 8. Sticky Floating Cart Summary Bar
class FloatingCartBar extends StatelessWidget {
  final int itemsCount;
  final double totalPrice;
  final VoidCallback onTap;

  const FloatingCartBar({
    super.key,
    required this.itemsCount,
    required this.totalPrice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: 56.0,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2722) : OBColors.neutral100,
        borderRadius: BorderRadius.circular(28.0),
        boxShadow: OBShadows.neomorphic(level: 4, isDarkMode: isDark),
        border: Border.all(
          color: isDark ? Colors.white10 : OBColors.neutral200,
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.shopping_cart_outlined, color: OBColors.primary500, size: 20.0),
              const SizedBox(width: 10.0),
              Text(
                '$itemsCount ${itemsCount == 1 ? "Item" : "Items"}  •  ₹${totalPrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: onTap,
            child: Row(
              children: [
                Text(
                  'Checkout',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFC1C9FF) : OBColors.primary500,
                  ),
                ),
                const SizedBox(width: 4.0),
                Icon(
                  Icons.arrow_forward,
                  size: 16.0,
                  color: isDark ? const Color(0xFFC1C9FF) : OBColors.primary500,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
