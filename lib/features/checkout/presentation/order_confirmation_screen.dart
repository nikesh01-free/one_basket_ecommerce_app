import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/cards.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final String orderId;
  const OrderConfirmationScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(OBSpacing.space6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Large neomorphic success icon
              Container(
                width: 100.0,
                height: 100.0,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2722) : OBColors.neutral100,
                  shape: BoxShape.circle,
                  boxShadow: OBShadows.neomorphic(level: 3, isDarkMode: isDark),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: OBColors.success,
                  size: 50.0,
                ),
              ),
              const SizedBox(height: OBSpacing.space6),

              Text(
                'Order Confirmed!',
                style: OBTypography.displayL.copyWith(
                  color: isDark ? Colors.white : OBColors.neutral800,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: OBSpacing.space2),
              Text(
                'Your hyperlocal order has been received and is being prepared.',
                style: OBTypography.body.copyWith(color: OBColors.neutral500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: OBSpacing.space6),

              // Order detail card
              OBCard(
                child: Padding(
                  padding: const EdgeInsets.all(OBSpacing.space4),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Order ID:'),
                          Text(
                            orderId,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Delivery Area:'),
                          Text(
                            'Ahmedabad Only',
                            style: TextStyle(
                              color: OBColors.primary500,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Timeline:'),
                          Text(
                            '24-48 Hours Expected',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: OBSpacing.space8),

              // Action buttons
              OBButton(
                text: 'Track Order Status',
                onPressed: () {
                  context.go('/profile/order/$orderId');
                },
                isFullWidth: true,
              ),
              const SizedBox(height: OBSpacing.space3),
              OBButton(
                text: 'Continue Shopping',
                onPressed: () {
                  context.go('/home');
                },
                variant: OBButtonVariant.text,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
