import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../theme/spacing.dart';
import '../theme/shadows.dart';

enum OBButtonVariant { primary, secondary, outlined, ghost, danger, success, text }
enum OBButtonSize { small, medium, large }

class OBButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final OBButtonVariant variant;
  final OBButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  const OBButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = OBButtonVariant.primary,
    this.size = OBButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  @override
  State<OBButton> createState() => _OBButtonState();
}

class _OBButtonState extends State<OBButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isEnabled = widget.onPressed != null && !widget.isLoading;

    // Resolve Button Sizing Properties
    final double height = switch (widget.size) {
      OBButtonSize.small => 36.0,
      OBButtonSize.medium => 48.0,
      OBButtonSize.large => 56.0,
    };

    final double horizontalPadding = switch (widget.size) {
      OBButtonSize.small => OBSpacing.space3,
      OBButtonSize.medium => OBSpacing.space5,
      OBButtonSize.large => OBSpacing.space6,
    };

    final double borderRadiusVal = switch (widget.size) {
      OBButtonSize.small => 10.0,
      OBButtonSize.medium => 14.0,
      OBButtonSize.large => 18.0,
    };

    final BorderRadius borderRadius = BorderRadius.circular(borderRadiusVal);

    // Resolve Text and Icon Colors
    Color getTextColor() {
      if (!isEnabled) {
        return isDark ? Colors.white30 : OBColors.neutral400;
      }
      return switch (widget.variant) {
        OBButtonVariant.primary => isDark ? const Color(0xFFC1C9FF) : OBColors.primary500,
        OBButtonVariant.secondary => isDark ? Colors.white : OBColors.neutral800,
        OBButtonVariant.outlined => isDark ? Colors.white : OBColors.neutral800,
        OBButtonVariant.ghost => isDark ? const Color(0xFFC1C9FF) : OBColors.primary500,
        OBButtonVariant.danger => isDark ? const Color(0xFFEF5350) : OBColors.error,
        OBButtonVariant.success => isDark ? const Color(0xFF81C784) : OBColors.success,
        OBButtonVariant.text => isDark ? const Color(0xFFC1C9FF) : OBColors.primary500,
      };
    }

    final Color contentColor = getTextColor();

    // Resolve Button Decoration (Gradient or Solid Background)
    Decoration getDecoration() {
      if (!isEnabled) {
        return BoxDecoration(
          color: isDark ? const Color(0xFF252528) : OBColors.neutral200,
          borderRadius: borderRadius,
        );
      }

      // Tactile Neomorphic Shadows (pure neomorphism)
      List<BoxShadow> shadows = [];
      if (widget.variant != OBButtonVariant.text && widget.variant != OBButtonVariant.ghost) {
        shadows = OBShadows.neomorphic(
          level: 2,
          isDarkMode: isDark,
          pressed: _isPressed,
        );
      }

      switch (widget.variant) {
        case OBButtonVariant.primary:
        case OBButtonVariant.secondary:
        case OBButtonVariant.danger:
        case OBButtonVariant.success:
          return BoxDecoration(
            color: isDark ? const Color(0xFF2C2722) : OBColors.neutral100,
            borderRadius: borderRadius,
            boxShadow: shadows,
            border: Border.all(
              color: isDark ? Colors.white10 : OBColors.neutral200,
              width: 1.0,
            ),
          );
        case OBButtonVariant.outlined:
          return BoxDecoration(
            color: Colors.transparent,
            borderRadius: borderRadius,
            border: Border.all(
              color: isDark ? Colors.white12 : OBColors.neutral300,
              width: 1.0,
            ),
          );
        case OBButtonVariant.ghost:
        case OBButtonVariant.text:
          return BoxDecoration(
            color: Colors.transparent,
            borderRadius: borderRadius,
          );
      }
    }

    // Build Loading Indicator or Main Button Child
    Widget buttonContent = AnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      child: widget.isLoading
          ? _MinimalSpinner(color: contentColor)
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    size: widget.size == OBButtonSize.small ? 15.0 : 18.0,
                    color: contentColor,
                  ),
                  const SizedBox(width: 8.0),
                ],
                Text(
                  widget.text,
                  style: OBTypography.button.copyWith(
                    color: contentColor,
                    fontSize: widget.size == OBButtonSize.small ? 12.5 : 14.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                    height: 1.2,
                  ),
                ),
              ],
            ),
    );

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: widget.text,
      child: GestureDetector(
        onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: isEnabled ? (_) {
          setState(() => _isPressed = false);
          widget.onPressed?.call();
        } : null,
        onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: Container(
            height: height,
            width: widget.isFullWidth ? double.infinity : null,
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            decoration: getDecoration(),
            child: Center(child: buttonContent),
          ),
        ),
      ),
    );
  }
}

class _MinimalSpinner extends StatefulWidget {
  final Color color;
  const _MinimalSpinner({required this.color});

  @override
  State<_MinimalSpinner> createState() => _MinimalSpinnerState();
}

class _MinimalSpinnerState extends State<_MinimalSpinner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: SizedBox(
        width: 16.0,
        height: 16.0,
        child: CircularProgressIndicator(
          strokeWidth: 1.5,
          valueColor: AlwaysStoppedAnimation<Color>(widget.color),
        ),
      ),
    );
  }
}
