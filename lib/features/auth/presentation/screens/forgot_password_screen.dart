import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_theme_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Slide animation setup
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(0, 1), // Start from bottom
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    // Start animation
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authNotifier = ref.read(authControllerProvider.notifier);
      await authNotifier.sendPasswordResetEmail(_emailController.text);

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset link sent! Check your email.'),
            backgroundColor: AppThemeColors.success,
          ),
        );
        context.pop(); // Go back to login
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Failed to send reset email');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppThemeColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Design reference size
    const designWidth = 402.0;
    const designHeight = 874.0;

    final scaleW = size.width / designWidth;
    final scaleH = size.height / designHeight;

    return Scaffold(
      backgroundColor: AppThemeColors.secondary, // Match Login Blue
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 1. Background Image (Top Half)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 315 * scaleH, // Same height as AuthScreen
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
              child: Transform.scale(
                scale: 1.1, // Same zoom scale as AuthScreen
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  'assets/images/loginpage.png', // Use login image
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.bottomCenter,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ),

          // 2. Sliding Card (Bottom Half)
          Positioned(
            top: 295 * scaleH, // Match AuthScreen top position
            left: 0,
            right: 0,
            bottom: 0,
            child: SlideTransition(
              position: _slideAnimation,
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
                        Text(
                          'Forgot Password',
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: AppThemeColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 10 * scaleH),
                        Text(
                          'Enter your email address to reset your password.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppThemeColors.textSecondary,
                          ),
                        ),

                        SizedBox(height: 30 * scaleH),

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
                          style: AppTextStyles.bodyLarge,
                          decoration: InputDecoration(
                            hintText: 'hello@ignisave.com',
                            hintStyle: AppTextStyles.bodyLarge.copyWith(
                              color: AppThemeColors.textHint,
                            ),
                            filled: true,
                            fillColor: AppThemeColors.inputBackground,
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
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Required';
                            if (!val.contains('@')) return 'Invalid email';
                            return null;
                          },
                        ),

                        SizedBox(height: 30 * scaleH),

                        // Send Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSubmit,
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
                                    if (states.contains(WidgetState.pressed)) {
                                      return 0;
                                    }
                                    return 4;
                                  }),
                                ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'SEND RESET LINK',
                                    style: AppTextStyles.labelLarge.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                          ),
                        ),

                        SizedBox(height: 20 * scaleH),

                        // Back to Login
                        Center(
                          child: TextButton(
                            onPressed: () => context.pop(),
                            child: Text(
                              'BACK TO LOG IN',
                              style: AppTextStyles.labelLarge.copyWith(
                                fontFamily: 'Lexend',
                                fontWeight: FontWeight.w700,
                                color: AppThemeColors.primary,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),

                        // Extra padding for scrolling
                        SizedBox(
                          height: MediaQuery.of(context).viewInsets.bottom + 20,
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
    );
  }
}
