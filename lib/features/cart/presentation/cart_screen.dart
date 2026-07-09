import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'cart_provider.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/widgets/buttons.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final _couponController = TextEditingController();

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  void _handleCheckout() {
    final user = ref.read(authProvider);
    if (user == null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF242424) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
            title: const Text('Login Required'),
            content: const Text('You must be logged in to proceed to checkout and place an order.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: OBColors.neutral500)),
              ),
              OBButton(
                text: 'Log In',
                size: OBButtonSize.small,
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/login');
                },
              ),
            ],
          );
        },
      );
    } else {
      context.push('/cart/checkout');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final cartState = ref.watch(cartProvider);

    // Neomorphic backgrounds
    final Color backgroundColor = isDark ? const Color(0xFF181818) : const Color(0xFFF7F8FA);
    final Color surfaceColor = isDark ? const Color(0xFF242424) : const Color(0xFFFBFBFC);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: cartState.items.isEmpty
            ? EmptyCartView(
                surfaceColor: surfaceColor,
                isDark: isDark,
                onStartShopping: () => context.go('/home'),
              )
            : Stack(
                children: [
                  Column(
                    children: [
                      // Floating Custom App Bar
                      CartHeader(
                        itemsCount: cartState.items.length,
                        isDark: isDark,
                        surfaceColor: surfaceColor,
                        onBackTap: () => context.pop(),
                      ),

                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.only(
                            left: 16.0,
                            right: 16.0,
                            top: 12.0,
                            bottom: 180.0, // spacing for sticky checkout bar
                          ),
                          children: [
                            // 1. Delivery Info Card
                            DeliveryInfoCard(
                              surfaceColor: surfaceColor,
                              isDark: isDark,
                              subtotal: cartState.subtotal,
                            ),
                            const SizedBox(height: 20.0),

                            // 2. Section: Cart Items
                            const Text(
                              'Review Items',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: cartState.items.length,
                              itemBuilder: (context, index) {
                                final item = cartState.items[index];
                                return CartItemCard(
                                  imageUrl: item.product.primaryImageUrl,
                                  productName: item.product.name,
                                  variantName: item.variant.name,
                                  sku: item.variant.sku,
                                  price: item.variant.price,
                                  quantity: item.quantity,
                                  maxQuantity: item.variant.stockQty,
                                  surfaceColor: surfaceColor,
                                  isDark: isDark,
                                  onDelete: () {
                                    ref.read(cartProvider.notifier).removeFromCart(item.id);
                                  },
                                  onQtyChanged: (newQty) {
                                    ref.read(cartProvider.notifier).updateQuantity(item.id, newQty);
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 20.0),

                            // 3. Coupon Application Card
                            CouponCard(
                              controller: _couponController,
                              appliedCoupon: cartState.appliedCoupon,
                              surfaceColor: surfaceColor,
                              isDark: isDark,
                              onApply: () async {
                                final code = _couponController.text.trim();
                                if (code.isNotEmpty) {
                                  final ok = await ref.read(cartProvider.notifier).applyCoupon(code);
                                  if (ok) {
                                    _couponController.clear();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Coupon applied successfully!')),
                                      );
                                    }
                                  } else {
                                    final err = ref.read(cartProvider).errorMessage ?? 'Invalid Coupon Code';
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(err)),
                                      );
                                    }
                                  }
                                }
                              },
                              onRemove: () {
                                ref.read(cartProvider.notifier).removeCoupon();
                              },
                            ),
                            const SizedBox(height: 20.0),

                            // 4. Order Summary Card
                            OrderSummaryCard(
                              subtotal: cartState.subtotal,
                              discount: cartState.discount,
                              deliveryFee: cartState.deliveryFee,
                              total: cartState.total,
                              surfaceColor: surfaceColor,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 20.0),

                            // 5. Delivery Benefits Indicators
                            DeliveryBenefitsCard(
                              surfaceColor: surfaceColor,
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // 6. Sticky Floating Checkout CTA Bar
                  Positioned(
                    bottom: 0.0,
                    left: 0.0,
                    right: 0.0,
                    child: StickyCheckoutBar(
                      totalAmount: cartState.total,
                      surfaceColor: surfaceColor,
                      isDark: isDark,
                      onCheckout: _handleCheckout,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// --------------------------------------------------------------------
// Reusable Checkout Components
// --------------------------------------------------------------------

// 1. Cart Header Widget
class CartHeader extends StatelessWidget {
  final int itemsCount;
  final bool isDark;
  final Color surfaceColor;
  final VoidCallback onBackTap;

  const CartHeader({
    super.key,
    required this.itemsCount,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Shopping Cart',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    '$itemsCount ${itemsCount == 1 ? "item" : "items"} ready to ship',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: OBColors.neutral500,
                    ),
                  ),
                ],
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
            child: const Icon(Icons.shopping_cart_checkout_outlined, color: OBColors.primary500, size: 20.0),
          ),
        ],
      ),
    );
  }
}

// 2. Delivery Address Info Card
class DeliveryInfoCard extends StatelessWidget {
  final Color surfaceColor;
  final bool isDark;
  final double subtotal;

  const DeliveryInfoCard({
    super.key,
    required this.surfaceColor,
    required this.isDark,
    required this.subtotal,
  });

  @override
  Widget build(BuildContext context) {
    // Delivery Progress to reach Free Shipping (₹200 threshold)
    const double threshold = 200.0;
    final double progress = (subtotal / threshold).clamp(0.0, 1.0);
    final double remaining = threshold - subtotal;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: OBShadows.neomorphic(level: 3, isDarkMode: isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.location_on_outlined, color: OBColors.primary500, size: 20.0),
                  SizedBox(width: 8.0),
                  Text(
                    'Deliver to Ahmedabad',
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C1917) : OBColors.neutral100,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: OBShadows.neomorphic(level: 1, isDarkMode: isDark),
                ),
                child: const Text(
                  '15-20 MINS',
                  style: TextStyle(fontSize: 9.0, fontWeight: FontWeight.bold, color: OBColors.primary500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          // Free delivery indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                remaining > 0
                    ? 'Add ₹${remaining.toStringAsFixed(0)} more for FREE delivery'
                    : 'Yay! You unlocked FREE Delivery 🎉',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: remaining > 0 ? OBColors.neutral500 : const Color(0xFF22C55E),
                ),
              ),
              if (remaining > 0)
                const Text(
                  'Goal: ₹200',
                  style: TextStyle(fontSize: 11.0, color: OBColors.neutral400),
                ),
            ],
          ),
          const SizedBox(height: 6.0),
          // Neomorphic Progress bar
          Container(
            height: 6.0,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1917) : OBColors.neutral200,
              borderRadius: BorderRadius.circular(3.0),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: (progress * 100).toInt(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      borderRadius: BorderRadius.circular(3.0),
                    ),
                  ),
                ),
                Expanded(
                  flex: ((1.0 - progress) * 100).toInt(),
                  child: const SizedBox(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 3. Cart Item Detail Row Card
class CartItemCard extends StatelessWidget {
  final String? imageUrl;
  final String productName;
  final String variantName;
  final String sku;
  final double price;
  final int quantity;
  final int maxQuantity;
  final Color surfaceColor;
  final bool isDark;
  final VoidCallback onDelete;
  final ValueChanged<int> onQtyChanged;

  const CartItemCard({
    super.key,
    this.imageUrl,
    required this.productName,
    required this.variantName,
    required this.sku,
    required this.price,
    required this.quantity,
    required this.maxQuantity,
    required this.surfaceColor,
    required this.isDark,
    required this.onDelete,
    required this.onQtyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: OBShadows.neomorphic(level: 2, isDarkMode: isDark),
      ),
      child: Row(
        children: [
          // Neomorphic Image wrapper
          Container(
            width: 72.0,
            height: 72.0,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1917) : OBColors.neutral100,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: OBShadows.neomorphic(level: 1, isDarkMode: isDark, pressed: true),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: imageUrl != null
                    ? Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (c, o, s) => const Icon(Icons.broken_image_outlined),
                      )
                    : const Icon(Icons.image),
              ),
            ),
          ),
          const SizedBox(width: 14.0),

          // Title & variant specs
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: const TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2.0),
                Text(
                  '$variantName • SKU: $sku',
                  style: const TextStyle(
                    fontSize: 11.0,
                    color: OBColors.neutral500,
                  ),
                ),
                const SizedBox(height: 6.0),
                Text(
                  '₹${price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: OBColors.primary500,
                  ),
                ),
              ],
            ),
          ),

          // Quantity stepper or Delete button
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF3E1E1E) : const Color(0xFFFFEBEE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_outline, color: OBColors.error, size: 16.0),
                ),
              ),
              const SizedBox(height: 10.0),
              // Stepper count controls
              Container(
                height: 32.0,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C1917) : OBColors.neutral100,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: OBShadows.neomorphic(level: 1, isDarkMode: isDark, pressed: true),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: quantity > 1 ? () => onQtyChanged(quantity - 1) : null,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Icon(Icons.remove, size: 14.0),
                      ),
                    ),
                    Text(
                      '$quantity',
                      style: const TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: quantity < maxQuantity ? () => onQtyChanged(quantity + 1) : null,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Icon(Icons.add, size: 14.0),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 4. Coupon Card Code application
class CouponCard extends StatelessWidget {
  final TextEditingController controller;
  final dynamic appliedCoupon;
  final Color surfaceColor;
  final bool isDark;
  final VoidCallback onApply;
  final VoidCallback onRemove;

  const CouponCard({
    super.key,
    required this.controller,
    required this.appliedCoupon,
    required this.surfaceColor,
    required this.isDark,
    required this.onApply,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasCoupon = appliedCoupon != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: OBShadows.neomorphic(level: 3, isDarkMode: isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.confirmation_number_outlined, color: OBColors.primary500, size: 18.0),
              SizedBox(width: 8.0),
              Text(
                'Avail Coupons & Offers',
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          if (!hasCoupon) ...[
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44.0,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1C1917) : OBColors.neutral100,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: OBShadows.neomorphic(level: 1, isDarkMode: isDark, pressed: true),
                    ),
                    child: TextField(
                      controller: controller,
                      style: const TextStyle(fontSize: 13.5),
                      decoration: const InputDecoration(
                        hintText: 'Enter coupon (e.g. WELCOME50)',
                        hintStyle: TextStyle(color: OBColors.neutral400),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                OBButton(
                  text: 'Apply',
                  size: OBButtonSize.small,
                  onPressed: onApply,
                ),
              ],
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle_outline_outlined, color: Color(0xFF22C55E), size: 18.0),
                      const SizedBox(width: 8.0),
                      Text(
                        'Applied Code: ${appliedCoupon.code}',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF22C55E),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: onRemove,
                    child: const Icon(Icons.cancel_outlined, color: OBColors.error, size: 18.0),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// 5. Order Summary Card Breakdown
class OrderSummaryCard extends StatelessWidget {
  final double subtotal;
  final double discount;
  final double deliveryFee;
  final double total;
  final Color surfaceColor;
  final bool isDark;

  const OrderSummaryCard({
    super.key,
    required this.subtotal,
    required this.discount,
    required this.deliveryFee,
    required this.total,
    required this.surfaceColor,
    required this.isDark,
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
          const Text(
            'Bill Summary',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14.0),

          _buildRow('Subtotal', '₹${subtotal.toStringAsFixed(0)}'),
          if (discount > 0) ...[
            const SizedBox(height: 8.0),
            _buildRow('Coupon Discount', '-₹${discount.toStringAsFixed(0)}', color: const Color(0xFF22C55E)),
          ],
          const SizedBox(height: 8.0),
          _buildRow('Delivery Partner Fee', deliveryFee > 0 ? '₹${deliveryFee.toStringAsFixed(0)}' : 'FREE', color: deliveryFee > 0 ? null : const Color(0xFF22C55E)),
          const SizedBox(height: 8.0),
          _buildRow('Convenience & Safety Fee', '₹2.00'),

          const Divider(height: 24.0),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Grand Total',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              Text(
                '₹${(total + 2.0).toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: OBColors.primary500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13.0, color: OBColors.neutral500),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.0,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

// 6. Delivery Benefits Trust Badges Card
class DeliveryBenefitsCard extends StatelessWidget {
  final Color surfaceColor;
  final bool isDark;

  const DeliveryBenefitsCard({
    super.key,
    required this.surfaceColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: OBShadows.neomorphic(level: 3, isDarkMode: isDark),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBenefitItem(Icons.local_shipping_outlined, 'Free Delivery'),
          _buildBenefitItem(Icons.eco_outlined, 'Fresh Guarantee'),
          _buildBenefitItem(Icons.verified_user_outlined, 'Secure Pay'),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14.0, color: OBColors.primary500),
        const SizedBox(width: 4.0),
        Text(
          label,
          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// 7. Sticky Floating Checkout CTA bottom card bar
class StickyCheckoutBar extends StatelessWidget {
  final double totalAmount;
  final Color surfaceColor;
  final bool isDark;
  final VoidCallback onCheckout;

  const StickyCheckoutBar({
    super.key,
    required this.totalAmount,
    required this.surfaceColor,
    required this.isDark,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            offset: const Offset(0, -4),
            blurRadius: 16.0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Simulated payments logo row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Includes ₹2.0 safety fee',
                style: TextStyle(fontSize: 11.0, color: OBColors.neutral500),
              ),
              Row(
                children: [
                  const Icon(Icons.payment_outlined, size: 14.0, color: OBColors.neutral400),
                  const SizedBox(width: 4.0),
                  Text(
                    'UPI & Cards accepted',
                    style: TextStyle(fontSize: 10.5, color: isDark ? Colors.white38 : OBColors.neutral500),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12.0),

          // Action Stepper Button
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'GRAND TOTAL',
                    style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: OBColors.neutral500),
                  ),
                  Text(
                    '₹${(totalAmount + 2.0).toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(width: 24.0),
              Expanded(
                child: OBButton(
                  text: 'Proceed to Pay',
                  onPressed: onCheckout,
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

// 8. Empty Cart placeholder view
class EmptyCartView extends StatelessWidget {
  final Color surfaceColor;
  final bool isDark;
  final VoidCallback onStartShopping;

  const EmptyCartView({
    super.key,
    required this.surfaceColor,
    required this.isDark,
    required this.onStartShopping,
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
              // Beautiful grocery illustration frame
              Container(
                padding: const EdgeInsets.all(18.0),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C1917) : OBColors.neutral100,
                  shape: BoxShape.circle,
                  boxShadow: OBShadows.neomorphic(level: 1, isDarkMode: isDark, pressed: true),
                ),
                child: const Icon(
                  Icons.shopping_cart_outlined,
                  size: 64.0,
                  color: OBColors.primary500,
                ),
              ),
              const SizedBox(height: 20.0),
              const Text(
                'Your cart is empty',
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              const Text(
                'Add fresh produce and local groceries to get started with fast Ahmedabad shipping.',
                style: TextStyle(
                  fontSize: 13.5,
                  color: OBColors.neutral500,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24.0),
              OBButton(
                text: 'Start Shopping',
                onPressed: onStartShopping,
                size: OBButtonSize.medium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
