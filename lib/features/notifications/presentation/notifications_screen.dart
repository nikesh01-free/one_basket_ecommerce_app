import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/radius.dart';
import '../../../core/theme/shadows.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final mockNotifications = [
      {
        'title': 'Order Delivered 🚚',
        'desc': 'Your order ID order_1234567890 has been successfully delivered to Vastrapur.',
        'time': '2 hours ago',
        'icon': Icons.local_shipping_outlined,
        'color': OBColors.success,
      },
      {
        'title': 'Order Shipped 📦',
        'desc': 'Your local grocery items are in transit. Expect delivery within 1 hour.',
        'time': '4 hours ago',
        'icon': Icons.local_mall_outlined,
        'color': OBColors.primary500,
      },
      {
        'title': 'Order Confirmed ✅',
        'desc': 'Your order has been verified by the Ahmedabad offline store manager.',
        'time': '5 hours ago',
        'icon': Icons.verified_outlined,
        'color': OBColors.info,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(
          left: OBSpacing.space4,
          right: OBSpacing.space4,
          top: OBSpacing.space3,
          bottom: 100.0,
        ),
        itemCount: mockNotifications.length,
        itemBuilder: (context, index) {
          final notif = mockNotifications[index];
          final color = notif['color'] as Color;

          return Container(
            margin: const EdgeInsets.only(bottom: OBSpacing.space3),
            padding: const EdgeInsets.all(OBSpacing.space3),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2722) : OBColors.neutral100,
              borderRadius: OBRadius.md,
              boxShadow: OBShadows.neomorphic(level: 1, isDarkMode: isDark),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20.0,
                  backgroundColor: color.withValues(alpha: 0.1),
                  child: Icon(notif['icon'] as IconData, color: color, size: 20.0),
                ),
                const SizedBox(width: OBSpacing.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            notif['title'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            notif['time'] as String,
                            style: OBTypography.caption.copyWith(color: OBColors.neutral400, fontSize: 10.0),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        notif['desc'] as String,
                        style: OBTypography.body.copyWith(
                          fontSize: 12.0,
                          color: isDark ? OBColors.neutral400 : OBColors.neutral600,
                        ),
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
