import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

class AuthBackground extends StatefulWidget {
  const AuthBackground({super.key});

  @override
  State<AuthBackground> createState() => _AuthBackgroundState();
}

class _AuthBackgroundState extends State<AuthBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _anim1;
  late final Animation<double> _anim2;
  late final Animation<double> _anim3;

  // Reference design size
  static const double _designWidth = 402.0;
  static const double _designHeight = 874.0;

  double _scaleW(BuildContext context, double value) {
    return value * (MediaQuery.of(context).size.width / _designWidth);
  }

  double _scaleH(BuildContext context, double value) {
    return value * (MediaQuery.of(context).size.height / _designHeight);
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _anim1 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOutSine),
    );
    _anim2 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeInOutSine),
      ),
    );
    _anim3 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeInOutSine),
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // --- Animated Background Layers ---
        AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return Stack(
              children: [
                // 1. Black rotated background (StyledVector3)
                Positioned(
                  left: _scaleW(context, 645.18 + (_anim1.value * 20)),
                  top: _scaleH(context, 330.02 + (_anim1.value * 10)),
                  child: Transform.rotate(
                    angle: (-141 + (_anim1.value * 2)) * (math.pi / 180),
                    alignment: Alignment.topLeft,
                    child: Container(
                      width: _scaleW(context, 1091.02),
                      height: _scaleH(context, 848.37),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                    ),
                  ),
                ),

                // 2. Blue rotated shape (StyledVector1)
                Positioned(
                  left: _scaleW(context, 375.77 - (_anim2.value * 20)),
                  top: _scaleH(context, -377.94 + (_anim2.value * 10)),
                  child: Transform.rotate(
                    angle: (39 - (_anim2.value * 2)) * (math.pi / 180),
                    alignment: Alignment.topLeft,
                    child: Container(
                      width: _scaleW(context, 727.61),
                      height: _scaleH(context, 477.30),
                      color: const Color(0xFF146C94),
                    ),
                  ),
                ),

                // 3. Cyan shape 1 (StyledVector2)
                Positioned(
                  left: _scaleW(context, -113.16 + (_anim3.value * 15)),
                  top: _scaleH(context, -266 - (_anim3.value * 10)),
                  child: Transform.rotate(
                    angle: (18 + (_anim3.value * 2)) * (math.pi / 180),
                    alignment: Alignment.topLeft,
                    child: Container(
                      width: _scaleW(context, 747.14),
                      height: _scaleH(context, 240.43),
                      color: const Color(0xFF19A7CE).withValues(alpha: 0.50),
                    ),
                  ),
                ),

                // 4. Cyan shape 2 (StyledVector4)
                Positioned(
                  left: _scaleW(context, 148.84 - (_anim1.value * 15)),
                  top: _scaleH(context, -7 + (_anim1.value * 10)),
                  child: Transform.rotate(
                    angle: (18 - (_anim1.value * 2)) * (math.pi / 180),
                    alignment: Alignment.topLeft,
                    child: Container(
                      width: _scaleW(context, 747.14),
                      height: _scaleH(context, 240.43),
                      color: const Color(0xFF19A7CE).withValues(alpha: 0.50),
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        // 5. Blur effect (Static overlay)
        // Matched to OnboardingScreen (sigma 30)
        Positioned(
          left: _scaleW(context, -7),
          top: _scaleH(context, -247),
          child: RepaintBoundary(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 50,
                  sigmaY: 50,
                ), // Increased to 50 for softer look
                child: Container(
                  width: _scaleW(context, 424),
                  height: _scaleH(context, 874),
                  color: const Color(0xFF0C0C0C).withValues(alpha: 0.02),
                ),
              ),
            ),
          ),
        ),

        // 6. Gradient overlay (Static)
        Positioned(
          left: _scaleW(context, -18),
          top: _scaleH(context, -295),
          child: RepaintBoundary(
            child: Container(
              width: _scaleW(context, 435),
              height: _scaleH(context, 748),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0C0C0C).withValues(alpha: 0.02),
                    const Color(0xFF0C0C0C).withValues(alpha: 0.0),
                  ],
                  stops: const [0.75, 1.0],
                ),
              ),
            ),
          ),
        ),

        // 7. Noise Overlay (Masked to top area)
        Positioned.fill(
          child: RepaintBoundary(
            child: IgnorePointer(
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white, // Visible at top
                      Colors.transparent, // Invisible at bottom
                    ],
                    stops: [0.0, 0.6], // Fade out around 60% down
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: CustomPaint(painter: NoisePainter()),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class NoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.square;

    final random = math.Random(1337);
    // Matched to OnboardingScreen (8000 points)
    final points = List.generate(
      8000,
      (index) => Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      ),
    );

    canvas.drawPoints(PointMode.points, points, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
