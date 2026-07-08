import 'package:flutter/material.dart';
import 'buttons.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../theme/spacing.dart';

class OBEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  const OBEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(OBSpacing.space6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 72.0,
              color: isDark ? OBColors.neutral600 : OBColors.neutral400,
            ),
            const SizedBox(height: OBSpacing.space4),
            Text(
              title,
              style: OBTypography.heading2.copyWith(
                color: isDark ? Colors.white : OBColors.neutral800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: OBSpacing.space2),
            Text(
              description,
              style: OBTypography.body.copyWith(
                color: isDark ? OBColors.neutral400 : OBColors.neutral50,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onActionPressed != null) ...[
              const SizedBox(height: OBSpacing.space6),
              OBButton(
                text: actionLabel!,
                onPressed: onActionPressed!,
                variant: OBButtonVariant.primary,
                size: OBButtonSize.medium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
