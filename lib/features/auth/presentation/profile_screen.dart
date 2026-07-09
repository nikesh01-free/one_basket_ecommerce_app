import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/buttons.dart';
import '../../wishlist/presentation/wishlist_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Local states for preferences toggle switches
  bool _notificationsEnabled = true;
  bool _faceIdEnabled = false;

  // Retrieve a dynamic greeting based on system hour
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning 👋';
    if (hour < 17) return 'Good Afternoon ☀️';
    return 'Good Evening 🌙';
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final themeMode = ref.watch(themeModeProvider);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    // Core Neomorphic Color System
    final Color backgroundColor = isDark
        ? const Color(0xFF181818)
        : const Color(0xFFF6F7F9);
    final Color surfaceColor = isDark
        ? const Color(0xFF242424)
        : const Color(0xFFFBFBFC);

    // Dynamic stats (mocked or loaded from providers)
    final wishlist = ref.watch(wishlistProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dynamic greeting
              Text(
                _getGreeting(),
                style: const TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 20.0),

              if (user == null) ...[
                // Guest profile placeholder screen
                _buildGuestMode(context, surfaceColor, isDark),
              ] else ...[
                // Profile header block
                ProfileHeader(
                  fullName: user.fullName,
                  email:
                      '${user.fullName.toLowerCase().replaceAll(' ', '')}@gmail.com',
                  phone: user.phoneNumber?.isNotEmpty == true
                      ? user.phoneNumber!
                      : 'No phone linked',
                  role: user.role,
                  surfaceColor: surfaceColor,
                  isDark: isDark,
                ),
                const SizedBox(height: 20.0),

                // Statistics Card
                StatsCard(
                  surfaceColor: surfaceColor,
                  isDark: isDark,
                  ordersCount: 12, // Mocked overall orders
                  wishlistCount: wishlist.length,
                  addressesCount: 3, // Mocked delivery locations
                  pointsCount: 240, // Mocked loyalty reward points
                ),
                const SizedBox(height: 24.0),

                // Quick Actions grid
                _buildSectionHeader('Quick Actions', isDark),
                const SizedBox(height: 12.0),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 14.0,
                  mainAxisSpacing: 14.0,
                  childAspectRatio: 1.35,
                  children: [
                    QuickActionCard(
                      icon: Icons.receipt_long_outlined,
                      title: 'Orders',
                      subtitle: 'Track status',
                      surfaceColor: surfaceColor,
                      isDark: isDark,
                      onTap: () => context.push('/profile/orders'),
                    ),
                    QuickActionCard(
                      icon: Icons.favorite_border_outlined,
                      title: 'Wishlist',
                      subtitle: 'Saved items',
                      surfaceColor: surfaceColor,
                      isDark: isDark,
                      onTap: () => context.push('/home/products'),
                    ),
                    QuickActionCard(
                      icon: Icons.confirmation_number_outlined,
                      title: 'Coupons',
                      subtitle: 'Active savings',
                      surfaceColor: surfaceColor,
                      isDark: isDark,
                      onTap: () {},
                    ),
                    QuickActionCard(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Wallet',
                      subtitle: 'Verify balance',
                      surfaceColor: surfaceColor,
                      isDark: isDark,
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),

                // Account Lists
                ProfileSection(
                  title: 'Account Settings',
                  isDark: isDark,
                  children: [
                    SettingsTile(
                      icon: Icons.location_on_outlined,
                      title: 'Saved Addresses',
                      subtitle: 'Manage delivery destinations',
                      isDark: isDark,
                      onTap: () => context.push('/profile/addresses'),
                    ),
                    SettingsTile(
                      icon: Icons.credit_card_outlined,
                      title: 'Saved Cards',
                      subtitle: 'UPI & Card setups',
                      isDark: isDark,
                      onTap: () {},
                    ),
                    SettingsTile(
                      icon: Icons.history_outlined,
                      title: 'Recently Viewed',
                      subtitle: 'Items you clicked recently',
                      isDark: isDark,
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),

                // Preferences switches
                ProfileSection(
                  title: 'App Preferences',
                  isDark: isDark,
                  children: [
                    // Dynamic Dark Mode Switch Tile
                    SettingsTile(
                      icon: isDark
                          ? Icons.wb_sunny_outlined
                          : Icons.dark_mode_outlined,
                      title: 'Dark Mode',
                      subtitle: 'Enable low brightness theme',
                      isDark: isDark,
                      trailing: Switch.adaptive(
                        value: themeMode == ThemeMode.dark,
                        activeTrackColor: OBColors.primary500,
                        onChanged: (bool val) {
                          ref.read(themeModeProvider.notifier).state = val
                              ? ThemeMode.dark
                              : ThemeMode.light;
                        },
                      ),
                    ),
                    SettingsTile(
                      icon: Icons.notifications_none_outlined,
                      title: 'Push Notifications',
                      subtitle: 'Alerts and campaign updates',
                      isDark: isDark,
                      trailing: Switch.adaptive(
                        value: _notificationsEnabled,
                        activeTrackColor: OBColors.primary500,
                        onChanged: (bool val) {
                          setState(() => _notificationsEnabled = val);
                        },
                      ),
                    ),
                    SettingsTile(
                      icon: Icons.fingerprint_outlined,
                      title: 'Biometric Access',
                      subtitle: 'Enable Face ID or Fingerprint',
                      isDark: isDark,
                      trailing: Switch.adaptive(
                        value: _faceIdEnabled,
                        activeTrackColor: OBColors.primary500,
                        onChanged: (bool val) {
                          setState(() => _faceIdEnabled = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),

                // Support links
                ProfileSection(
                  title: 'Support & Help',
                  isDark: isDark,
                  children: [
                    SettingsTile(
                      icon: Icons.help_outline_outlined,
                      title: 'Help Center',
                      subtitle: 'FAQs & troubleshooting',
                      isDark: isDark,
                      onTap: () {},
                    ),
                    SettingsTile(
                      icon: Icons.chat_bubble_outline_outlined,
                      title: 'Chat Support',
                      subtitle: 'Talk to an agent instantly',
                      isDark: isDark,
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),

                // Danger zone section
                LogoutCard(
                  surfaceColor: surfaceColor,
                  isDark: isDark,
                  onLogout: () async {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                ),
                const SizedBox(
                  height: 60.0,
                ), // Padding to avoid clipping above bottom nav
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Section heading title
  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : const Color(0xFF1E1E1E),
      ),
    );
  }

  // Guest Mode Call to Action Widget
  Widget _buildGuestMode(
    BuildContext context,
    Color surfaceColor,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: OBShadows.neomorphic(level: 3, isDarkMode: isDark),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1917) : OBColors.neutral100,
              shape: BoxShape.circle,
              boxShadow: OBShadows.neomorphic(
                level: 1,
                isDarkMode: isDark,
                pressed: true,
              ),
            ),
            child: const Icon(
              Icons.account_circle_outlined,
              size: 72.0,
              color: OBColors.primary500,
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            'Log In to Your Account',
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 8.0),
          const Text(
            'Unlock dynamic order tracking, saved address sheets, payment vault, and special Amdavadi fresh loyalty rewards.',
            style: TextStyle(
              fontSize: 13.0,
              color: OBColors.neutral500,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24.0),
          OBButton(
            text: 'Sign In / Register',
            onPressed: () => context.go('/login'),
            isFullWidth: true,
            size: OBButtonSize.large,
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------------
// Reusable Component Classes (Sub-widgets)
// --------------------------------------------------------------------

// 1. Profile Header
class ProfileHeader extends StatelessWidget {
  final String fullName;
  final String email;
  final String phone;
  final String role;
  final Color surfaceColor;
  final bool isDark;

  const ProfileHeader({
    super.key,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.surfaceColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: OBShadows.neomorphic(level: 3, isDarkMode: isDark),
      ),
      child: Column(
        children: [
          // 120x120 Neomorphic circle image container
          Stack(
            children: [
              Hero(
                tag: 'avatar_hero',
                child: Container(
                  width: 120.0,
                  height: 120.0,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1C1917)
                        : OBColors.neutral100,
                    shape: BoxShape.circle,
                    boxShadow: OBShadows.neomorphic(
                      level: 2,
                      isDarkMode: isDark,
                      pressed: true,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      fullName.isNotEmpty
                          ? fullName.substring(0, 1).toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontFamily: OBTypography.headingFont,
                        fontWeight: FontWeight.bold,
                        fontSize: 48.0,
                        color: OBColors.primary500,
                      ),
                    ),
                  ),
                ),
              ),
              // Floating Glassmorphism Camera Button (bottom right)
              Positioned(
                bottom: 2.0,
                right: 2.0,
                child: Container(
                  width: 34.0,
                  height: 34.0,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black45
                        : Colors.white.withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.white60,
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 4.0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.camera_alt_outlined,
                      size: 16.0,
                      color: OBColors.primary500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),

          // User Name & Role badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                fullName,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(width: 8.0),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 3.5,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: const Text(
                  'GOLD MEMBER',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4.0),

          // Contact Details
          Text(
            email,
            style: const TextStyle(fontSize: 13.0, color: OBColors.neutral500),
          ),
          const SizedBox(height: 2.0),
          Text(
            phone,
            style: const TextStyle(fontSize: 13.0, color: OBColors.neutral500),
          ),
        ],
      ),
    );
  }
}

// 2. Stats Card
class StatsCard extends StatelessWidget {
  final Color surfaceColor;
  final bool isDark;
  final int ordersCount;
  final int wishlistCount;
  final int addressesCount;
  final int pointsCount;

  const StatsCard({
    super.key,
    required this.surfaceColor,
    required this.isDark,
    required this.ordersCount,
    required this.wishlistCount,
    required this.addressesCount,
    required this.pointsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: OBShadows.neomorphic(level: 3, isDarkMode: isDark),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            Icons.local_shipping_outlined,
            ordersCount.toString(),
            'Orders',
          ),
          _buildVerticalDivider(),
          _buildStatItem(
            Icons.favorite_border_outlined,
            wishlistCount.toString(),
            'Wishlist',
          ),
          _buildVerticalDivider(),
          _buildStatItem(
            Icons.location_on_outlined,
            addressesCount.toString(),
            'Addresses',
          ),
          _buildVerticalDivider(),
          _buildStatItem(
            Icons.stars_outlined,
            pointsCount.toString(),
            'Points',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 20.0, color: OBColors.primary500),
        const SizedBox(height: 6.0),
        Text(
          value,
          style: const TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10.0,
            color: OBColors.neutral500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1.0,
      height: 36.0,
      color: isDark ? Colors.white10 : OBColors.neutral200,
    );
  }
}

// 3. Quick Action Grid Card
class QuickActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color surfaceColor;
  final bool isDark;
  final VoidCallback onTap;

  const QuickActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.surfaceColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<QuickActionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: widget.surfaceColor,
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: OBShadows.neomorphic(
              level: 2,
              isDarkMode: widget.isDark,
              pressed: _isPressed,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: widget.isDark
                          ? const Color(0xFF1C1917)
                          : OBColors.neutral100,
                      shape: BoxShape.circle,
                      boxShadow: OBShadows.neomorphic(
                        level: 1,
                        isDarkMode: widget.isDark,
                        pressed: true,
                      ),
                    ),
                    child: Icon(
                      widget.icon,
                      size: 18.0,
                      color: OBColors.primary500,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 16.0,
                    color: widget.isDark ? Colors.white30 : OBColors.neutral400,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    widget.subtitle,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: OBColors.neutral500,
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

// 4. Profile Section Wrapper (Combines tiles into rounded neomorphic plates)
class ProfileSection extends StatelessWidget {
  final String title;
  final bool isDark;
  final List<Widget> children;

  const ProfileSection({
    super.key,
    required this.title,
    required this.isDark,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final Color surfaceColor = isDark
        ? const Color(0xFF242424)
        : const Color(0xFFFBFBFC);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15.0,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : OBColors.neutral700,
          ),
        ),
        const SizedBox(height: 10.0),
        Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(24.0),
            boxShadow: OBShadows.neomorphic(level: 3, isDarkMode: isDark),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

// 5. Settings Tile (Tile components inside section wrapper)
class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C1917) : OBColors.neutral100,
                  shape: BoxShape.circle,
                  boxShadow: OBShadows.neomorphic(
                    level: 1,
                    isDarkMode: isDark,
                    pressed: true,
                  ),
                ),
                child: Icon(icon, size: 18.0, color: OBColors.primary500),
              ),
              const SizedBox(width: 14.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: OBColors.neutral500,
                      ),
                    ),
                  ],
                ),
              ),
              trailing ??
                  Icon(
                    Icons.chevron_right,
                    size: 18.0,
                    color: isDark ? Colors.white30 : OBColors.neutral400,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

// 6. Logout / Danger Card
class LogoutCard extends StatefulWidget {
  final Color surfaceColor;
  final bool isDark;
  final VoidCallback onLogout;

  const LogoutCard({
    super.key,
    required this.surfaceColor,
    required this.isDark,
    required this.onLogout,
  });

  @override
  State<LogoutCard> createState() => _LogoutCardState();
}

class _LogoutCardState extends State<LogoutCard> {
  bool _isPressed = false;

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: widget.isDark
              ? const Color(0xFF242424)
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out of OneBasket?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: OBColors.neutral500),
              ),
            ),
            OBButton(
              text: 'Log Out',
              variant: OBButtonVariant.danger,
              size: OBButtonSize.small,
              onPressed: () {
                Navigator.pop(context);
                widget.onLogout();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _showLogoutDialog(context);
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          decoration: BoxDecoration(
            color: widget.surfaceColor,
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: OBShadows.neomorphic(
              level: 2,
              isDarkMode: widget.isDark,
              pressed: _isPressed,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? const Color(0xFF3E1E1E)
                      : const Color(0xFFFFEBEE),
                  shape: BoxShape.circle,
                  boxShadow: OBShadows.neomorphic(
                    level: 1,
                    isDarkMode: widget.isDark,
                    pressed: true,
                  ),
                ),
                child: const Icon(
                  Icons.logout_outlined,
                  size: 18.0,
                  color: OBColors.error,
                ),
              ),
              const SizedBox(width: 14.0),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Log Out',
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: OBColors.error,
                      ),
                    ),
                    SizedBox(height: 2.0),
                    Text(
                      'Safely sign out of this account',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: OBColors.neutral500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 18.0,
                color: OBColors.error,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
