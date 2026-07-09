import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/text_fields.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _passwordError;
  String? _confirmError;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool _validate() {
    bool isValid = true;
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (password.isEmpty) {
      setState(() => _passwordError = 'Password is required.');
      isValid = false;
    } else if (password.length < 8) {
      setState(() => _passwordError = 'Password must be at least 8 characters.');
      isValid = false;
    } else {
      setState(() => _passwordError = null);
    }

    if (confirm.isEmpty) {
      setState(() => _confirmError = 'Confirm password is required.');
      isValid = false;
    } else if (password != confirm) {
      setState(() => _confirmError = 'Passwords do not match.');
      isValid = false;
    } else {
      setState(() => _confirmError = null);
    }

    return isValid;
  }

  Future<void> _handleSave() async {
    if (!_validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(authProvider.notifier).changePassword(_passwordController.text.trim());
      setState(() {
        _isLoading = false;
      });
      _passwordController.clear();
      _confirmController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to change password: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security & Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(OBSpacing.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Change Password',
              style: OBTypography.subtitle.copyWith(
                color: isDark ? Colors.white : OBColors.neutral800,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: OBSpacing.space2),
            Text(
              'Enter a new password below. It must be at least 8 characters long.',
              style: OBTypography.body.copyWith(color: OBColors.neutral500),
            ),
            const SizedBox(height: OBSpacing.space6),
            OBPasswordField(
              label: 'New Password',
              hintText: 'Minimum 8 characters',
              controller: _passwordController,
              errorText: _passwordError,
              isEnabled: !_isLoading,
            ),
            const SizedBox(height: OBSpacing.space3),
            OBPasswordField(
              label: 'Confirm New Password',
              hintText: 'Repeat new password',
              controller: _confirmController,
              errorText: _confirmError,
              isEnabled: !_isLoading,
            ),
            const SizedBox(height: OBSpacing.space8),
            OBButton(
              text: 'Update Password',
              onPressed: _isLoading ? null : _handleSave,
              isLoading: _isLoading,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}
