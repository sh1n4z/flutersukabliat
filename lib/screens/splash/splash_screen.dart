import 'package:flutter/material.dart';
import 'dart:math';
import '../../theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback? onFinish;

  const SplashScreen({Key? key, this.onFinish}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  // ... (Toàn bộ phần thân class không thay đổi) ...
  late AnimationController _containerFadeController;
  late AnimationController _logoScaleController;
  late AnimationController _logoBorderRotateController;
  late AnimationController _logoBorderScaleController;
  late AnimationController _brandFadeController;
  late AnimationController _taglineFadeController;
  late AnimationController _progressBarController;
  late AnimationController _loadingPulseController;
  late AnimationController _decorativeDotsController;
  late List<AnimationController> _particleControllers;

  late Animation<double> _containerFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoBorderScaleAnimation;
  late Animation<double> _brandFadeAnimation;
  late Animation<double> _taglineFadeAnimation;

  @override
  void initState() {
    super.initState();

    // Container fade animation
    _containerFadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _containerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _containerFadeController, curve: Curves.easeOut),
    );

    // Logo scale animation (delay: 0.2s)
    _logoScaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _logoScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _logoScaleController, curve: Curves.easeOut),
    );

    // Logo border rotation (infinite 20s)
    _logoBorderRotateController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    // Logo border scale pulse (infinite 2s)
    _logoBorderScaleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _logoBorderScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.05), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 50),
    ]).animate(_logoBorderScaleController);

    // Brand text fade (delay: 0.4s)
    _brandFadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _brandFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _brandFadeController, curve: Curves.easeOut),
    );

    // Tagline fade (delay: 0.6s)
    _taglineFadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _taglineFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _taglineFadeController, curve: Curves.easeOut),
    );

    // Progress bar animation (2.5s)
    _progressBarController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Loading pulse animation (1.5s infinite)
    _loadingPulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    // Decorative dots pulse (2s infinite)
    _decorativeDotsController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Initialize particle controllers (8 particles, 8-12s duration each)
    _particleControllers = List.generate(
      8,
      (index) => AnimationController(
        duration: Duration(milliseconds: 8000 + Random().nextInt(4000)),
        vsync: this,
      )..repeat(),
    );

    // Start animations with delays
    _containerFadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _logoScaleController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _brandFadeController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _taglineFadeController.forward();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _progressBarController.forward().then((_) {
          if (mounted) {
            widget.onFinish?.call();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _containerFadeController.dispose();
    _logoScaleController.dispose();
    _logoBorderRotateController.dispose();
    _logoBorderScaleController.dispose();
    _brandFadeController.dispose();
    _taglineFadeController.dispose();
    _progressBarController.dispose();
    _loadingPulseController.dispose();
    _decorativeDotsController.dispose();
    for (var controller in _particleControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ebonyDark,
      body: FadeTransition(
        opacity: _containerFadeAnimation,
        child: Stack(
          children: [
            // Background gradient
            Container(
              width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF2d2318),
                  Color(0xFF1a1410),
                  Color(0xFF0d0a08),
                ],
              ),
            ),
          ),

          // Wood grain texture overlay
          Opacity(
            opacity: 0.2,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'data:image/svg+xml,%3Csvg width="60" height="60" xmlns="http://www.w3.org/2000/svg"%3E%3Cdefs%3E%3Cpattern id="grain" width="60" height="60" patternUnits="userSpaceOnUse"%3E%3Cpath d="M 10 0 L 0 0 0 10" fill="none" stroke="white" stroke-width="0.5"/%3E%3C/pattern%3E%3C/defs%3E%3Crect width="100%25" height="100%25" fill="url(%23grain)"/%3E%3C/svg%3E',
                  ),
                  repeat: ImageRepeat.repeat,
                ),
              ),
            ),
          ),

          // Radial glow effect
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  AppColors.woodAccent.withOpacity(0.1),
                  Colors.transparent,
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),

          // Falling particles
          Stack(
            children: List.generate(
              8,
              (index) {
                final randomX = Random(index).nextDouble() * 407;
                final randomDelay = Random(index + 100).nextDouble() * 3000;
                return Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _particleControllers[index],
                    builder: (context, child) {
                      final value = (_particleControllers[index].value +
                          (randomDelay / (_particleControllers[index].duration!.inMilliseconds + randomDelay.toInt()))) %
                          1.0;
                      final currentY = value * 904 - 20;
                      final opacity = value < 0.2
                          ? value * 1.5
                          : (value > 0.8
                          ? (1 - value) * 5
                          : 0.3);
                      return Positioned(
                        left: randomX,
                        top: currentY,
                        child: Opacity(
                          opacity: opacity.clamp(0.0, 0.3),
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.woodAccent,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),

          // Main content
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo container with animated border
                  ScaleTransition(
                    scale: _logoScaleAnimation,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Animated rotating golden circle border
                        RotationTransition(
                          turns: Tween(begin: 0.0, end: 1.0).animate(
                            _logoBorderRotateController,
                          ),
                          child: ScaleTransition(
                            scale: _logoBorderScaleAnimation,
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.woodAccent.withOpacity(0.3),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Logo circle with gradient
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.woodAccent,
                                const Color(0xFF8b6f47),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(2),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF2d2318),
                                  Color(0xFF1a1410),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Image.asset(
                                'assets/images/logo1.png',
                                width: 80,
                                height: 80,
                                fit: BoxFit.contain,
                                errorBuilder: (c, e, s) => CustomPaint(
                                  size: const Size(60, 60),
                                  painter: WoodIconPainter(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Brand name with dividers
                  FadeTransition(
                    opacity: _brandFadeAnimation,
                    child: Material(
                      type: MaterialType.transparency,
                      child: Column(
                        children: [
                          const Text(
                            'EBONY',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                              letterSpacing: 8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 32,
                                height: 1,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Colors.transparent,
                                      AppColors.woodAccent,
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'FURNITURE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.woodAccent,
                                  letterSpacing: 6.4,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 32,
                                height: 1,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      AppColors.woodAccent,
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tagline
                  FadeTransition(
                    opacity: _taglineFadeAnimation,
                    child: Material(
                      type: MaterialType.transparency,
                      child: Text(
                        'Handcrafted Excellence',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.6),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Loading indicator
                  Column(
                    children: [
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 192,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: AnimatedBuilder(
                            animation: _progressBarController,
                            builder: (context, child) {
                              return Row(
                                children: [
                                  Flexible(
                                    flex: (_progressBarController.value * 100)
                                        .toInt(),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                          colors: [
                                            AppColors.woodAccent,
                                            const Color(0xFFd4af8e),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.woodAccent
                                                .withOpacity(0.6),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    flex: (100 -
                                        (_progressBarController.value * 100)
                                            .toInt()),
                                    child: const SizedBox.shrink(),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Loading text with pulse
                      AnimatedBuilder(
                        animation: _loadingPulseController,
                        builder: (context, child) {
                          final pulseValue = _loadingPulseController.value;
                          final opacity = 0.5 +
                              (pulseValue < 0.5
                                  ? pulseValue * 1.0
                                  : (1 - pulseValue) * 1.0);
                          return Opacity(
                            opacity: opacity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    color: AppColors.woodAccent,
                                    strokeWidth: 1.5,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Loading your experience...',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white.withOpacity(0.4),
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 48),

                  // Decorative dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (i) => AnimatedBuilder(
                        animation: _decorativeDotsController,
                        builder: (context, child) {
                          final delayedValue =
                              (_decorativeDotsController.value - (i * 0.2)) %
                                  1.0;
                          final scale = 1.0 +
                              (delayedValue < 0.5
                                  ? delayedValue * 0.2
                                  : (1 - delayedValue) * 0.2);
                          final opacity = 0.3 +
                              (delayedValue < 0.5
                                  ? delayedValue * 0.3
                                  : (1 - delayedValue) * 0.3);
                          return Opacity(
                            opacity: opacity,
                            child: Transform.scale(
                              scale: scale,
                              child: Container(
                                width: 4,
                                height: 4,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.woodAccent,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}

class WoodIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.woodAccent
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Vertical center line
    canvas.drawLine(
      Offset(centerX, centerY - 20),
      Offset(centerX, centerY + 20),
      paint,
    );

    // Left wood pattern
    canvas.drawLine(
      Offset(centerX - 10, centerY - 15),
      Offset(centerX - 5, centerY - 10),
      paint,
    );
    canvas.drawLine(
      Offset(centerX - 5, centerY - 10),
      Offset(centerX - 10, centerY - 5),
      paint,
    );
    canvas.drawLine(
      Offset(centerX - 10, centerY),
      Offset(centerX - 5, centerY + 5),
      paint,
    );
    canvas.drawLine(
      Offset(centerX - 5, centerY + 5),
      Offset(centerX - 10, centerY + 10),
      paint,
    );

    // Right wood pattern
    canvas.drawLine(
      Offset(centerX + 10, centerY - 15),
      Offset(centerX + 5, centerY - 10),
      paint,
    );
    canvas.drawLine(
      Offset(centerX + 5, centerY - 10),
      Offset(centerX + 10, centerY - 5),
      paint,
    );
    canvas.drawLine(
      Offset(centerX + 10, centerY),
      Offset(centerX + 5, centerY + 5),
      paint,
    );
    canvas.drawLine(
      Offset(centerX + 5, centerY + 5),
      Offset(centerX + 10, centerY + 10),
      paint,
    );
  }

  @override
  bool shouldRepaint(WoodIconPainter oldDelegate) => false;
}
