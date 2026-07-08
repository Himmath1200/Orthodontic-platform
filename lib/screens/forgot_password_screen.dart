import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/firebase_config.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _emailSent = false;
  bool _isDemo = false;

  late AnimationController _animCtrl;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _animCtrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
          ..forward();
    _fadeIn = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.forgotPassword(_emailCtrl.text.trim());
    if (ok && mounted) {
      setState(() {
        _emailSent = true;
        _isDemo = auth.isFirebaseMockMode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(gradient: AppGradients.splashGradient),
          ),
          // Decorative orbs
          Positioned(top: -60, right: -50,
              child: _Orb(220, AppColors.primary.withOpacity(0.2))),
          Positioned(bottom: -80, left: -60,
              child: _Orb(180, AppColors.secondary.withOpacity(0.15))),

          SafeArea(
            child: Column(
              children: [
                // AppBar-like top row
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                  child: Row(children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Text('Reset Password',
                        style: TextStyle(color: Colors.white, fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700, fontSize: 18)),
                  ]),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                    child: FadeTransition(
                      opacity: _fadeIn,
                      child: SlideTransition(
                        position: _slideUp,
                        child: _emailSent ? _SuccessView(
                          email: _emailCtrl.text.trim(),
                          isDemo: _isDemo,
                          onBack: () => Navigator.of(context).pushReplacementNamed('/login'),
                        ) : _FormView(
                          emailCtrl: _emailCtrl,
                          formKey: _formKey,
                          onSubmit: _handleReset,
                          isFirebaseEnabled: FirebaseConfig.useFirebase,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Success state
class _SuccessView extends StatelessWidget {
  final String email;
  final bool isDemo;
  final VoidCallback onBack;
  const _SuccessView({required this.email, required this.isDemo, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(height: 32),
      // Animated checkmark container
      Container(
        width: 96, height: 96,
        decoration: BoxDecoration(
          gradient: AppGradients.successGradient,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: AppColors.success.withOpacity(0.4), blurRadius: 28, spreadRadius: 2)],
        ),
        child: const Icon(Icons.mark_email_read_rounded, color: Colors.white, size: 46),
      ),
      const SizedBox(height: 28),
      const Text('Check Your Email',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800,
              fontSize: 24, color: Colors.white)),
      const SizedBox(height: 12),

      if (isDemo) ...[
        // Demo mode notice
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.warning.withOpacity(0.5)),
          ),
          child: Column(children: [
            Row(children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.warningLight, size: 18),
              const SizedBox(width: 8),
              const Text('Demo Mode — No Email Sent',
                  style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700,
                      fontSize: 13, color: AppColors.warningLight)),
            ]),
            const SizedBox(height: 8),
            const Text(
              'Firebase is not configured, so no real email was delivered. '
              'To enable real password reset:\n\n'
              '1. Set up your Firebase project\n'
              '2. Fill in lib/config/firebase_config.dart\n'
              '3. Set useFirebase = true',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
                  color: Colors.white70, height: 1.6),
            ),
          ]),
        ),
      ] else ...[
        // Real email sent
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(children: [
            Text('We sent a reset link to:',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.white.withOpacity(0.7))),
            const SizedBox(height: 4),
            Text(email,
                style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700,
                    fontSize: 15, color: Colors.white)),
            const SizedBox(height: 12),
            Text('Follow the link in your email to create a new password.\nIf you don\'t see it, check your spam folder.',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.white.withOpacity(0.65), height: 1.5),
                textAlign: TextAlign.center),
          ]),
        ),
      ],

      const SizedBox(height: 28),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded, size: 18),
          label: const Text('Back to Sign In',
              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 14)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
        ),
      ),
    ]);
  }
}

// ── Form state
class _FormView extends StatelessWidget {
  final TextEditingController emailCtrl;
  final GlobalKey<FormState> formKey;
  final VoidCallback onSubmit;
  final bool isFirebaseEnabled;
  const _FormView({required this.emailCtrl, required this.formKey,
      required this.onSubmit, required this.isFirebaseEnabled});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Icon
      Container(
        width: 80, height: 80,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
        ),
        child: const Icon(Icons.lock_reset_rounded, color: Colors.white, size: 38),
      ),
      const SizedBox(height: 24),
      const Text('Forgot Password?',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800,
              fontSize: 24, color: Colors.white)),
      const SizedBox(height: 10),
      Text('Enter your registered email and we\'ll\nsend you a reset link.',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 14,
              color: Colors.white.withOpacity(0.6), height: 1.5),
          textAlign: TextAlign.center),
      const SizedBox(height: 32),

      // Demo mode notice
      if (!isFirebaseEnabled)
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.warning.withOpacity(0.4)),
          ),
          child: Row(children: [
            const Icon(Icons.info_outline_rounded, color: AppColors.warningLight, size: 16),
            const SizedBox(width: 10),
            Expanded(child: Text('Demo mode: no real email will be sent. Configure Firebase for real password reset.',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 11,
                    color: Colors.white.withOpacity(0.75), height: 1.4))),
          ]),
        ),

      // Glass card form
      Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.18)),
        ),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(children: [
            // Email field
            TextFormField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: 14),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Email is required';
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) return 'Enter a valid email';
                return null;
              },
              decoration: InputDecoration(
                hintText: 'your@email.com',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.35), fontFamily: 'Poppins'),
                prefixIcon: const Icon(Icons.email_outlined, color: Colors.white54, size: 20),
                filled: true, fillColor: Colors.white.withOpacity(0.08),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.secondaryLight, width: 2)),
                errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.errorLight)),
                errorStyle: const TextStyle(color: AppColors.errorLight, fontFamily: 'Poppins', fontSize: 11),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 16),

            // Submit button
            Consumer<AuthProvider>(builder: (_, auth, __) {
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: auth.isLoading ? null : onSubmit,
                  icon: auth.isLoading
                      ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send_rounded, size: 18),
                  label: Text(auth.isLoading ? 'Sending...' : 'Send Reset Link',
                      style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    shadowColor: AppColors.secondary.withOpacity(0.4),
                  ),
                ),
              );
            }),

            // Error banner
            Consumer<AuthProvider>(builder: (_, auth, __) {
              if (auth.errorMessage == null) return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.error.withOpacity(0.5)),
                ),
                child: Row(children: [
                  const Icon(Icons.error_outline_rounded, color: AppColors.errorLight, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(auth.errorMessage!,
                      style: const TextStyle(color: AppColors.errorLight, fontSize: 12, fontFamily: 'Poppins'))),
                ]),
              );
            }),
          ]),
        ),
      ),

      const SizedBox(height: 20),
      TextButton.icon(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back_rounded, size: 16, color: Colors.white60),
        label: const Text('Back to Sign In',
            style: TextStyle(color: Colors.white60, fontFamily: 'Poppins', fontSize: 13)),
      ),
    ]);
  }
}

class _Orb extends StatelessWidget {
  final double size;
  final Color color;
  const _Orb(this.size, this.color);
  @override
  Widget build(BuildContext context) => Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color));
}
