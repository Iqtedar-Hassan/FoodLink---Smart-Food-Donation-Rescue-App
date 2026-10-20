import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../data/repositories/local_donation_repository.dart';
import '../../models/user_role.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/button_loading.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key, required this.repository, required this.role});

  final FoodLinkRepository repository;
  final UserRole role;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreed = false;
  bool _isSubmitting = false;
  String _donorType = AppConstants.donorTypes.first;

  // Brand palette (mirrors LoginScreen)
  static const Color _primaryGreen = AppColors.primaryGreen;
  static const Color _greenDeep = Color(0xFF0E6B47);
  static const Color _greenSoft = Color(0xFFE8F6EF);

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password.';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match. Please re-enter them.';
    }
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please agree to the usage guidance before creating your account.',
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Simulated processing delay so the loading state is visible in the demo.
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    try {
      try {
        widget.repository.signup(
          fullName: _fullNameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          password: _passwordController.text,
          role: widget.role,
          donorType: widget.role == UserRole.donor ? _donorType : null,
        );
      } on StateError catch (error) {
        if (!mounted) return;

        final message = error.toString().contains('already exists')
            ? 'This email is already registered. Please use a different email address.'
            : 'Unable to create your account right now. Please try again.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        return;
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Account created successfully.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        widget.role == UserRole.donor ? '/dashboard' : '/ngo-dashboard',
        (route) => false,
      );
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
            role: widget.role,
            fullNameController: _fullNameController,
            emailController: _emailController,
            phoneController: _phoneController,
            passwordController: _passwordController,
            confirmPasswordController: _confirmPasswordController,
            donorType: _donorType,
            obscurePassword: _obscurePassword,
            obscureConfirmPassword: _obscureConfirmPassword,
            isSubmitting: _isSubmitting,
            agreed: _agreed,
            onToggleObscurePassword: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            onToggleObscureConfirm: () => setState(
              () => _obscureConfirmPassword = !_obscureConfirmPassword,
            ),
            onDonorTypeChanged: (v) =>
                setState(() => _donorType = v ?? AppConstants.donorTypes.first),
            onAgreementChanged: (v) => setState(() => _agreed = v ?? false),
            onSubmit: _submit,
            onLogin: () => Navigator.pushNamed(context, '/login'),
            validateConfirmPassword: _validateConfirmPassword,
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
// # LAYOUT VARIANTS — same system as LoginScreen
// ============================================================

class _SplitLayout extends StatelessWidget {
  final Widget child;
  const _SplitLayout({required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        children: [
          const Expanded(flex: 42, child: _BrandingPanel()),
          Expanded(
            flex: 58,
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 32,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 64,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: child,
                    ),
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

class _StackedLayout extends StatelessWidget {
  final double height;
  final Widget child;
  const _StackedLayout({required this.height, required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _MobileHeader(),
                    const SizedBox(height: 22),
                    Flexible(child: child),
                    const SizedBox(height: 22),
                  ],
                ),
              ),
            ),
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
            _SignUpScreenState._primaryGreen,
            _SignUpScreenState._greenDeep,
          ],
        ),
      ),
      child: Stack(
        children: [
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                const Text(
                  'Become a\nFoodLink donor\ntoday.',
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
                const _FeatureBullet(
                  icon: Icons.bolt_rounded,
                  text: 'Quick 30-second donations',
                ),
                const SizedBox(height: 14),
                const _FeatureBullet(
                  icon: Icons.shield_rounded,
                  text: 'Verified NGO partners only',
                ),
                const SizedBox(height: 14),
                const _FeatureBullet(
                  icon: Icons.insights_rounded,
                  text: 'Real-time impact dashboard',
                ),
                const Spacer(),
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
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                _SignUpScreenState._primaryGreen,
                _SignUpScreenState._greenDeep,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _SignUpScreenState._primaryGreen.withValues(alpha: 0.35),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(Icons.spa, color: Colors.white, size: 32),
        ),
        const SizedBox(height: 18),
        const Text(
          'Create your account',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          'Join FoodLink to share and rescue food in your community.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black.withValues(alpha: 0.6),
            fontSize: 14,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

// ============================================================
// # FORM CONTENT (shared by both layouts)
// ============================================================

class _FormContent extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final UserRole role;
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final String donorType;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final bool isSubmitting;
  final bool agreed;
  final VoidCallback onToggleObscurePassword;
  final VoidCallback onToggleObscureConfirm;
  final ValueChanged<String?> onDonorTypeChanged;
  final ValueChanged<bool?> onAgreementChanged;
  final VoidCallback onSubmit;
  final VoidCallback onLogin;
  final String? Function(String?) validateConfirmPassword;
  final bool isCompact;

  const _FormContent({
    required this.formKey,
    required this.role,
    required this.fullNameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.donorType,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.isSubmitting,
    required this.agreed,
    required this.onToggleObscurePassword,
    required this.onToggleObscureConfirm,
    required this.onDonorTypeChanged,
    required this.onAgreementChanged,
    required this.onSubmit,
    required this.onLogin,
    required this.validateConfirmPassword,
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _SignUpScreenState._greenSoft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _SignUpScreenState._primaryGreen.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  role == UserRole.donor
                      ? Icons.storefront_outlined
                      : Icons.volunteer_activism_outlined,
                  color: _SignUpScreenState._primaryGreen,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Registering as ${role.label}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (isCompact) ...[
            Text(
              'Sign up',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Fill in your details to create your ${role.label} account.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primaryText.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 22),
          ],
          // Full name
          AppTextField(
            controller: fullNameController,
            label: 'Full name',
            hint: 'Your full name',
            prefixIcon: const Icon(Icons.person_outline),
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.name],
            validator: (value) =>
                Validators.validateRequired(value, 'Full name'),
          ),
          const SizedBox(height: 14),
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
          const SizedBox(height: 14),
          // Phone
          AppTextField(
            controller: phoneController,
            label: 'Phone number',
            hint: '+92 300 1234567',
            prefixIcon: const Icon(Icons.phone_outlined),
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.telephoneNumber],
            validator: Validators.validatePhoneNumber,
          ),
          const SizedBox(height: 14),
          // Password
          AppTextField(
            controller: passwordController,
            label: 'Password',
            hint: 'Create a password',
            prefixIcon: const Icon(Icons.lock_outline),
            obscureText: obscurePassword,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
            helperText: 'Use 8+ characters with letters and numbers.',
            validator: Validators.validatePassword,
            suffixIcon: IconButton(
              tooltip: obscurePassword ? 'Show password' : 'Hide password',
              icon: Icon(
                obscurePassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: onToggleObscurePassword,
            ),
          ),
          const SizedBox(height: 14),
          // Confirm password
          AppTextField(
            controller: confirmPasswordController,
            label: 'Confirm password',
            hint: 'Re-enter your password',
            prefixIcon: const Icon(Icons.lock_reset_outlined),
            obscureText: obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            validator: validateConfirmPassword,
            suffixIcon: IconButton(
              tooltip: obscureConfirmPassword
                  ? 'Show password'
                  : 'Hide password',
              icon: Icon(
                obscureConfirmPassword
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
              onPressed: onToggleObscureConfirm,
            ),
          ),
          const SizedBox(height: 14),
          if (role == UserRole.donor) ...[
            _DonorTypeSelector(value: donorType, onChanged: onDonorTypeChanged),
            const SizedBox(height: 12),
          ],
          // Agreement
          _AgreementCheckbox(value: agreed, onChanged: onAgreementChanged),
          const SizedBox(height: 20),
          // Submit
          _PrimaryButton(
            isSubmitting: isSubmitting,
            label: 'Create Account',
            loadingLabel: 'Creating account...',
            onPressed: onSubmit,
          ),
          const SizedBox(height: 16),
          // Already have an account?
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Already have an account?',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primaryText.withValues(alpha: 0.7),
                ),
              ),
              TextButton(
                onPressed: isSubmitting ? null : onLogin,
                child: Text(
                  'Log In',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _SignUpScreenState._primaryGreen,
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
// # DONOR TYPE SELECTOR
// ============================================================

class _DonorTypeSelector extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;
  const _DonorTypeSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Donor type',
          helperText: 'Optional - tells NGOs what kind of donor you are.',
          prefixIcon: Icon(Icons.storefront_outlined),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        items: AppConstants.donorTypes.map((type) {
          return DropdownMenuItem(value: type, child: Text(type));
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

// ============================================================
// # AGREEMENT CHECKBOX
// ============================================================

class _AgreementCheckbox extends StatelessWidget {
  const _AgreementCheckbox({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _SignUpScreenState._greenSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _SignUpScreenState._primaryGreen.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 24,
            width: 24,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: _SignUpScreenState._primaryGreen,
              checkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'I agree to the basic usage guidance and responsible food '
                'donation practices.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: AppColors.primaryText.withValues(alpha: 0.8),
                ),
              ),
            ),
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
                  _SignUpScreenState._primaryGreen.withValues(alpha: 0.6),
                  _SignUpScreenState._greenDeep.withValues(alpha: 0.6),
                ]
              : [
                  _SignUpScreenState._primaryGreen,
                  _SignUpScreenState._greenDeep,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: isSubmitting
            ? []
            : [
                BoxShadow(
                  color: _SignUpScreenState._primaryGreen.withValues(
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
