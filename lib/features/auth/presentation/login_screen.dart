import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/widgets/buttons.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with TickerProviderStateMixin {
  // Tabs: 0 = Phone Login, 1 = Email Login
  int _activeTab = 0;

  // Controllers
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(4, (_) => FocusNode());

  // Error States
  String? _phoneError;
  String? _emailError;
  String? _passwordError;
  String? _generalError;

  // Loading & Flow State
  bool _isLoading = false;
  bool _otpSent = false;
  int _countdown = 30;
  Timer? _countdownTimer;

  // Animations Controller
  late AnimationController _entryController;
  late Animation<double> _illustrationFade;
  late Animation<double> _cardSlide;
  late Animation<double> _formFade;

  // Selected Country for phone prefix
  String _selectedPrefix = '+91';

  @override
  void initState() {
    super.initState();
    // Configure Entry animations (fade + slide up)
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _illustrationFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
    );

    _cardSlide = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(parent: _entryController, curve: const Interval(0.3, 0.9, curve: Curves.easeOutCubic)),
    );

    _formFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: const Interval(0.5, 1.0, curve: Curves.easeIn)),
    );

    _entryController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var f in _otpFocusNodes) {
      f.dispose();
    }
    _countdownTimer?.cancel();
    _entryController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _countdown = 30;
    });
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown == 0) {
        timer.cancel();
      } else {
        setState(() {
          _countdown--;
        });
      }
    });
  }

  // Handle Phone login (Mock Send OTP & Verify)
  void _handleSendOTP() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      setState(() => _phoneError = 'Enter a valid 10-digit number');
      return;
    }
    setState(() => _phoneError = null);

    setState(() {
      _isLoading = true;
    });

    // Simulate OTP sending
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _otpSent = true;
        });
        _startTimer();
      }
    });
  }

  void _handleVerifyOTP() {
    String otp = _otpControllers.map((c) => c.text).join();
    if (otp.length < 4) {
      setState(() => _generalError = 'Please enter all 4 digits');
      return;
    }
    setState(() => _generalError = null);

    setState(() {
      _isLoading = true;
    });

    // Mock verification logs in standard user
    Future.delayed(const Duration(milliseconds: 1000), () async {
      try {
        await ref.read(authProvider.notifier).login('customer@onebasket.com', 'customer123');
        if (mounted) {
          context.go('/home');
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _generalError = 'OTP verification failed';
          });
        }
      }
    });
  }

  // Handle Email login (Standard credentials calling AuthProvider)
  bool _validateEmailForm() {
    bool isValid = true;
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      setState(() => _emailError = 'Email is required');
      isValid = false;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() => _emailError = 'Enter a valid email address');
      isValid = false;
    } else {
      setState(() => _emailError = null);
    }

    if (password.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      isValid = false;
    } else if (password.length < 8) {
      setState(() => _passwordError = 'Password must be at least 8 characters');
      isValid = false;
    } else {
      setState(() => _passwordError = null);
    }

    return isValid;
  }

  Future<void> _handleEmailLogin() async {
    if (!_validateEmailForm()) return;

    setState(() {
      _isLoading = true;
      _generalError = null;
    });

    try {
      await ref.read(authProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _generalError = 'Incorrect email or password';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Soft neomorphic color palettes
    final Color backgroundColor = isDark ? const Color(0xFF181818) : const Color(0xFFF7F8FA);
    final Color surfaceColor = isDark ? const Color(0xFF242424) : const Color(0xFFFBFBFC);
    final Color textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final Color mutedColor = isDark ? const Color(0xFFA1A1AA) : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            children: [
              // Top Safe Area: Beautiful Floating Illustration (Fade transition)
              AnimatedBuilder(
                animation: _illustrationFade,
                builder: (context, child) {
                  return Opacity(
                    opacity: _illustrationFade.value,
                    child: child,
                  );
                },
                child: const LoginIllustration(),
              ),

              // Title Headline and Description text
              const SizedBox(height: 10.0),
              Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 34.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.8,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 6.0),
              Text(
                'Sign in to continue shopping fresh groceries delivered to your doorstep.',
                style: TextStyle(
                  fontSize: 14.5,
                  color: mutedColor,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24.0),

              // Neomorphic Floating Auth Card (Slides up)
              AnimatedBuilder(
                animation: _cardSlide,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0.0, _cardSlide.value),
                    child: Opacity(
                      opacity: _formFade.value,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22.0),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(26.0),
                    boxShadow: OBShadows.neomorphic(level: 3, isDarkMode: isDark),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _otpSent ? _buildOTPForm(surfaceColor, textColor, mutedColor, isDark) : _buildForms(surfaceColor, textColor, mutedColor, isDark),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),

              // Footer links
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      'Terms & Conditions',
                      style: TextStyle(fontSize: 12.0, color: mutedColor, decoration: TextDecoration.underline),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Text('•', style: TextStyle(color: mutedColor)),
                  const SizedBox(width: 16.0),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      'Privacy Policy',
                      style: TextStyle(fontSize: 12.0, color: mutedColor, decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }

  // OTP Verification view panel
  Widget _buildOTPForm(Color surfaceColor, Color textColor, Color mutedColor, bool isDark) {
    return Column(
      key: const ValueKey('otp_verification_form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => _otpSent = false),
              child: Container(
                padding: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C1917) : OBColors.neutral100,
                  shape: BoxShape.circle,
                  boxShadow: OBShadows.neomorphic(level: 1, isDarkMode: isDark),
                ),
                child: Icon(Icons.arrow_back, size: 18.0, color: textColor),
              ),
            ),
            const SizedBox(width: 12.0),
            Text(
              'Verify OTP',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: textColor),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        Text(
          'We sent a 4-digit code to $_selectedPrefix ${_phoneController.text}. Enter it below to authorize.',
          style: TextStyle(fontSize: 13.0, color: mutedColor, height: 1.4),
        ),
        const SizedBox(height: 20.0),

        if (_generalError != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: OBColors.errorBg,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: OBColors.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: OBColors.error, size: 16.0),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    _generalError!,
                    style: const TextStyle(fontSize: 11.5, color: OBColors.error),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14.0),
        ],

        // 4 OTP Boxes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(4, (index) {
            return SizedBox(
              width: 58.0,
              height: 58.0,
              child: NeomorphicTextField(
                controller: _otpControllers[index],
                focusNode: _otpFocusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                isDark: isDark,
                onChanged: (val) {
                  if (val.isNotEmpty && index < 3) {
                    _otpFocusNodes[index + 1].requestFocus();
                  } else if (val.isEmpty && index > 0) {
                    _otpFocusNodes[index - 1].requestFocus();
                  }
                  if (index == 3 && val.isNotEmpty) {
                    FocusScope.of(context).unfocus();
                  }
                },
              ),
            );
          }),
        ),
        const SizedBox(height: 20.0),

        // Countdown Timer & Resend action
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _countdown > 0 ? 'Resend code in ${_countdown}s' : 'Didn\'t receive code?',
              style: TextStyle(fontSize: 12.5, color: mutedColor),
            ),
            if (_countdown == 0)
              GestureDetector(
                onTap: _startTimer,
                child: const Text(
                  'Resend Now',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: OBColors.primary500,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 24.0),

        OBButton(
          text: 'Verify & Continue',
          onPressed: _isLoading ? null : _handleVerifyOTP,
          isLoading: _isLoading,
          isFullWidth: true,
          size: OBButtonSize.large,
        ),
      ],
    );
  }

  // Active Login forms (tabbed)
  Widget _buildForms(Color surfaceColor, Color textColor, Color mutedColor, bool isDark) {
    return Column(
      key: const ValueKey('login_options_form'),
      children: [
        // Tabs Selector (Neomorphic slider plate)
        Container(
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF181818) : OBColors.neutral200.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: OBShadows.neomorphic(level: 1, isDarkMode: isDark, pressed: true),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildTabButton(0, 'Phone Number', isDark),
              ),
              Expanded(
                child: _buildTabButton(1, 'Email ID', isDark),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24.0),

        if (_generalError != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: OBColors.errorBg,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: OBColors.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: OBColors.error, size: 16.0),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    _generalError!,
                    style: const TextStyle(fontSize: 11.5, color: OBColors.error),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
        ],

        // Input Form Builder
        if (_activeTab == 0) ...[
          // Phone Number Form
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Phone Number',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Country Flag Dropdown Picker
                  Container(
                    height: 52.0,
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1C1917) : OBColors.neutral100,
                      borderRadius: BorderRadius.circular(14.0),
                      boxShadow: OBShadows.neomorphic(level: 1, isDarkMode: isDark),
                      border: Border.all(
                        color: isDark ? Colors.white12 : OBColors.neutral200,
                        width: 1.0,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedPrefix,
                        dropdownColor: surfaceColor,
                        style: TextStyle(fontSize: 14.5, color: textColor),
                        items: const [
                          DropdownMenuItem(value: '+91', child: Text('🇮🇳 +91')),
                          DropdownMenuItem(value: '+1', child: Text('🇺🇸 +1')),
                          DropdownMenuItem(value: '+44', child: Text('🇬🇧 +44')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedPrefix = val;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  // Phone Text field input
                  Expanded(
                    child: NeomorphicTextField(
                      controller: _phoneController,
                      hintText: 'Enter 10-digit phone',
                      keyboardType: TextInputType.phone,
                      errorText: _phoneError,
                      isDark: isDark,
                      prefixIcon: Icons.phone_android_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
              OBButton(
                text: 'Send OTP',
                onPressed: _isLoading ? null : _handleSendOTP,
                isLoading: _isLoading,
                isFullWidth: true,
                size: OBButtonSize.large,
              ),
            ],
          ),
        ] else ...[
          // Email Form
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Email Address',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6.0),
              NeomorphicTextField(
                controller: _emailController,
                hintText: 'e.g. priya@gmail.com',
                prefixIcon: Icons.email_outlined,
                errorText: _emailError,
                isDark: isDark,
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Password',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6.0),
              NeomorphicTextField(
                controller: _passwordController,
                hintText: 'Enter your password',
                prefixIcon: Icons.lock_outline,
                errorText: _passwordError,
                isPassword: true,
                isDark: isDark,
              ),
              const SizedBox(height: 24.0),
              OBButton(
                text: 'Log In',
                onPressed: _isLoading ? null : _handleEmailLogin,
                isLoading: _isLoading,
                isFullWidth: true,
                size: OBButtonSize.large,
              ),
            ],
          ),
        ],

        // Divider
        const SizedBox(height: 20.0),
        Row(
          children: [
            Expanded(child: Divider(color: isDark ? Colors.white10 : OBColors.neutral200)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text('OR', style: TextStyle(fontSize: 11.5, color: mutedColor, fontWeight: FontWeight.bold)),
            ),
            Expanded(child: Divider(color: isDark ? Colors.white10 : OBColors.neutral200)),
          ],
        ),
        const SizedBox(height: 20.0),

        // Social login buttons
        Row(
          children: [
            Expanded(
              child: _buildSocialButton(
                icon: Icons.g_mobiledata_outlined,
                label: 'Google',
                isDark: isDark,
                onTap: () {},
              ),
            ),
            if (Theme.of(context).platform == TargetPlatform.iOS) ...[
              const SizedBox(width: 12.0),
              Expanded(
                child: _buildSocialButton(
                  icon: Icons.apple_outlined,
                  label: 'Apple',
                  isDark: isDark,
                  onTap: () {},
                ),
              ),
            ],
            const SizedBox(width: 12.0),
            Expanded(
              child: _buildSocialButton(
                icon: Icons.person_outline,
                label: 'Guest',
                isDark: isDark,
                onTap: () => context.go('/home'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24.0),

        // Trust Indicators
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _TrustIndicator(icon: Icons.security_outlined, label: 'Secure Login'),
            _TrustIndicator(icon: Icons.verified_user_outlined, label: '100% Privacy'),
            _TrustIndicator(icon: Icons.local_shipping_outlined, label: 'Fast Delivery'),
          ],
        ),

        // Navigation to Register Screen
        const SizedBox(height: 24.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("New to OneBasket? ", style: TextStyle(fontSize: 13.5, color: mutedColor)),
            GestureDetector(
              onTap: () => context.push('/register'),
              child: const Text(
                'Register Now',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: OBColors.primary500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Neomorphic Tab button builder
  Widget _buildTabButton(int tabIndex, String label, bool isDark) {
    final bool isActive = _activeTab == tabIndex;
    return GestureDetector(
      onTap: () => setState(() {
        _activeTab = tabIndex;
        _generalError = null;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        decoration: BoxDecoration(
          color: isActive ? (isDark ? const Color(0xFF2C2722) : OBColors.neutral100) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: isActive ? OBShadows.neomorphic(level: 1, isDarkMode: isDark) : const [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? (isDark ? Colors.white : OBColors.neutral900) : (isDark ? Colors.white38 : OBColors.neutral500),
            ),
          ),
        ),
      ),
    );
  }

  // Social round buttons builder
  Widget _buildSocialButton({required IconData icon, required String label, required bool isDark, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF242424) : OBColors.neutral100,
          borderRadius: BorderRadius.circular(14.0),
          boxShadow: OBShadows.neomorphic(level: 1, isDarkMode: isDark),
          border: Border.all(
            color: isDark ? Colors.white10 : OBColors.neutral200,
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20.0, color: isDark ? Colors.white70 : OBColors.neutral700),
            const SizedBox(width: 6.0),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.0,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : OBColors.neutral700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------
// Sub-widgets & Painters
// --------------------------------------------------------------------

// 1. Neomorphic TextField Component
class NeomorphicTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final IconData? prefixIcon;
  final String? errorText;
  final bool isPassword;
  final TextInputType keyboardType;
  final int? maxLength;
  final TextAlign textAlign;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final bool isDark;

  const NeomorphicTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.prefixIcon,
    this.errorText,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.textAlign = TextAlign.start,
    this.onChanged,
    this.focusNode,
    required this.isDark,
  });

  @override
  State<NeomorphicTextField> createState() => _NeomorphicTextFieldState();
}

class _NeomorphicTextFieldState extends State<NeomorphicTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;

    Color getBorderColor() {
      if (hasError) return OBColors.error;
      if (_isFocused) return OBColors.primary500;
      return widget.isDark ? Colors.white10 : OBColors.neutral200;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 52.0,
          decoration: BoxDecoration(
            color: widget.isDark ? const Color(0xFF1C1917) : OBColors.neutral100,
            borderRadius: BorderRadius.circular(14.0),
            boxShadow: OBShadows.neomorphic(
              level: _isFocused ? 1 : 2,
              isDarkMode: widget.isDark,
              pressed: _isFocused,
            ),
            border: Border.all(
              color: getBorderColor(),
              width: _isFocused || hasError ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              if (widget.prefixIcon != null)
                Padding(
                  padding: const EdgeInsets.only(left: 14.0),
                  child: Icon(widget.prefixIcon, color: OBColors.neutral400, size: 20.0),
                ),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  keyboardType: widget.keyboardType,
                  obscureText: widget.isPassword && _obscureText,
                  maxLength: widget.maxLength,
                  textAlign: widget.textAlign,
                  onChanged: widget.onChanged,
                  style: TextStyle(
                    fontSize: 15.5,
                    color: widget.isDark ? Colors.white : OBColors.neutral900,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    counterText: '',
                    hintText: widget.hintText,
                    hintStyle: const TextStyle(color: OBColors.neutral400),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14.0,
                      vertical: 12.0,
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
                ),
            ],
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 6.0),
            child: Text(
              widget.errorText!,
              style: const TextStyle(fontSize: 11.0, color: OBColors.error),
            ),
          ),
      ],
    );
  }
}

// 2. Trust Indicator Row Element
class _TrustIndicator extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TrustIndicator({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12.0, color: OBColors.primary500),
        const SizedBox(width: 4.0),
        Text(
          label,
          style: const TextStyle(fontSize: 10.5, color: OBColors.neutral500),
        ),
      ],
    );
  }
}

// 3. Login Header Illustration Painter (Subtle floating blobs representing fresh groceries)
class LoginIllustration extends StatelessWidget {
  const LoginIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: double.infinity,
      height: 180.0,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background soft glowing blob
          Positioned(
            child: Container(
              width: 140.0,
              height: 140.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    OBColors.primary500.withValues(alpha: isDark ? 0.08 : 0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Main shopping bag neomorphic frame
          Container(
            width: 90.0,
            height: 90.0,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2722) : OBColors.neutral100,
              shape: BoxShape.circle,
              boxShadow: OBShadows.neomorphic(level: 2, isDarkMode: isDark),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              size: 40.0,
              color: OBColors.primary500,
            ),
          ),
          // Floating leaf graphics (Apple/Nothing OS style vectors)
          Positioned(
            top: 24.0,
            right: 80.0,
            child: _buildFloatingBlob(Icons.spa_outlined, const Color(0xFF22C55E), isDark),
          ),
          Positioned(
            bottom: 24.0,
            left: 80.0,
            child: _buildFloatingBlob(Icons.delivery_dining_outlined, OBColors.primary500, isDark),
          ),
          Positioned(
            top: 50.0,
            left: 70.0,
            child: _buildFloatingBlob(Icons.wb_sunny_outlined, const Color(0xFFFBBF24), isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingBlob(IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF242424) : Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(icon, size: 16.0, color: color),
    );
  }
}
