import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/text_fields.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;
  String? _generalError;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool _validate() {
    bool isValid = true;
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (name.isEmpty) {
      setState(() => _nameError = 'Full name is required.');
      isValid = false;
    } else {
      setState(() => _nameError = null);
    }

    if (email.isEmpty) {
      setState(() => _emailError = 'Email is required.');
      isValid = false;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() => _emailError = 'Enter a valid email address.');
      isValid = false;
    } else {
      setState(() => _emailError = null);
    }

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

  Future<void> _handleRegister() async {
    if (!_validate()) return;

    setState(() {
      _isLoading = true;
      _generalError = null;
    });

    try {
      // Simulate registry delay or check email uniqueness mock logic
      if (_emailController.text.trim().toLowerCase() == 'priya@gmail.com') {
        throw Exception('An account with this email already exists. Try logging in instead.');
      }

      await ref.read(authProvider.notifier).register(
            _nameController.text.trim(),
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
      
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _generalError = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: OBSpacing.space6, vertical: OBSpacing.space4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Account',
                style: OBTypography.displayL.copyWith(
                  color: isDark ? Colors.white : OBColors.neutral800,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: OBSpacing.space2),
              Text(
                'Register with email & password to start placing orders.',
                style: OBTypography.body.copyWith(
                  color: OBColors.neutral500,
                ),
              ),
              const SizedBox(height: OBSpacing.space6),
              if (_generalError != null) ...[
                Container(
                  padding: const EdgeInsets.all(OBSpacing.space3),
                  decoration: BoxDecoration(
                    color: OBColors.errorBg,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: OBColors.error),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: OBColors.error),
                      const SizedBox(width: OBSpacing.space2),
                      Expanded(
                        child: Text(
                          _generalError!,
                          style: OBTypography.caption.copyWith(color: OBColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: OBSpacing.space4),
              ],
              OBTextField(
                label: 'Full Name',
                hintText: 'e.g. Priya Sharma',
                prefixIcon: Icons.person_outline,
                controller: _nameController,
                errorText: _nameError,
                isEnabled: !_isLoading,
              ),
              const SizedBox(height: OBSpacing.space4),
              OBTextField(
                label: 'Email Address',
                hintText: 'e.g. priya@gmail.com',
                prefixIcon: Icons.email_outlined,
                controller: _emailController,
                errorText: _emailError,
                keyboardType: TextInputType.emailAddress,
                isEnabled: !_isLoading,
              ),
              const SizedBox(height: OBSpacing.space4),
              OBPasswordField(
                label: 'Password',
                hintText: 'At least 8 characters',
                controller: _passwordController,
                errorText: _passwordError,
                isEnabled: !_isLoading,
              ),
              const SizedBox(height: OBSpacing.space4),
              OBPasswordField(
                label: 'Confirm Password',
                hintText: 'Repeat password',
                controller: _confirmController,
                errorText: _confirmError,
                isEnabled: !_isLoading,
              ),
              const SizedBox(height: OBSpacing.space6),
              OBButton(
                text: 'Create Account',
                onPressed: _isLoading ? null : _handleRegister,
                isLoading: _isLoading,
                isFullWidth: true,
              ),
              const SizedBox(height: OBSpacing.space6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: OBTypography.body.copyWith(color: OBColors.neutral500),
                  ),
                  GestureDetector(
                    onTap: _isLoading ? null : () => context.pop(),
                    child: Text(
                      'Log In',
                      style: OBTypography.body.copyWith(
                        color: OBColors.primary500,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
