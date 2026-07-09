import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'orders_provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/radius.dart';
import '../../../core/theme/shadows.dart';

class OrdersListScreen extends ConsumerWidget {
  const OrdersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final orders = ref.watch(ordersProvider);

    Color getStatusColor(String status) {
      return switch (status.toLowerCase()) {
        'pending' => OBColors.warning,
        'confirmed' => OBColors.info,
        'shipped' => OBColors.primary500,
        'delivered' => OBColors.success,
        'cancelled' => OBColors.error,
        _ => OBColors.neutral500,
      };
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: orders.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(OBSpacing.space6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.receipt_long_outlined,
                      size: 80.0,
                      color: OBColors.neutral400,
                    ),
                    const SizedBox(height: OBSpacing.space4),
                    Text(
                      'No orders yet',
                      style: OBTypography.heading2.copyWith(
                        color: isDark ? Colors.white : OBColors.neutral800,
                      ),
                    ),
                    const SizedBox(height: OBSpacing.space2),
                    Text(
                      "You haven't placed any orders yet. Visit the catalog to find items.",
                      style: OBTypography.body.copyWith(color: OBColors.neutral500),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(
                left: OBSpacing.space4,
                right: OBSpacing.space4,
                top: OBSpacing.space3,
                bottom: 100.0,
              ),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final statusColor = getStatusColor(order.status);

                return Container(
                  margin: const EdgeInsets.only(bottom: OBSpacing.space3),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2C2722) : OBColors.neutral100,
                    borderRadius: OBRadius.md,
                    boxShadow: OBShadows.neomorphic(level: 1, isDarkMode: isDark),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(OBSpacing.space3),
                    onTap: () {
                      context.push('/profile/order/${order.id}');
                    },
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ID: ${order.id.substring(0, 12)}...',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4.0),
                            border: Border.all(color: statusColor),
                          ),
                          child: Text(
                            order.status.toUpperCase(),
                            style: OBTypography.overline.copyWith(color: statusColor),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8.0),
                        Text(
                          'Placed: ${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
                          style: OBTypography.caption.copyWith(color: OBColors.neutral500),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'Items: ${order.items.length}',
                          style: OBTypography.body.copyWith(
                            color: isDark ? OBColors.neutral300 : OBColors.neutral700,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'Total: ₹${order.total.toStringAsFixed(2)}',
                          style: OBTypography.body.copyWith(
                            color: OBColors.primary500,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              },
            ),
    );
  }
}
