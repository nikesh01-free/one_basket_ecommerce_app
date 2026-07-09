import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/spacing.dart';
import '../../core/theme/shadows.dart';
import '../../core/widgets/buttons.dart';

class OfflineScreen extends StatelessWidget {
  final VoidCallback onRetry;
  const OfflineScreen({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(OBSpacing.space6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100.0,
                height: 100.0,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2722) : OBColors.neutral100,
                  shape: BoxShape.circle,
                  boxShadow: OBShadows.neomorphic(level: 3, isDarkMode: isDark),
                ),
                child: const Icon(
                  Icons.wifi_off_outlined,
                  color: OBColors.error,
                  size: 48.0,
                ),
              ),
              const SizedBox(height: OBSpacing.space6),
              Text(
                'No Internet Connection',
                style: OBTypography.heading2.copyWith(
                  color: isDark ? Colors.white : OBColors.neutral800,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: OBSpacing.space2),
              Text(
                "You're offline. Please check your internet settings and try again.",
                style: OBTypography.body.copyWith(color: OBColors.neutral500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: OBSpacing.space8),
              OBButton(
                text: 'Retry Connection',
                onPressed: onRetry,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
