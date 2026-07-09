import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../theme/spacing.dart';
import '../theme/radius.dart';

class OBTextField extends StatefulWidget {
  final String label;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool isPassword;
  final bool isReadOnly;
  final bool isEnabled;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const OBTextField({
    super.key,
    required this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.isReadOnly = false,
    this.isEnabled = true,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.onChanged,
  });

  @override
  State<OBTextField> createState() => _OBTextFieldState();
}

class _OBTextFieldState extends State<OBTextField> {
  bool _obscureText = true;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool hasError = widget.errorText != null;

    Color getBorderColor() {
      if (hasError) return OBColors.error;
      if (_isFocused) return OBColors.primary500;
      return isDark ? const Color(0xFF453E36) : OBColors.neutral300;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: OBTypography.subtitle.copyWith(
            color: hasError 
                ? OBColors.error 
                : (_isFocused ? OBColors.primary500 : (isDark ? OBColors.neutral300 : OBColors.neutral700)),
            fontSize: 12.0,
          ),
        ),
        const SizedBox(height: OBSpacing.space1),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C2722) : OBColors.neutral100,
            borderRadius: OBRadius.sm,
            border: Border.all(color: getBorderColor(), width: _isFocused || hasError ? 2.0 : 1.0),
          ),
          child: Row(
            children: [
              if (widget.prefixIcon != null)
                Padding(
                  padding: const EdgeInsets.only(left: OBSpacing.space3),
                  child: Icon(widget.prefixIcon, color: OBColors.neutral400, size: 20.0),
                ),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  keyboardType: widget.keyboardType,
                  obscureText: widget.isPassword && _obscureText,
                  readOnly: widget.isReadOnly,
                  enabled: widget.isEnabled,
                  onChanged: widget.onChanged,
                  style: OBTypography.body.copyWith(
                    color: isDark ? Colors.white : OBColors.neutral900,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: widget.hintText,
                    hintStyle: OBTypography.body.copyWith(color: OBColors.neutral400),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: OBSpacing.space3,
                      vertical: OBSpacing.space3,
                    ),
                  ),
                ),
              ),
              if (widget.isPassword)
                IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: OBColors.neutral400,
                    size: 20.0,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              else if (widget.suffixIcon != null)
                Padding(
                  padding: const EdgeInsets.only(right: OBSpacing.space3),
                  child: Icon(widget.suffixIcon, color: OBColors.neutral400, size: 20.0),
                ),
            ],
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: OBSpacing.space1, left: OBSpacing.space1),
            child: Text(
              widget.errorText!,
              style: OBTypography.caption.copyWith(color: OBColors.error),
            ),
          )
        else if (widget.helperText != null)
          Padding(
            padding: const EdgeInsets.only(top: OBSpacing.space1, left: OBSpacing.space1),
            child: Text(
              widget.helperText!,
              style: OBTypography.caption.copyWith(color: OBColors.neutral500),
            ),
          ),
      ],
    );
  }
}

// Password Field wrapper helper
class OBPasswordField extends StatelessWidget {
  final String label;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool isEnabled;

  const OBPasswordField({
    super.key,
    required this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.controller,
    this.onChanged,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return OBTextField(
      label: label,
      hintText: hintText,
      helperText: helperText,
      errorText: errorText,
      controller: controller,
      onChanged: onChanged,
      isPassword: true,
      prefixIcon: Icons.lock_outline,
      isEnabled: isEnabled,
    );
  }
}

// Search Field wrapper helper
class OBSearchField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const OBSearchField({
    super.key,
    required this.hintText,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return OBTextField(
      label: '',
      hintText: hintText,
      controller: controller,
      onChanged: onChanged,
      prefixIcon: Icons.search,
    );
  }
}
