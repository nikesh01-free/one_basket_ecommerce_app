import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../theme/spacing.dart';
import '../theme/radius.dart';
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

    // Resolve Size Properties
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

    // Resolve Background Color
    Color getBackgroundColor() {
      if (!isEnabled) return isDark ? const Color(0xFF2C2722) : OBColors.neutral300;
      return switch (widget.variant) {
        OBButtonVariant.primary => OBColors.primary500,
        OBButtonVariant.secondary => OBColors.primary100,
        OBButtonVariant.outlined => Colors.transparent,
        OBButtonVariant.ghost => Colors.transparent,
        OBButtonVariant.danger => OBColors.error,
        OBButtonVariant.success => OBColors.success,
        OBButtonVariant.text => Colors.transparent,
      };
    }

    // Resolve Text/Icon Color
    Color getTextColor() {
      if (!isEnabled) return OBColors.neutral400;
      return switch (widget.variant) {
        OBButtonVariant.primary => Colors.white,
        OBButtonVariant.secondary => OBColors.primary700,
        OBButtonVariant.outlined => OBColors.primary500,
        OBButtonVariant.ghost => OBColors.primary500,
        OBButtonVariant.danger => Colors.white,
        OBButtonVariant.success => Colors.white,
        OBButtonVariant.text => OBColors.primary500,
      };
    }

    // Resolve Neomorphic Shadows
    List<BoxShadow> getShadows() {
      if (!isEnabled || widget.variant == OBButtonVariant.text || widget.variant == OBButtonVariant.ghost) {
        return const [];
      }
      return OBShadows.neomorphic(level: 2, isDarkMode: isDark, pressed: _isPressed);
    }

    final double borderSize = (widget.variant == OBButtonVariant.outlined && isEnabled) ? 1.5 : 0.0;
    final Color borderColor = isEnabled ? OBColors.primary500 : Colors.transparent;

    Widget buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading)
          SizedBox(
            width: 18.0,
            height: 18.0,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(getTextColor()),
            ),
          )
        else ...[
          if (widget.icon != null) ...[
            Icon(widget.icon, size: widget.size == OBButtonSize.small ? 16.0 : 18.0, color: getTextColor()),
            const SizedBox(width: OBSpacing.space2),
          ],
          Text(
            widget.text,
            style: OBTypography.button.copyWith(
              color: getTextColor(),
              fontSize: widget.size == OBButtonSize.small ? 12.0 : 14.0,
            ),
          ),
        ],
      ],
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          height: height,
          width: widget.isFullWidth ? double.infinity : null,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          decoration: BoxDecoration(
            color: getBackgroundColor(),
            borderRadius: OBRadius.full,
            border: borderSize > 0 ? Border.all(color: borderColor, width: borderSize) : null,
            boxShadow: getShadows(),
          ),
          child: Center(child: buttonChild),
        ),
      ),
    );
  }
}
