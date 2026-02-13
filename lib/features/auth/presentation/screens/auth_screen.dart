import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:igni_save/core/constants/app_strings.dart';
import 'package:igni_save/core/constants/app_theme_colors.dart';
import 'package:igni_save/core/theme/text_styles.dart';
import 'package:igni_save/features/auth/presentation/widgets/legal_popup.dart';
import 'package:igni_save/features/auth/providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  final bool initialIsLogin;

  const AuthScreen({super.key, this.initialIsLogin = true});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with TickerProviderStateMixin {
  late bool _isLogin;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Focus Nodes
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Animation Controllers
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _isLogin = widget.initialIsLogin;

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Start animation after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
    // Clear fields when switching
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (_isLogin) {
      await ref
          .read(authControllerProvider.notifier)
          .signInWithEmail(email, password);
    } else {
      await ref
          .read(authControllerProvider.notifier)
          .signUpWithEmail(email, password, email.split('@')[0]);
    }

    if (mounted) {
      final authState = ref.read(authStateProvider);
      if (authState.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authState.error.toString()),
            backgroundColor: AppThemeColors.error,
          ),
        );
      } else if (authState.value != null) {
        context.go(AppStrings.routeDashboard);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLoading = ref.watch(authStateProvider).isLoading;

    // Design reference size
    const designWidth = 402.0;
    const designHeight = 874.0;

    // Calculate scale factors
    final scaleW = size.width / designWidth;
    final scaleH = size.height / designHeight;

    // Background colors matching the images
    final backgroundColor = _isLogin
        ? AppThemeColors
              .secondary // Blue for login
        : AppThemeColors
              .primary; // Green for signup (changed from sky blue to match brand)

    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevent layout shift on keyboard open
      backgroundColor: backgroundColor,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        color: backgroundColor,
        child: Stack(
          children: [
            // 1. Background Image (Top Half)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height:
                  315 * scaleH, // Anchor bottom to top of card (295) + overlap
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, -1), // Start from top
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _slideController,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Transform.scale(
                    key: ValueKey(_isLogin),
                    scale: 1.1,
                    alignment:
                        Alignment.bottomCenter, // Titik pusat zoom di bawah
                    child: Image.asset(
                      _isLogin
                          ? 'assets/images/loginpage.png'
                          : 'assets/images/signuppage.png',
                      fit: BoxFit.fitWidth,
                      alignment: Alignment.bottomCenter,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
              ),
            ),

            // 2. Sliding Card (Bottom Half)
            Positioned(
              top: 295 * scaleH, // Match design top position roughly
              left: 0,
              right: 0,
              bottom: 0,
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 1), // Start from bottom
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _slideController,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppThemeColors.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 36 * scaleW,
                      vertical: 30 * scaleH,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Toggle Switch
                          Container(
                            height: 56,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppThemeColors.inputBackground,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: AppThemeColors.border),
                            ),
                            child: Stack(
                              children: [
                                AnimatedAlign(
                                  alignment: _isLogin
                                      ? Alignment.centerLeft
                                      : Alignment.centerRight,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  child: Container(
                                    width: (size.width - 72 * scaleW) / 2 - 4,
                                    height: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(26),
                                      boxShadow: AppThemeColors.cardShadow,
                                      border: Border.all(
                                        color: AppThemeColors.borderLight,
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          if (!_isLogin) _toggleAuthMode();
                                        },
                                        child: Container(
                                          color: Colors.transparent,
                                          alignment: Alignment.center,
                                          child: Text(
                                            'LOG IN',
                                            style: AppTextStyles.labelLarge
                                                .copyWith(
                                                  color: _isLogin
                                                      ? AppThemeColors
                                                            .textPrimary
                                                      : AppThemeColors
                                                            .textSecondary,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 1.0,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          if (_isLogin) _toggleAuthMode();
                                        },
                                        child: Container(
                                          color: Colors.transparent,
                                          alignment: Alignment.center,
                                          child: Text(
                                            'SIGN UP',
                                            style: AppTextStyles.labelLarge
                                                .copyWith(
                                                  color: !_isLogin
                                                      ? AppThemeColors
                                                            .textPrimary
                                                      : AppThemeColors
                                                            .textSecondary,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 1.0,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Email Field
                          Text(
                            'EMAIL ADDRESS',
                            style: AppTextStyles.labelSmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppThemeColors.textSecondary,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            focusNode: _emailFocus,
                            style: AppTextStyles.bodyLarge,
                            decoration: InputDecoration(
                              hintText: 'hello@ignisave.com',
                              hintStyle: AppTextStyles.bodyLarge.copyWith(
                                color: AppThemeColors.textHint,
                              ),
                              filled: true,
                              fillColor: AppThemeColors.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: AppThemeColors.border,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: AppThemeColors.border,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: AppThemeColors.primary,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Password Field
                          Text(
                            'PASSWORD',
                            style: AppTextStyles.labelSmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppThemeColors.textSecondary,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            focusNode: _passwordFocus,
                            obscureText: _obscurePassword,
                            style: AppTextStyles.bodyLarge,
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              hintStyle: AppTextStyles.bodyLarge.copyWith(
                                color: AppThemeColors.textHint,
                                letterSpacing: 2.0,
                              ),
                              filled: true,
                              fillColor: AppThemeColors.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: AppThemeColors.border,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: AppThemeColors.border,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: AppThemeColors.primary,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                  color: AppThemeColors.textSecondary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),

                          // Forgot Password (Login Only)
                          if (_isLogin) ...[
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {
                                  context.push(AppStrings.routeForgotPassword);
                                },
                                child: Text(
                                  'FORGOT PASSWORD?',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppThemeColors.primary,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ],

                          // Confirm Password (Signup Only)
                          AnimatedCrossFade(
                            firstChild: Container(),
                            secondChild: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 20),
                                Text(
                                  'CONFIRM PASSWORD',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppThemeColors.textSecondary,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  focusNode: _confirmPasswordFocus,
                                  obscureText: _obscureConfirmPassword,
                                  style: AppTextStyles.bodyLarge,
                                  decoration: InputDecoration(
                                    hintText: '••••••••',
                                    hintStyle: AppTextStyles.bodyLarge.copyWith(
                                      color: AppThemeColors.textHint,
                                      letterSpacing: 2.0,
                                    ),
                                    filled: true,
                                    fillColor: AppThemeColors.surface,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                        color: AppThemeColors.border,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                        color: AppThemeColors.border,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                        color: AppThemeColors.primary,
                                        width: 2,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 18,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirmPassword
                                            ? Icons.visibility_off_rounded
                                            : Icons.visibility_rounded,
                                        color: AppThemeColors.textSecondary,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureConfirmPassword =
                                              !_obscureConfirmPassword;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (!_isLogin) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please confirm your password';
                                      }
                                      if (value != _passwordController.text) {
                                        return 'Passwords do not match';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                            crossFadeState: _isLogin
                                ? CrossFadeState.showFirst
                                : CrossFadeState.showSecond,
                            duration: const Duration(milliseconds: 300),
                          ),

                          const SizedBox(height: 32),

                          // Continue Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _submit,
                              style:
                                  ElevatedButton.styleFrom(
                                    backgroundColor: AppThemeColors.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    elevation: 0,
                                    shadowColor: AppThemeColors.primary
                                        .withValues(alpha: 0.4),
                                  ).copyWith(
                                    elevation: WidgetStateProperty.resolveWith((
                                      states,
                                    ) {
                                      if (states.contains(
                                        WidgetState.pressed,
                                      )) {
                                        return 0;
                                      }
                                      return 4;
                                    }),
                                  ),
                              child: isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text(
                                      _isLogin ? 'LOG IN' : 'CREATE ACCOUNT',
                                      style: AppTextStyles.labelLarge.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Or Divider
                          Row(
                            children: [
                              Expanded(
                                child: Divider(color: AppThemeColors.border),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  'OR',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppThemeColors.textTertiary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(color: AppThemeColors.border),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Google Button
                          GestureDetector(
                            onTap: () {
                              ref
                                  .read(authControllerProvider.notifier)
                                  .signInWithGoogle();
                            },
                            child: Container(
                              width: double.infinity,
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppThemeColors.border,
                                  width: 2,
                                ),
                                boxShadow: AppThemeColors.cardShadow,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/google.svg',
                                    width: 20,
                                    height: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'CONTINUE WITH GOOGLE',
                                    style: AppTextStyles.labelLarge.copyWith(
                                      color: AppThemeColors.textPrimary,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Terms
                          Center(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              children: [
                                Text(
                                  'By tapping Continue, You agree to our ',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppThemeColors.textTertiary,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => showLegalPopup(context, 'Terms'),
                                  child: Text(
                                    'Terms',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppThemeColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  ' and ',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppThemeColors.textTertiary,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () =>
                                      showLegalPopup(context, 'Privacy Policy'),
                                  child: Text(
                                    'Privacy Policy',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppThemeColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  '.',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppThemeColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Extra padding for scrolling
                          SizedBox(
                            height:
                                MediaQuery.of(context).viewInsets.bottom + 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
