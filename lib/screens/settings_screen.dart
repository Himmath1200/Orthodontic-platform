import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<AuthProvider>(
        builder: (_, auth, __) {
          final user = auth.currentUser;
          return CustomScrollView(
            slivers: [
              // ── Gradient header with profile
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                backgroundColor: AppColors.primaryDark,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(gradient: AppGradients.heroGradient),
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Avatar
                        Container(
                          width: 72, height: 72,
                          decoration: BoxDecoration(
                            gradient: AppGradients.tealGradient,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.3), width: 3),
                            boxShadow: [
                              BoxShadow(color: AppColors.secondary.withOpacity(0.4), blurRadius: 20),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              (user?.name.isNotEmpty ?? false) ? user!.name[0].toUpperCase() : 'U',
                              style: const TextStyle(color: Colors.white, fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w800, fontSize: 28),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(user?.name ?? 'User',
                            style: const TextStyle(color: Colors.white, fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700, fontSize: 18)),
                        const SizedBox(height: 4),
                        Text(user?.email ?? '',
                            style: TextStyle(color: Colors.white.withOpacity(0.65),
                                fontFamily: 'Poppins', fontSize: 12)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(_roleIcon(user?.role), size: 12, color: AppColors.secondaryPale),
                            const SizedBox(width: 6),
                            Text(
                              (user?.role.name ?? 'user').toUpperCase(),
                              style: const TextStyle(color: AppColors.secondaryPale,
                                  fontFamily: 'Poppins', fontWeight: FontWeight.w700,
                                  fontSize: 10, letterSpacing: 1),
                            ),
                          ]),
                        ),
                      ],
                    ),
                  ),
                  title: const Text('Settings',
                      style: TextStyle(color: Colors.white, fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700, fontSize: 17)),
                  collapseMode: CollapseMode.parallax,
                ),
              ),

              // ── Settings body
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([

                    // ── Profile Details section
                    _SectionLabel(label: 'ACCOUNT'),
                    const SizedBox(height: 8),
                    _SettingsCard(children: [
                      _InfoTile(
                        icon: Icons.person_rounded,
                        iconColor: AppColors.primary,
                        label: 'Full Name',
                        value: user?.name ?? 'N/A',
                      ),
                      const _Divider(),
                      _InfoTile(
                        icon: Icons.email_rounded,
                        iconColor: AppColors.info,
                        label: 'Email Address',
                        value: user?.email ?? 'N/A',
                      ),
                      const _Divider(),
                      _InfoTile(
                        icon: Icons.badge_rounded,
                        iconColor: AppColors.accent,
                        label: 'Role',
                        value: (user?.role.name ?? 'N/A')
                            .replaceFirst(user?.role.name[0] ?? '', (user?.role.name[0] ?? '').toUpperCase()),
                        valueWidget: _RoleBadge(role: user?.role),
                      ),
                    ]),

                    const SizedBox(height: 20),

                    // ── Appearance section
                    _SectionLabel(label: 'APPEARANCE'),
                    const SizedBox(height: 8),
                    _SettingsCard(children: [
                      Consumer<ThemeProvider>(
                        builder: (_, theme, __) => _ToggleTile(
                          icon: theme.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                          iconColor: theme.isDarkMode ? const Color(0xFF6366F1) : AppColors.warningLight,
                          label: 'Dark Mode',
                          subtitle: theme.isDarkMode ? 'Night theme active' : 'Day theme active',
                          value: theme.isDarkMode,
                          onChanged: (_) => theme.toggleTheme(),
                        ),
                      ),
                    ]),

                    const SizedBox(height: 20),

                    // ── Notifications section
                    _SectionLabel(label: 'NOTIFICATIONS'),
                    const SizedBox(height: 8),
                    _SettingsCard(children: [
                      _ToggleTile(
                        icon: Icons.notifications_rounded,
                        iconColor: AppColors.secondary,
                        label: 'Push Notifications',
                        subtitle: 'Case updates & reminders',
                        value: true,
                        onChanged: (_) {},
                      ),
                      const _Divider(),
                      _ToggleTile(
                        icon: Icons.email_rounded,
                        iconColor: AppColors.info,
                        label: 'Email Reports',
                        subtitle: 'Weekly analysis summaries',
                        value: false,
                        onChanged: (_) {},
                      ),
                    ]),

                    const SizedBox(height: 20),

                    // ── Security section
                    _SectionLabel(label: 'SECURITY'),
                    const SizedBox(height: 8),
                    _SettingsCard(children: [
                      _ActionTile(
                        icon: Icons.lock_reset_rounded,
                        iconColor: AppColors.warning,
                        label: 'Change Password',
                        subtitle: 'Update your account password',
                        onTap: () => Navigator.of(context).pushNamed('/forgot-password'),
                      ),
                      const _Divider(),
                      _ActionTile(
                        icon: Icons.security_rounded,
                        iconColor: AppColors.success,
                        label: 'Two-Factor Authentication',
                        subtitle: 'Add an extra layer of security',
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.info.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('Soon', style: TextStyle(color: AppColors.info,
                              fontFamily: 'Poppins', fontSize: 9, fontWeight: FontWeight.w700)),
                        ),
                        onTap: () {},
                      ),
                    ]),

                    const SizedBox(height: 20),

                    // ── About section
                    _SectionLabel(label: 'ABOUT'),
                    const SizedBox(height: 8),
                    _SettingsCard(children: [
                      _InfoTile(
                        icon: Icons.info_rounded,
                        iconColor: AppColors.textTertiary,
                        label: 'App Version',
                        value: '1.0.0 (Build 42)',
                      ),
                      const _Divider(),
                      _ActionTile(
                        icon: Icons.description_rounded,
                        iconColor: AppColors.textSecondary,
                        label: 'Terms & Conditions',
                        onTap: () {},
                      ),
                      const _Divider(),
                      _ActionTile(
                        icon: Icons.privacy_tip_rounded,
                        iconColor: AppColors.textSecondary,
                        label: 'Privacy Policy',
                        onTap: () {},
                      ),
                      const _Divider(),
                      _ActionTile(
                        icon: Icons.help_rounded,
                        iconColor: AppColors.info,
                        label: 'Help & Support',
                        onTap: () {},
                      ),
                    ]),

                    const SizedBox(height: 24),

                    // ── Logout button
                    _LogoutButton(auth: auth),

                    const SizedBox(height: 16),

                    // ── Danger zone
                    _SectionLabel(label: 'DANGER ZONE', color: AppColors.error),
                    const SizedBox(height: 8),
                    _SettingsCard(
                      borderColor: AppColors.error.withOpacity(0.25),
                      children: [
                        _ActionTile(
                          icon: Icons.delete_forever_rounded,
                          iconColor: AppColors.error,
                          label: 'Delete Account',
                          subtitle: 'Permanently remove your data',
                          labelColor: AppColors.error,
                          onTap: () => _confirmDeleteAccount(context, auth),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  IconData _roleIcon(UserRole? role) {
    switch (role) {
      case UserRole.doctor: return Icons.local_hospital_rounded;
      case UserRole.researcher: return Icons.science_rounded;
      case UserRole.admin: return Icons.admin_panel_settings_rounded;
      default: return Icons.person_rounded;
    }
  }

  Future<void> _confirmDeleteAccount(BuildContext context, AuthProvider auth) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Account',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
        content: const Text(
            'This will permanently delete your account and all associated data. This action cannot be undone.',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 14, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(fontFamily: 'Poppins')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            child: const Text('Delete', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await auth.deleteAccount();
    }
  }
}

// ── Logout button
class _LogoutButton extends StatelessWidget {
  final AuthProvider auth;
  const _LogoutButton({required this.auth});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Sign Out',
                style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
            content: const Text('Are you sure you want to sign out?',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 14)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel', style: TextStyle(fontFamily: 'Poppins')),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                child: const Text('Sign Out',
                    style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        );
        if (confirmed == true && context.mounted) {
          await auth.signOut();
          if (context.mounted) {
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/login', (route) => false);
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: AppGradients.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 16, offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          const Text('Sign Out',
              style: TextStyle(color: Colors.white, fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: 0.5)),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// REUSABLE SETTING COMPONENTS
// ══════════════════════════════════════════════════════════════

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _SectionLabel({required this.label, this.color = AppColors.textTertiary});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4),
    child: Text(label,
        style: TextStyle(fontFamily: 'Poppins', fontSize: 10, fontWeight: FontWeight.w700,
            color: color, letterSpacing: 1.2)),
  );
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  final Color? borderColor;
  const _SettingsCard({required this.children, this.borderColor});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: borderColor ?? AppColors.border.withOpacity(0.5)),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4)),
      ],
    ),
    child: Column(children: children),
  );
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => const Divider(
      height: 1, thickness: 1, color: AppColors.border, indent: 56);
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Widget? valueWidget;
  const _InfoTile({required this.icon, required this.iconColor,
      required this.label, required this.value, this.valueWidget});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
    child: Row(children: [
      _IconBox(icon: icon, color: iconColor),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12,
            color: AppColors.textTertiary)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14,
            fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ])),
      if (valueWidget != null) valueWidget!,
    ]),
  );
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleTile({required this.icon, required this.iconColor, required this.label,
      this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Row(children: [
      _IconBox(icon: icon, color: iconColor),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14,
            fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        if (subtitle != null)
          Text(subtitle!, style: const TextStyle(fontFamily: 'Poppins', fontSize: 11,
              color: AppColors.textTertiary)),
      ])),
      Switch(
        value: value, onChanged: onChanged,
        activeColor: AppColors.secondary,
        activeTrackColor: AppColors.secondary.withOpacity(0.3),
        inactiveThumbColor: AppColors.textTertiary,
        inactiveTrackColor: AppColors.border,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    ]),
  );
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? subtitle;
  final Color? labelColor;
  final Widget? trailing;
  final VoidCallback onTap;
  const _ActionTile({required this.icon, required this.iconColor, required this.label,
      this.subtitle, this.labelColor, this.trailing, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(children: [
        _IconBox(icon: icon, color: iconColor),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontFamily: 'Poppins', fontSize: 14,
              fontWeight: FontWeight.w600,
              color: labelColor ?? AppColors.textPrimary)),
          if (subtitle != null)
            Text(subtitle!, style: const TextStyle(fontFamily: 'Poppins', fontSize: 11,
                color: AppColors.textTertiary)),
        ])),
        trailing ?? Icon(Icons.chevron_right_rounded,
            size: 18, color: AppColors.textTertiary.withOpacity(0.6)),
      ]),
    ),
  );
}

class _RoleBadge extends StatelessWidget {
  final UserRole? role;
  const _RoleBadge({this.role});

  @override
  Widget build(BuildContext context) {
    final color = _roleColor(role);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        (role?.name ?? 'user').toUpperCase(),
        style: TextStyle(fontFamily: 'Poppins', fontSize: 10,
            fontWeight: FontWeight.w700, color: color, letterSpacing: 0.8),
      ),
    );
  }

  Color _roleColor(UserRole? r) {
    switch (r) {
      case UserRole.doctor: return AppColors.primary;
      case UserRole.researcher: return AppColors.accent;
      case UserRole.admin: return AppColors.warning;
      default: return AppColors.textSecondary;
    }
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _IconBox({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    width: 36, height: 36,
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(icon, size: 18, color: color),
  );
}
