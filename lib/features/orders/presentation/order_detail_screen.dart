import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'orders_provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/radius.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/cards.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final orders = ref.watch(ordersProvider);

    final orderIndex = orders.indexWhere((o) => o.id == orderId);
    if (orderIndex < 0) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Details')),
        body: const Center(child: Text('Order not found.')),
      );
    }

    final order = orders[orderIndex];
    final bool canCancel = order.status.toLowerCase() == 'pending' || order.status.toLowerCase() == 'confirmed';

    int getStepIndex(String status) {
      return switch (status.toLowerCase()) {
        'pending' => 0,
        'confirmed' => 1,
        'shipped' => 2,
        'delivered' => 3,
        _ => -1, // Cancelled or other
      };
    }

    final currentStep = getStepIndex(order.status);
    final isCancelled = order.status.toLowerCase() == 'cancelled';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Tracking'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: OBSpacing.space4,
          right: OBSpacing.space4,
          top: OBSpacing.space3,
          bottom: 100.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Order Status Timeline
            Text(
              'Order Status',
              style: OBTypography.subtitle.copyWith(
                color: isDark ? Colors.white : OBColors.neutral800,
              ),
            ),
            const SizedBox(height: OBSpacing.space3),
            if (isCancelled)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(OBSpacing.space4),
                decoration: BoxDecoration(
                  color: OBColors.errorBg,
                  borderRadius: OBRadius.md,
                  border: Border.all(color: OBColors.error),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cancel, color: OBColors.error),
                    const SizedBox(width: 8.0),
                    Text(
                      'This order has been cancelled.',
                      style: OBTypography.body.copyWith(color: OBColors.error, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(vertical: OBSpacing.space4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2722) : OBColors.neutral100,
                  borderRadius: OBRadius.md,
                  boxShadow: OBShadows.neomorphic(level: 1, isDarkMode: isDark),
                ),
                child: Stepper(
                  physics: const NeverScrollableScrollPhysics(),
                  currentStep: currentStep >= 0 ? currentStep : 0,
                  controlsBuilder: (context, details) => Container(), // Hide default buttons
                  steps: [
                    Step(
                      title: const Text('Ordered'),
                      subtitle: const Text('We have received your order'),
                      content: const SizedBox(),
                      isActive: currentStep >= 0,
                      state: currentStep > 0 ? StepState.complete : StepState.indexed,
                    ),
                    Step(
                      title: const Text('Confirmed'),
                      subtitle: const Text('Order details verified by store'),
                      content: const SizedBox(),
                      isActive: currentStep >= 1,
                      state: currentStep > 1 ? StepState.complete : StepState.indexed,
                    ),
                    Step(
                      title: const Text('Shipped'),
                      subtitle: const Text('In transit to Ahmedabad address'),
                      content: const SizedBox(),
                      isActive: currentStep >= 2,
                      state: currentStep > 2 ? StepState.complete : StepState.indexed,
                    ),
                    Step(
                      title: const Text('Delivered'),
                      subtitle: const Text('Arrived at your doorstep'),
                      content: const SizedBox(),
                      isActive: currentStep >= 3,
                      state: currentStep == 3 ? StepState.complete : StepState.indexed,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: OBSpacing.space6),

            // 2. Shipping Address
            Text(
              'Delivery Address',
              style: OBTypography.subtitle.copyWith(
                color: isDark ? Colors.white : OBColors.neutral800,
              ),
            ),
            const SizedBox(height: OBSpacing.space2),
            OBCard(
              child: Padding(
                padding: const EdgeInsets.all(OBSpacing.space4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.shippingAddress['name'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      '${order.shippingAddress['address_line1']}, ${order.shippingAddress['address_line2'] ?? ""}\n${order.shippingAddress['city']} - ${order.shippingAddress['pincode']}',
                      style: OBTypography.body.copyWith(color: OBColors.neutral600),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Phone: ${order.shippingAddress['phone_number']}',
                      style: OBTypography.caption.copyWith(color: OBColors.neutral500),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: OBSpacing.space6),

            // 3. Order Breakdown details
            Text(
              'Receipt Breakdown',
              style: OBTypography.subtitle.copyWith(
                color: isDark ? Colors.white : OBColors.neutral800,
              ),
            ),
            const SizedBox(height: OBSpacing.space2),
            Container(
              padding: const EdgeInsets.all(OBSpacing.space4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C2722) : OBColors.neutral100,
                borderRadius: OBRadius.md,
                boxShadow: OBShadows.neomorphic(level: 1, isDarkMode: isDark),
              ),
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: order.items.length,
                    itemBuilder: (context, i) {
                      final item = order.items[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${item.productName} (${item.variantName}) x${item.quantity}'),
                            Text('₹${(item.priceAtPurchase * item.quantity).toStringAsFixed(2)}'),
                          ],
                        ),
                      );
                    },
                  ),
                  const Divider(height: OBSpacing.space4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal'),
                      Text('₹${order.subtotal.toStringAsFixed(2)}'),
                    ],
                  ),
                  if (order.discount > 0) ...[
                    const SizedBox(height: 4.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Discount', style: TextStyle(color: OBColors.success)),
                        Text('-₹${order.discount.toStringAsFixed(2)}', style: const TextStyle(color: OBColors.success)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 4.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Delivery Fee'),
                      Text('₹${order.deliveryFee.toStringAsFixed(2)}'),
                    ],
                  ),
                  const Divider(height: OBSpacing.space4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Paid', style: OBTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                      Text(
                        '₹${order.total.toStringAsFixed(2)}',
                        style: OBTypography.title.copyWith(
                          color: OBColors.primary500,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: OBSpacing.space8),

            // 4. Action button (cancel order)
            if (canCancel)
              OBButton(
                text: 'Cancel Order',
                variant: OBButtonVariant.danger,
                isFullWidth: true,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Cancel Order?'),
                        content: const Text('Are you sure you want to cancel this order? This action will restore stock items.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Keep Order'),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              try {
                                await ref.read(ordersProvider.notifier).cancelOrder(orderId);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Order Cancelled Successfully!')),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Cancellation Failed: $e')),
                                  );
                                }
                              }
                            },
                            child: const Text('Yes, Cancel'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
