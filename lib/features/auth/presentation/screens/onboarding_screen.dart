import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:igni_save/core/constants/app_strings.dart';
import 'package:igni_save/core/constants/app_theme_colors.dart';
import 'package:igni_save/core/theme/text_styles.dart';
import 'package:igni_save/services/local_storage_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  int _currentPage = 0;
  late AnimationController _progressController;

  // For content fade animation
  double _contentOpacity = 1.0;
  bool _isTransitioning = false;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      color: AppThemeColors.secondary, // Blue for first slide
      image: 'assets/images/onboardingslide1.png',
      title: 'Save Your Money, Shape Your Life',
      description:
          'Achieve your financial goals with a gamified experience that makes saving fun',
      titleColor: Colors.white,
      descColor: const Color(0xFFF3E8FF),
    ),
    OnboardingPageData(
      color: AppThemeColors.primary, // Green for second slide
      image: 'assets/images/onboardingslide2.png',
      title: 'Achieve Goals with Gamified Habits.',
      description:
          'Level up your finances, complete daily tasks and build your streak.',
      titleColor: Colors.white,
      descColor: Colors.white,
    ),
    OnboardingPageData(
      color: AppThemeColors
          .error, // Red/Orange for third slide (using error for vibrant contrast or custom)
      image: 'assets/images/onboardingslide3.png',
      title: 'Join the Community.',
      description:
          'Connect with friends and family to motivate each other and share your financial victories.',
      titleColor: Colors.white,
      descColor: Colors.white,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _progressController =
        AnimationController(vsync: this, duration: const Duration(seconds: 15))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _nextPage();
            }
          });

    _startProgress();
  }

  void _startProgress() {
    _progressController.reset();
    _progressController.forward();
  }

  Future<void> _nextPage() async {
    if (_isTransitioning) return;

    if (_currentPage < _pages.length - 1) {
      setState(() => _isTransitioning = true);

      // Fade out current content
      setState(() => _contentOpacity = 0.0);

      // Wait for fade out animation
      await Future.delayed(const Duration(milliseconds: 250));

      if (!mounted) return;

      // Change page and fade in new content
      setState(() {
        _currentPage++;
        _contentOpacity = 1.0;
      });

      // Wait for fade in animation
      await Future.delayed(const Duration(milliseconds: 250));

      if (!mounted) return;

      // Reset transition state and start progress
      setState(() => _isTransitioning = false);
      _startProgress();
    } else {
      _finishOnboarding();
    }
  }

  void _skip() {
    _finishOnboarding();
  }

  Future<void> _finishOnboarding() async {
    _progressController.stop();

    // Fade out animation
    setState(() => _contentOpacity = 0.0);
    await Future.delayed(const Duration(milliseconds: 300));

    await LocalStorageService.setOnboardingComplete(true);
    if (mounted) {
      context.go(AppStrings.routeLogin);
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    // Calculate proportional sizes based on screen
    final imageHeight = screenHeight * 0.50;
    final horizontalPadding = screenWidth * 0.10;

    final pageData = _pages[_currentPage];

    // Override pageData color if we want specific custom colors not in theme
    // But trying to use theme colors for consistency
    // If AppThemeColors.error isn't the right "Red" for slide 3, we might need a custom one.
    // For now assuming the vibrant colors in theme are sufficient.

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        color: pageData.color,
        child: Stack(
          children: [
            // Content with fade animation
            AnimatedOpacity(
              opacity: _contentOpacity,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image section - full width, clip top
                  ClipRect(
                    child: SizedBox(
                      width: double.infinity,
                      height: imageHeight,
                      child: Image.asset(
                        pageData.image,
                        width: double.infinity,
                        height: imageHeight,
                        fit: BoxFit.cover,
                        alignment: Alignment.bottomCenter,
                        // Cache the image for performance
                        cacheWidth: (screenWidth * 2).toInt(),
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.white.withValues(alpha: 0.1),
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported_rounded,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Content section - bottom half
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),

                          // IgniSave Logo
                          Text(
                            'IgniSave',
                            style: AppTextStyles.headlineSmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Title
                          Text(
                            pageData.title,
                            style: AppTextStyles.headlineMedium.copyWith(
                              color: pageData.titleColor,
                              height: 1.2,
                              fontSize: 32, // Keep large size for onboarding
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Description
                          Text(
                            pageData.description,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: pageData.descColor,
                              height: 1.4,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Dots Indicator with animation
                          Row(
                            children: List.generate(_pages.length, (i) {
                              bool isActive = i == _currentPage;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.only(right: 10),
                                width: isActive ? 30 : 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(
                                    alpha: isActive ? 1.0 : 0.5,
                                  ),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              );
                            }),
                          ),

                          const Spacer(),

                          // Next Button
                          SizedBox(
                            width: double.infinity,
                            height: 56, // Taller button
                            child: ElevatedButton(
                              onPressed: _isTransitioning ? null : _nextPage,
                              style:
                                  ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: pageData.color,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        20,
                                      ), // Pill shape
                                    ),
                                    shadowColor: Colors.black.withValues(
                                      alpha: 0.2,
                                    ),
                                  ).copyWith(
                                    elevation: WidgetStateProperty.resolveWith((
                                      states,
                                    ) {
                                      if (states.contains(
                                        WidgetState.pressed,
                                      )) {
                                        return 0;
                                      }
                                      return 4; // Subtle shadow
                                    }),
                                  ),
                              child: Text(
                                'CONTINUE',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: pageData.color,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Skip Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: TextButton(
                              onPressed: _isTransitioning ? null : _skip,
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                'SKIP',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Progress Bars (NO fade animation, always visible)
            Positioned(
              top: statusBarHeight + 10,
              left: 16,
              right: 16,
              child: Row(
                children: List.generate(_pages.length, (index) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.5),
                      child: Stack(
                        children: [
                          // Background track
                          Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          // Progress
                          AnimatedBuilder(
                            animation: _progressController,
                            builder: (context, child) {
                              double widthFactor = 0.0;
                              if (index < _currentPage) {
                                widthFactor = 1.0;
                              } else if (index == _currentPage) {
                                widthFactor = _progressController.value;
                              } else {
                                widthFactor = 0.0;
                              }

                              return FractionallySizedBox(
                                widthFactor: widthFactor,
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPageData {
  final Color color;
  final String image;
  final String title;
  final String description;
  final Color titleColor;
  final Color descColor;

  const OnboardingPageData({
    required this.color,
    required this.image,
    required this.title,
    required this.description,
    required this.titleColor,
    required this.descColor,
  });
}
