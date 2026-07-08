import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  UserRole _selectedRole = UserRole.doctor;
  // Patient login removed — patients are entered by researchers and assigned to doctors

  late AnimationController _entranceCtrl;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..forward();
    _fadeIn = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut);
    _slideUp =
        Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _entranceCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.signIn(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      mockRole: _selectedRole,
    );
    if (!ok || !mounted) return;

    final userRole = auth.currentUser?.role;

    // Reject if the account's role doesn't match the selected tab
    if (userRole != null && userRole != _selectedRole) {
      await auth.signOut();
      if (!mounted) return;
      final correctTab = userRole == UserRole.researcher ? 'Researcher' : 'Doctor';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.block_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'This account is registered as a ${userRole.name.toUpperCase()}. '
              'Please switch to the $correctTab tab.',
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 12),
            ),
          ),
        ]),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ));
      return;
    }

    Navigator.of(context).pushReplacementNamed(
      userRole == UserRole.researcher ? '/researcher' : '/dashboard',
    );
  }

  Future<void> _handleGoogleSignIn() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isFirebaseMode) {
      await _demoGoogleSignIn(auth);
      return;
    }
    final ok = await auth.signInWithGoogle();
    if (ok && mounted) {
      final role = auth.currentUser?.role;
      Navigator.of(context).pushReplacementNamed(
        role == UserRole.researcher ? '/researcher' : '/dashboard',
      );
    } else if (!ok && mounted) {
      // Google Sign-In not configured on this platform (e.g. web without clientId)
      final err = auth.errorMessage ?? '';
      if (err.contains('google_not_configured') || err.contains('ClientID') || err.contains('clientId')) {
        auth.clearError();
        await _demoGoogleSignIn(auth);
      }
    }
  }

  Future<void> _demoGoogleSignIn(AuthProvider auth) async {
    final ok = await auth.signInDemoGoogle(role: _selectedRole);
    if (!ok || !mounted) return;
    final name = _selectedRole == UserRole.researcher ? 'Demo Researcher' : 'Dr. Demo User';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Container(
          width: 22, height: 22,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: const Center(child: Text('G',
              style: TextStyle(color: Color(0xFF4285F4),
                  fontWeight: FontWeight.w900, fontSize: 12, fontFamily: 'Poppins'))),
        ),
        const SizedBox(width: 10),
        Text('Signed in as $name',
            style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
      ]),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    ));
    Navigator.of(context).pushReplacementNamed(
      _selectedRole == UserRole.researcher ? '/researcher' : '/dashboard',
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          // ── Background gradient
          Container(
            decoration: const BoxDecoration(gradient: AppGradients.splashGradient),
          ),

          // ── Decorative orbs
          Positioned(
            top: -60, right: -50,
            child: _Orb(size: 220, color: AppColors.primary.withOpacity(0.22)),
          ),
          Positioned(
            top: size.height * 0.18, left: -60,
            child: _Orb(size: 160, color: AppColors.secondary.withOpacity(0.16)),
          ),
          Positioned(
            bottom: -80, right: -40,
            child: _Orb(size: 200, color: AppColors.accent.withOpacity(0.12)),
          ),

          // ── Scrollable content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 36),

                  // ── Logo + title
                  FadeTransition(
                    opacity: _fadeIn,
                    child: Column(children: [
                      Container(
                        width: 86,
                        height: 86,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1A6B9A), Color(0xFF0DA77F)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondary.withOpacity(0.45),
                              blurRadius: 28, spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.medical_information_rounded,
                            size: 42, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      const Text('AI Orthodontic',
                          style: TextStyle(
                            fontSize: 26, fontWeight: FontWeight.w800,
                            color: Colors.white, fontFamily: 'Poppins',
                          )),
                      const SizedBox(height: 4),
                      Text('Clinical Management Platform',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.55),
                            fontFamily: 'Poppins',
                          )),
                    ]),
                  ),

                  const SizedBox(height: 28),

                  // ── Glass form card
                  SlideTransition(
                    position: _slideUp,
                    child: FadeTransition(
                      opacity: _fadeIn,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.18), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 30, offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // ── Role Selector
                              _RoleSelector(
                                selected: _selectedRole,
                                onChanged: (r) => setState(() => _selectedRole = r),
                              ),
                              const SizedBox(height: 22),

                              Text(
                                _selectedRole == UserRole.researcher
                                    ? 'Researcher Sign In'
                                    : 'Doctor Sign In',
                                style: const TextStyle(
                                  fontSize: 19, fontWeight: FontWeight.w700,
                                  color: Colors.white, fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _selectedRole == UserRole.researcher
                                    ? 'Manage patient intake & assignments'
                                    : 'Manage cases & clinical analysis',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.5),
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Email
                              _GlassField(
                                controller: _emailCtrl,
                                hint: _selectedRole == UserRole.researcher
                                    ? 'researcher@clinic.com'
                                    : 'doctor@clinic.com',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Email required';
                                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                                    return 'Enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),

                              // Password
                              _GlassField(
                                controller: _passwordCtrl,
                                hint: 'Password',
                                icon: Icons.lock_outline_rounded,
                                obscureText: _obscurePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: Colors.white54, size: 20,
                                  ),
                                  onPressed: () => setState(
                                      () => _obscurePassword = !_obscurePassword),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Password required';
                                  if (v.length < 6) return 'Min. 6 characters';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),

                              // Forgot password
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () =>
                                      Navigator.of(context).pushNamed('/forgot-password'),
                                  child: Text('Forgot password?',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.secondaryLight,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w600,
                                      )),
                                ),
                              ),
                              const SizedBox(height: 18),

                              // Error banner
                              Consumer<AuthProvider>(
                                builder: (_, auth, __) {
                                  if (auth.errorMessage == null) {
                                    return const SizedBox.shrink();
                                  }
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 14),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: AppColors.error.withOpacity(0.5)),
                                    ),
                                    child: Row(children: [
                                      const Icon(Icons.error_outline_rounded,
                                          color: AppColors.errorLight, size: 18),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(auth.errorMessage!,
                                            style: const TextStyle(
                                              color: AppColors.errorLight,
                                              fontSize: 12, fontFamily: 'Poppins',
                                            )),
                                      ),
                                      GestureDetector(
                                        onTap: auth.clearError,
                                        child: const Icon(Icons.close_rounded,
                                            color: AppColors.errorLight, size: 16),
                                      ),
                                    ]),
                                  );
                                },
                              ),

                              // Sign in button
                              Consumer<AuthProvider>(
                                builder: (_, auth, __) => GradientButton(
                                  text: 'Sign In',
                                  isLoading: auth.isLoading,
                                  onPressed: _handleLogin,
                                  icon: Icons.login_rounded,
                                  gradient: _selectedRole == UserRole.researcher
                                      ? AppGradients.purpleGradient
                                      : AppGradients.primaryGradient,
                                ),
                              ),

                              const SizedBox(height: 14),
                              _GoogleSignInButton(onTap: _handleGoogleSignIn),

                              const SizedBox(height: 20),
                              // Demo hint
                              _DemoHint(role: _selectedRole),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Sign up link
                  FadeTransition(
                    opacity: _fadeIn,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account? ",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 13, fontFamily: 'Poppins',
                            )),
                        GestureDetector(
                          onTap: () => Navigator.of(context)
                              .pushReplacementNamed('/register'),
                          child: const Text('Create Account',
                              style: TextStyle(
                                color: AppColors.secondaryLight,
                                fontSize: 13, fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700,
                              )),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Role selector tabs
class _RoleSelector extends StatelessWidget {
  final UserRole selected;
  final ValueChanged<UserRole> onChanged;
  const _RoleSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: Row(children: [
        _RoleTab(
          label: 'Doctor',
          icon: Icons.local_hospital_rounded,
          isSelected: selected == UserRole.doctor,
          onTap: () => onChanged(UserRole.doctor),
          activeGradient: AppGradients.primaryGradient,
        ),
        _RoleTab(
          label: 'Researcher',
          icon: Icons.science_rounded,
          isSelected: selected == UserRole.researcher,
          onTap: () => onChanged(UserRole.researcher),
          activeGradient: AppGradients.purpleGradient,
        ),
      ]),
    );
  }
}

class _RoleTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Gradient activeGradient;
  const _RoleTab({
    required this.label, required this.icon, required this.isSelected,
    required this.onTap, required this.activeGradient,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected ? activeGradient : null,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8)]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 18,
                  color: isSelected ? Colors.white : Colors.white38),
              const SizedBox(height: 3),
              Text(label,
                  style: TextStyle(
                    fontSize: 11, fontFamily: 'Poppins',
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    color: isSelected ? Colors.white : Colors.white38,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Demo credentials hint
class _DemoHint extends StatelessWidget {
  final UserRole role;
  const _DemoHint({required this.role});

  @override
  Widget build(BuildContext context) {
    final String email = role == UserRole.researcher
        ? 'research@test.com'
        : 'doctor@test.com';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(children: [
        Icon(Icons.info_outline_rounded,
            size: 14, color: AppColors.secondaryLight.withOpacity(0.8)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Demo: $email / anypassword',
            style: TextStyle(
              fontSize: 11, fontFamily: 'Poppins',
              color: Colors.white.withOpacity(0.45),
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Glass text field
class _GlassField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _GlassField({
    required this.controller, required this.hint, required this.icon,
    this.obscureText = false, this.suffixIcon, this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.35), fontFamily: 'Poppins', fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.white54, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.secondaryLight, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.errorLight)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.errorLight, width: 2)),
        errorStyle: const TextStyle(color: AppColors.errorLight, fontFamily: 'Poppins', fontSize: 11),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

// ── Google sign-in button
class _GoogleSignInButton extends StatelessWidget {
  final VoidCallback onTap;
  const _GoogleSignInButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.18)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 22, height: 22,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Center(
              child: Text('G', style: TextStyle(color: Color(0xFF4285F4),
                  fontWeight: FontWeight.w800, fontSize: 13, fontFamily: 'Poppins')),
            ),
          ),
          const SizedBox(width: 12),
          Text('Continue with Google',
              style: TextStyle(color: Colors.white.withOpacity(0.75),
                  fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 14)),
        ]),
      ),
    );
  }
}

// ── Decorative orb
class _Orb extends StatelessWidget {
  final double size;
  final Color color;
  const _Orb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) => Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color));
}
