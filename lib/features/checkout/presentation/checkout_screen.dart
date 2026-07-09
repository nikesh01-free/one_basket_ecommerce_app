import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../addresses/presentation/address_provider.dart';
import '../../cart/presentation/cart_provider.dart';
import '../../orders/presentation/orders_provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/widgets/buttons.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen>
    with SingleTickerProviderStateMixin {
  int _selectedAddressIndex = 0;
  String _paymentMethod = 'cod'; // 'cod' or 'stripe'
  bool _isProcessing = false;

  Future<void> _handleConfirm() async {
    final addresses = ref.read(addressProvider);
    if (addresses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a delivery address first.')),
      );
      return;
    }

    final address = addresses[_selectedAddressIndex];

    setState(() {
      _isProcessing = true;
    });

    try {
      if (_paymentMethod == 'stripe') {
        // Mock Stripe secure sheet delay
        await Future.delayed(const Duration(milliseconds: 1500));
      }

      final order = await ref.read(ordersProvider.notifier).placeOrder(
            address: address,
            paymentMethod: _paymentMethod,
          );

      if (mounted) {
        context.go('/cart/confirmation/${order.id}');
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Checkout failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final addresses = ref.watch(addressProvider);
    final cartState = ref.watch(cartProvider);

    final Color backgroundColor = isDark ? const Color(0xFF181818) : const Color(0xFFF7F8FA);
    final Color surfaceColor = isDark ? const Color(0xFF242424) : const Color(0xFFFBFBFC);

    if (_isProcessing) {
      return CheckoutLoadingView(
        paymentMethod: _paymentMethod,
        isDark: isDark,
        surfaceColor: surfaceColor,
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Custom Floating App Bar
                _CheckoutHeader(
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  onBack: () => context.pop(),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      top: 12.0,
                      bottom: 160.0,
                    ),
                    children: [
                      // Progress Indicator
                      CheckoutProgressIndicator(
                        isDark: isDark,
                        surfaceColor: surfaceColor,
                      ),
                      const SizedBox(height: 20.0),

                      // 1. Delivery Address Section
                      const _SectionLabel(label: '📍 Delivery Address'),
                      const SizedBox(height: 10.0),
                      addresses.isEmpty
                          ? EmptyAddressCard(
                              isDark: isDark,
                              surfaceColor: surfaceColor,
                              onAdd: () => context.push('/profile'),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: addresses.length,
                              itemBuilder: (context, index) {
                                final addr = addresses[index];
                                final isSelected = index == _selectedAddressIndex;
                                return AddressCard(
                                  name: addr.name,
                                  line1: addr.addressLine1,
                                  line2: addr.addressLine2 ?? '',
                                  city: addr.city,
                                  pincode: addr.pincode,
                                  phone: addr.phoneNumber,
                                  isSelected: isSelected,
                                  isDark: isDark,
                                  surfaceColor: surfaceColor,
                                  onTap: () => setState(() => _selectedAddressIndex = index),
                                );
                              },
                            ),
                      const SizedBox(height: 10.0),
                      AddAddressCard(
                        isDark: isDark,
                        surfaceColor: surfaceColor,
                        onTap: () => context.push('/profile'),
                      ),
                      const SizedBox(height: 24.0),

                      // 2. Delivery Info
                      DeliveryInfoCheckoutCard(isDark: isDark, surfaceColor: surfaceColor),
                      const SizedBox(height: 24.0),

                      // 3. Payment Method
                      const _SectionLabel(label: '💳 Payment Method'),
                      const SizedBox(height: 10.0),
                      PaymentMethodCard(
                        icon: Icons.money_outlined,
                        title: 'Cash on Delivery',
                        subtitle: 'Pay when the order arrives at your door.',
                        value: 'cod',
                        groupValue: _paymentMethod,
                        isDark: isDark,
                        surfaceColor: surfaceColor,
                        onChanged: (val) => setState(() => _paymentMethod = val),
                      ),
                      const SizedBox(height: 10.0),
                      PaymentMethodCard(
                        icon: Icons.credit_card_outlined,
                        title: 'Stripe Card',
                        subtitle: 'Secure online payment using credit/debit card.',
                        value: 'stripe',
                        groupValue: _paymentMethod,
                        isDark: isDark,
                        surfaceColor: surfaceColor,
                        onChanged: (val) => setState(() => _paymentMethod = val),
                      ),
                      const SizedBox(height: 16.0),
                      SecurityBanner(isDark: isDark, surfaceColor: surfaceColor),
                      const SizedBox(height: 24.0),

                      // 4. Order Items
                      const _SectionLabel(label: '🛍 Your Order'),
                      const SizedBox(height: 10.0),
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(24.0),
                          boxShadow: OBShadows.neomorphic(level: 2, isDarkMode: isDark),
                        ),
                        child: Column(
                          children: cartState.items.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            return Column(
                              children: [
                                if (index > 0)
                                  Divider(
                                    height: 16.0,
                                    color: isDark ? Colors.white10 : OBColors.neutral200,
                                  ),
                                OrderSummaryRow(
                                  imageUrl: item.product.primaryImageUrl,
                                  name: item.product.name,
                                  variant: item.variant.name,
                                  quantity: item.quantity,
                                  price: item.variant.price * item.quantity,
                                  isDark: isDark,
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 24.0),

                      // 5. Bill Summary
                      BillSummaryCard(
                        subtotal: cartState.subtotal,
                        discount: cartState.discount,
                        deliveryFee: cartState.deliveryFee,
                        total: cartState.total,
                        isDark: isDark,
                        surfaceColor: surfaceColor,
                      ),
                      const SizedBox(height: 24.0),

                      // 6. Trust Badges
                      TrustBadges(isDark: isDark, surfaceColor: surfaceColor),
                    ],
                  ),
                ),
              ],
            ),

            // Sticky Bottom Place Order Bar
            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: StickyCheckoutBar(
                total: cartState.total,
                deliveryFee: cartState.deliveryFee,
                isDark: isDark,
                surfaceColor: surfaceColor,
                onPlaceOrder: _handleConfirm,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Internal Screen Header
// ──────────────────────────────────────────────────────────────────────────────

class _CheckoutHeader extends StatelessWidget {
  final bool isDark;
  final Color surfaceColor;
  final VoidCallback onBack;

  const _CheckoutHeader({
    required this.isDark,
    required this.surfaceColor,
    required this.onBack,
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
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1917) : OBColors.neutral100,
                shape: BoxShape.circle,
                boxShadow: OBShadows.neomorphic(level: 1, isDarkMode: isDark),
              ),
              child: Icon(Icons.arrow_back, size: 20.0, color: isDark ? Colors.white : Colors.black87),
            ),
          ),
          const SizedBox(width: 14.0),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Secure Checkout',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              Text(
                '🔒 256-bit SSL Encrypted',
                style: TextStyle(fontSize: 11.0, color: OBColors.neutral500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Reusable Checkout Widgets
// ──────────────────────────────────────────────────────────────────────────────

// 1. Checkout Progress Steps
class CheckoutProgressIndicator extends StatelessWidget {
  final bool isDark;
  final Color surfaceColor;

  const CheckoutProgressIndicator({
    super.key,
    required this.isDark,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: OBShadows.neomorphic(level: 2, isDarkMode: isDark),
      ),
      child: Row(
        children: [
          _step('Cart', Icons.shopping_cart_outlined, true),
          _connector(),
          _step('Address', Icons.location_on_outlined, true),
          _connector(),
          _step('Payment', Icons.payment_outlined, true),
          _connector(),
          _step('Review', Icons.rate_review_outlined, false),
        ],
      ),
    );
  }

  Widget _step(String label, IconData icon, bool active) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 28.0,
            height: 28.0,
            decoration: BoxDecoration(
              color: active ? OBColors.primary500 : OBColors.neutral300,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14.0, color: Colors.white),
          ),
          const SizedBox(height: 4.0),
          Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
              color: active ? OBColors.primary500 : OBColors.neutral400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _connector() {
    return Expanded(
      flex: 0,
      child: Container(
        width: 20.0,
        height: 2.0,
        color: OBColors.neutral300,
        margin: const EdgeInsets.only(bottom: 14.0),
      ),
    );
  }
}

// 2. Address Card
class AddressCard extends StatelessWidget {
  final String name;
  final String line1;
  final String line2;
  final String city;
  final String pincode;
  final String phone;
  final bool isSelected;
  final bool isDark;
  final Color surfaceColor;
  final VoidCallback onTap;

  const AddressCard({
    super.key,
    required this.name,
    required this.line1,
    required this.line2,
    required this.city,
    required this.pincode,
    required this.phone,
    required this.isSelected,
    required this.isDark,
    required this.surfaceColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 10.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isSelected ? OBColors.primary500.withValues(alpha: 0.05) : surfaceColor,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected ? OBColors.primary500 : Colors.transparent,
            width: 2.0,
          ),
          boxShadow: OBShadows.neomorphic(level: isSelected ? 3 : 2, isDarkMode: isDark),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: isSelected ? OBColors.primary500.withValues(alpha: 0.12) : (isDark ? const Color(0xFF1C1917) : OBColors.neutral100),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.home_outlined,
                size: 18.0,
                color: isSelected ? OBColors.primary500 : OBColors.neutral500,
              ),
            ),
            const SizedBox(width: 14.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? OBColors.primary500 : null,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 6.0),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: OBColors.primary500,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: const Text(
                            'SELECTED',
                            style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3.0),
                  Text(
                    '$line1, $line2\n$city — $pincode',
                    style: const TextStyle(fontSize: 12.0, color: OBColors.neutral500, height: 1.4),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    '📞 $phone',
                    style: const TextStyle(fontSize: 11.5, color: OBColors.neutral400),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: OBColors.primary500, size: 22.0),
          ],
        ),
      ),
    );
  }
}

// 3. Empty Address Card
class EmptyAddressCard extends StatelessWidget {
  final bool isDark;
  final Color surfaceColor;
  final VoidCallback onAdd;

  const EmptyAddressCard({
    super.key,
    required this.isDark,
    required this.surfaceColor,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: OBShadows.neomorphic(level: 2, isDarkMode: isDark),
      ),
      child: Column(
        children: [
          const Icon(Icons.location_off_outlined, size: 48.0, color: OBColors.neutral400),
          const SizedBox(height: 12.0),
          const Text(
            'No Delivery Address Yet',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6.0),
          const Text(
            'Add an Ahmedabad delivery address to continue your order.',
            style: TextStyle(fontSize: 12.5, color: OBColors.neutral500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16.0),
          OBButton(text: 'Add Address', onPressed: onAdd, size: OBButtonSize.medium),
        ],
      ),
    );
  }
}

// 4. Add Address Button Card
class AddAddressCard extends StatelessWidget {
  final bool isDark;
  final Color surfaceColor;
  final VoidCallback onTap;

  const AddAddressCard({
    super.key,
    required this.isDark,
    required this.surfaceColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isDark ? Colors.white24 : OBColors.neutral300,
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                color: OBColors.primary500.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, size: 16.0, color: OBColors.primary500),
            ),
            const SizedBox(width: 8.0),
            const Text(
              'Add New Address',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: OBColors.primary500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 5. Delivery Info Card
class DeliveryInfoCheckoutCard extends StatelessWidget {
  final bool isDark;
  final Color surfaceColor;

  const DeliveryInfoCheckoutCard({
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
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_shipping_outlined, color: Color(0xFF22C55E), size: 20.0),
          ),
          const SizedBox(width: 14.0),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Express Delivery',
                  style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2.0),
                Text(
                  'Estimated arrival: 15–20 mins • Freshness Guaranteed',
                  style: TextStyle(fontSize: 11.5, color: OBColors.neutral500),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
            decoration: BoxDecoration(
              color: OBColors.primary500.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: const Text(
              '⚡ 15 MIN',
              style: TextStyle(fontSize: 9.0, fontWeight: FontWeight.bold, color: OBColors.primary500),
            ),
          ),
        ],
      ),
    );
  }
}

// 6. Payment Method Cards
class PaymentMethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final String groupValue;
  final bool isDark;
  final Color surfaceColor;
  final ValueChanged<String> onChanged;

  const PaymentMethodCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.isDark,
    required this.surfaceColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = value == groupValue;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isSelected ? OBColors.primary500.withValues(alpha: 0.05) : surfaceColor,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected ? OBColors.primary500 : Colors.transparent,
            width: 2.0,
          ),
          boxShadow: OBShadows.neomorphic(level: isSelected ? 3 : 2, isDarkMode: isDark),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: isSelected ? OBColors.primary500.withValues(alpha: 0.12) : (isDark ? const Color(0xFF1C1917) : OBColors.neutral100),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20.0, color: isSelected ? OBColors.primary500 : OBColors.neutral500),
            ),
            const SizedBox(width: 14.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? OBColors.primary500 : null,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11.5, color: OBColors.neutral500),
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isSelected
                  ? const Icon(Icons.check_circle_rounded, color: OBColors.primary500, size: 22.0, key: ValueKey('selected'))
                  : Icon(Icons.radio_button_unchecked, color: OBColors.neutral300, size: 22.0, key: ValueKey('unselected_$value')),
            ),
          ],
        ),
      ),
    );
  }
}

// 7. Security Banner
class SecurityBanner extends StatelessWidget {
  final bool isDark;
  final Color surfaceColor;

  const SecurityBanner({
    super.key,
    required this.isDark,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18.0),
        boxShadow: OBShadows.neomorphic(level: 1, isDarkMode: isDark),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _secBadge(Icons.lock_outline, '256-bit SSL'),
          _divider(),
          _secBadge(Icons.verified_user_outlined, 'PCI DSS'),
          _divider(),
          _secBadge(Icons.shield_outlined, 'Stripe Secure'),
        ],
      ),
    );
  }

  Widget _secBadge(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 16.0, color: const Color(0xFF22C55E)),
        const SizedBox(height: 3.0),
        Text(label, style: const TextStyle(fontSize: 9.0, fontWeight: FontWeight.bold, color: OBColors.neutral500)),
      ],
    );
  }

  Widget _divider() {
    return Container(width: 1.0, height: 28.0, color: OBColors.neutral200);
  }
}

// 8. Order Summary Row (per item)
class OrderSummaryRow extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final String variant;
  final int quantity;
  final double price;
  final bool isDark;

  const OrderSummaryRow({
    super.key,
    this.imageUrl,
    required this.name,
    required this.variant,
    required this.quantity,
    required this.price,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52.0,
          height: 52.0,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1917) : OBColors.neutral100,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: imageUrl != null
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (c, o, s) => const Icon(Icons.image_outlined, size: 22.0, color: OBColors.neutral400),
                  )
                : const Icon(Icons.image_outlined, size: 22.0, color: OBColors.neutral400),
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2.0),
              Text(
                '$variant • Qty $quantity',
                style: const TextStyle(fontSize: 11.0, color: OBColors.neutral500),
              ),
            ],
          ),
        ),
        Text(
          '₹${price.toStringAsFixed(0)}',
          style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: OBColors.primary500),
        ),
      ],
    );
  }
}

// 9. Bill Summary Card
class BillSummaryCard extends StatelessWidget {
  final double subtotal;
  final double discount;
  final double deliveryFee;
  final double total;
  final bool isDark;
  final Color surfaceColor;

  const BillSummaryCard({
    super.key,
    required this.subtotal,
    required this.discount,
    required this.deliveryFee,
    required this.total,
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
          const Text('Bill Summary', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14.0),
          _row('Subtotal', '₹${subtotal.toStringAsFixed(0)}'),
          if (discount > 0) ...[
            const SizedBox(height: 8.0),
            _row('Coupon Discount', '-₹${discount.toStringAsFixed(0)}', valueColor: const Color(0xFF22C55E)),
          ],
          const SizedBox(height: 8.0),
          _row('Delivery Fee', deliveryFee > 0 ? '₹${deliveryFee.toStringAsFixed(0)}' : 'FREE',
              valueColor: deliveryFee == 0 ? const Color(0xFF22C55E) : null),
          const SizedBox(height: 8.0),
          _row('Convenience Fee', '₹2'),
          const Divider(height: 22.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Grand Total', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
              Text(
                '₹${(total + 2).toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: OBColors.primary500),
              ),
            ],
          ),
          if (discount > 0) ...[
            const SizedBox(height: 8.0),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Text(
                '🎉 You saved ₹${discount.toStringAsFixed(0)} today!',
                style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold, color: Color(0xFF22C55E)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13.0, color: OBColors.neutral500)),
        Text(
          value,
          style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold, color: valueColor),
        ),
      ],
    );
  }
}

// 10. Trust Badges Row
class TrustBadges extends StatelessWidget {
  final bool isDark;
  final Color surfaceColor;

  const TrustBadges({
    super.key,
    required this.isDark,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: OBShadows.neomorphic(level: 2, isDarkMode: isDark),
      ),
      child: Wrap(
        spacing: 16.0,
        runSpacing: 8.0,
        alignment: WrapAlignment.spaceAround,
        children: const [
          _TrustItem(emoji: '✅', label: 'Secure Pay'),
          _TrustItem(emoji: '↩', label: 'Easy Return'),
          _TrustItem(emoji: '🥬', label: 'Fresh Only'),
          _TrustItem(emoji: '🚚', label: 'Tracked'),
        ],
      ),
    );
  }
}

class _TrustItem extends StatelessWidget {
  final String emoji;
  final String label;

  const _TrustItem({required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 13.0)),
        const SizedBox(width: 4.0),
        Text(label, style: const TextStyle(fontSize: 11.0, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// 11. Sticky Bottom Place Order Bar
class StickyCheckoutBar extends StatelessWidget {
  final double total;
  final double deliveryFee;
  final bool isDark;
  final Color surfaceColor;
  final VoidCallback onPlaceOrder;

  const StickyCheckoutBar({
    super.key,
    required this.total,
    required this.deliveryFee,
    required this.isDark,
    required this.surfaceColor,
    required this.onPlaceOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'GRAND TOTAL',
                    style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: OBColors.neutral500),
                  ),
                  Text(
                    '₹${(total + 2).toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '15–20 min delivery',
                    style: TextStyle(fontSize: 10.5, color: OBColors.neutral500),
                  ),
                  Text(
                    '🔒 Secure Checkout',
                    style: TextStyle(fontSize: 10.0, color: OBColors.neutral400),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          OBButton(
            text: 'Place Order →',
            onPressed: onPlaceOrder,
            size: OBButtonSize.large,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }
}

// 12. Premium Loading View
class CheckoutLoadingView extends StatefulWidget {
  final String paymentMethod;
  final bool isDark;
  final Color surfaceColor;

  const CheckoutLoadingView({
    super.key,
    required this.paymentMethod,
    required this.isDark,
    required this.surfaceColor,
  });

  @override
  State<CheckoutLoadingView> createState() => _CheckoutLoadingViewState();
}

class _CheckoutLoadingViewState extends State<CheckoutLoadingView> {
  int _msgIndex = 0;
  final List<String> _messages = [
    'Preparing your order...',
    'Verifying inventory...',
    'Securing payment...',
    'Almost done...',
  ];

  @override
  void initState() {
    super.initState();
    _cycleMessages();
  }

  void _cycleMessages() {
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted && _msgIndex < _messages.length - 1) {
        setState(() => _msgIndex++);
        _cycleMessages();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = widget.isDark ? const Color(0xFF181818) : const Color(0xFFF7F8FA);

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Container(
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: widget.surfaceColor,
              borderRadius: BorderRadius.circular(28.0),
              boxShadow: OBShadows.neomorphic(level: 4, isDarkMode: widget.isDark),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pulsing delivery icon
                Container(
                  width: 80.0,
                  height: 80.0,
                  decoration: BoxDecoration(
                    color: OBColors.primary500.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.local_shipping_outlined, size: 40.0, color: OBColors.primary500),
                ),
                const SizedBox(height: 24.0),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                  child: Text(
                    _messages[_msgIndex],
                    key: ValueKey(_msgIndex),
                    style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  widget.paymentMethod == 'stripe'
                      ? 'Contacting Stripe gateway securely...'
                      : 'Creating your hyperlocal order...',
                  style: const TextStyle(fontSize: 12.0, color: OBColors.neutral500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24.0),
                // Animated progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: LinearProgressIndicator(
                    backgroundColor: widget.isDark ? Colors.white10 : OBColors.neutral200,
                    valueColor: const AlwaysStoppedAnimation<Color>(OBColors.primary500),
                    minHeight: 6.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
