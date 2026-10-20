import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../data/repositories/local_donation_repository.dart';
import '../../models/user_role.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/button_loading.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.repository});

  final FoodLinkRepository repository;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSubmitting = false;
  bool _rememberMe = true;

  // Local brand palette (works whether or not AppColors exposes every shade)
  static const Color _primaryGreen = AppColors.primaryGreen;
  static const Color _greenDeep = Color(0xFF0E6B47);
  static const Color _greenSoft = Color(0xFFE8F6EF);

  void _fillDemoCredentials() {
    _emailController.text = AppConstants.demoEmail;
    _passwordController.text = AppConstants.demoPassword;
    setState(() {});
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    // Simulated processing delay so the loading state is visible in the demo.
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    try {
      final UserRole role;
      try {
        role = widget.repository.login(
          _emailController.text,
          _passwordController.text,
        );
      } on StateError {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Incorrect email or password. Please try again.',
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        return;
      }
      if (!mounted) return;

      final destination = switch (role) {
        UserRole.donor => '/dashboard',
        UserRole.ngo => '/ngo-dashboard',
        UserRole.admin => '/admin-dashboard',
      };

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Welcome back! Opening your dashboard...'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      Navigator.pushNamedAndRemoveUntil(context, destination, (route) => false);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final useSplitLayout = width >= 900;

          final formContent = _FormContent(
            formKey: _formKey,
            emailController: _emailController,
            passwordController: _passwordController,
            obscurePassword: _obscurePassword,
            isSubmitting: _isSubmitting,
            rememberMe: _rememberMe,
            onToggleObscure: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            onToggleRemember: (v) => setState(() => _rememberMe = v ?? false),
            onFillDemo: _fillDemoCredentials,
            onSubmit: _submit,
            onSignup: () => Navigator.pushNamed(context, '/role-selection'),
            isCompact: useSplitLayout,
          );

          if (useSplitLayout) {
            return _SplitLayout(child: formContent);
          }

          return _StackedLayout(height: height, child: formContent);
        },
      ),
    );
  }
}

// ============================================================
// # LAYOUT VARIANTS
// ============================================================

class _SplitLayout extends StatelessWidget {
  final Widget child;
  const _SplitLayout({required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        children: [
          // Branding panel — fixed 42% width, never scrolls
          const Expanded(flex: 42, child: _BrandingPanel()),
          // Form panel — scrolls if needed
          Expanded(
            flex: 58,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StackedLayout extends StatelessWidget {
  final double height;
  final Widget child;
  const _StackedLayout({required this.height, required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: height - 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Compact header band (mobile portrait)
              const _MobileHeader(),
              const SizedBox(height: 24),
              child,
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// # BRANDING PANEL (TABLET / LANDSCAPE)
// ============================================================

class _BrandingPanel extends StatelessWidget {
  const _BrandingPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _LoginScreenState._primaryGreen,
            _LoginScreenState._greenDeep,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.spa,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'FoodLink',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Headline
                const Text(
                  'Share food.\nBuild community.\nReduce waste.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    height: 1.25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Join thousands of donors and NGOs making food rescue simple, fast, and impactful.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                // Feature bullets
                _FeatureBullet(
                  icon: Icons.bolt_rounded,
                  text: 'Quick 30-second donations',
                ),
                const SizedBox(height: 14),
                _FeatureBullet(
                  icon: Icons.shield_rounded,
                  text: 'Verified NGO partners only',
                ),
                const SizedBox(height: 14),
                _FeatureBullet(
                  icon: Icons.insights_rounded,
                  text: 'Real-time impact dashboard',
                ),
                const Spacer(),
                // Mini stats strip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Row(
                    children: const [
                      _BrandStat(value: '12k+', label: 'Donors'),
                      _VerticalDivider(),
                      _BrandStat(value: '480', label: 'NGOs'),
                      _VerticalDivider(),
                      _BrandStat(value: '1.2M', label: 'Meals'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureBullet extends StatelessWidget {
  final IconData icon;
  final String text;
  const _FeatureBullet({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 14),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _BrandStat extends StatelessWidget {
  final String value;
  final String label;
  const _BrandStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: Colors.white.withValues(alpha: 0.25),
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

// ============================================================
// # MOBILE HEADER (PORTRAIT)
// ============================================================

class _MobileHeader extends StatelessWidget {
  const _MobileHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        // Logo
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                _LoginScreenState._primaryGreen,
                _LoginScreenState._greenDeep,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _LoginScreenState._primaryGreen.withValues(alpha: 0.35),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(Icons.spa, color: Colors.white, size: 32),
        ),
        const SizedBox(height: 18),
        const Text(
          'Welcome back',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          'Sign in to manage your food donations and pickups.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black.withValues(alpha: 0.6),
            fontSize: 14,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ============================================================
// # FORM CONTENT (shared by both layouts)
// ============================================================

class _FormContent extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool isSubmitting;
  final bool rememberMe;
  final VoidCallback onToggleObscure;
  final ValueChanged<bool?> onToggleRemember;
  final VoidCallback onFillDemo;
  final VoidCallback onSubmit;
  final VoidCallback onSignup;
  final bool isCompact;

  const _FormContent({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.isSubmitting,
    required this.rememberMe,
    required this.onToggleObscure,
    required this.onToggleRemember,
    required this.onFillDemo,
    required this.onSubmit,
    required this.onSignup,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isCompact) ...[
            Text(
              'Sign in',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Use your donor credentials to continue.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primaryText.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 24),
          ],
          // Email
          AppTextField(
            controller: emailController,
            label: 'Email address',
            hint: 'name@example.com',
            prefixIcon: const Icon(Icons.email_outlined),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            validator: Validators.validateEmail,
          ),
          const SizedBox(height: 16),
          // Password
          AppTextField(
            controller: passwordController,
            label: 'Password',
            hint: 'Enter your password',
            prefixIcon: const Icon(Icons.lock_outline),
            obscureText: obscurePassword,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            validator: Validators.validatePassword,
            onFieldSubmitted: (_) => onSubmit(),
            suffixIcon: IconButton(
              tooltip: obscurePassword ? 'Show password' : 'Hide password',
              icon: Icon(
                obscurePassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: onToggleObscure,
            ),
          ),
          const SizedBox(height: 10),
          // Remember + Forgot row
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 4,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: rememberMe,
                      onChanged: onToggleRemember,
                      activeColor: _LoginScreenState._primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Remember me',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.primaryText.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: isSubmitting ? null : () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Forgot password?',
                  style: TextStyle(
                    fontSize: 13,
                    color: _LoginScreenState._primaryGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Demo banner
          _DemoCredentialsBanner(onFill: onFillDemo),
          const SizedBox(height: 20),
          // Submit button
          _PrimaryButton(
            isSubmitting: isSubmitting,
            label: 'Log In',
            loadingLabel: 'Logging in...',
            onPressed: onSubmit,
          ),
          const SizedBox(height: 16),
          // Divider
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'or continue with',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryText.withValues(alpha: 0.5),
                  ),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 14),
          // Social buttons
          Row(
            children: [
              Expanded(
                child: _SocialButton(
                  icon: Icons.g_mobiledata_rounded,
                  label: 'Google',
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SocialButton(
                  icon: Icons.apple_rounded,
                  label: 'Apple',
                  onTap: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Signup row
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                "Don't have an account?",
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primaryText.withValues(alpha: 0.7),
                ),
              ),
              TextButton(
                onPressed: isSubmitting ? null : onSignup,
                child: Text(
                  'Create account',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _LoginScreenState._primaryGreen,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// # PRIMARY BUTTON
// ============================================================

class _PrimaryButton extends StatelessWidget {
  final bool isSubmitting;
  final String label;
  final String loadingLabel;
  final VoidCallback onPressed;
  const _PrimaryButton({
    required this.isSubmitting,
    required this.label,
    required this.loadingLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: isSubmitting
              ? [
                  _LoginScreenState._primaryGreen.withValues(alpha: 0.6),
                  _LoginScreenState._greenDeep.withValues(alpha: 0.6),
                ]
              : [_LoginScreenState._primaryGreen, _LoginScreenState._greenDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: isSubmitting
            ? []
            : [
                BoxShadow(
                  color: _LoginScreenState._primaryGreen.withValues(
                    alpha: 0.35,
                  ),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: isSubmitting ? null : onPressed,
          child: Center(
            child: isSubmitting
                ? ButtonLoading(label: loadingLabel)
                : Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// # SOCIAL BUTTON
// ============================================================

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.1),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: AppColors.primaryText),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// # DEMO CREDENTIALS BANNER
// ============================================================

class _DemoCredentialsBanner extends StatelessWidget {
  const _DemoCredentialsBanner({required this.onFill});

  final VoidCallback onFill;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _LoginScreenState._greenSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _LoginScreenState._primaryGreen.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _LoginScreenState._primaryGreen.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.info_outline,
              size: 16,
              color: _LoginScreenState._greenDeep,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Demo donor account: ${AppConstants.demoEmail}',
              style: TextStyle(
                fontSize: 12,
                color: _LoginScreenState._greenDeep,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: _LoginScreenState._primaryGreen,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: onFill,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  'Fill',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
