import 'dart:math' as math;
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const SplashScreen({super.key, required this.onFinish});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _progressController;
  late AnimationController _rotationController;
  late AnimationController _particleController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _textYAnimation;

  final List<Particle> _particles = List.generate(8, (index) => Particle());

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.2, 0.6, curve: Curves.easeOut)),
    );

    _textYAnimation = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.4, 0.8, curve: Curves.easeOut)),
    );

    _mainController.forward();
    _progressController.forward().then((_) => widget.onFinish());
  }

  @override
  void dispose() {
    _mainController.dispose();
    _progressController.dispose();
    _rotationController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color ebonyBackgroundTop = Color(0xFF2D2318);
    const Color ebonyBackgroundMid = Color(0xFF1A1410);
    const Color ebonyBackgroundBottom = Color(0xFF0D0A08);
    const Color goldAccent = Color(0xFFA88860);
    const Color goldLight = Color(0xFFD4AF8E);

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // Background with gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [ebonyBackgroundTop, ebonyBackgroundMid, ebonyBackgroundBottom],
                ),
              ),
            ),

            // Radial glow effect
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.8,
                    colors: [
                      goldAccent.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Particles
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ParticlePainter(
                    particles: _particles,
                    progress: _particleController.value,
                    color: goldAccent,
                  ),
                  size: Size.infinite,
                );
              },
            ),

            // Main Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Container
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Animated golden circle
                        RotationTransition(
                          turns: _rotationController,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: goldAccent.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        // Logo Circle
                        Container(
                          width: 128,
                          height: 128,
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [goldAccent, Color(0xFF8B6F47)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black54,
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              )
                            ],
                          ),
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [ebonyBackgroundTop, ebonyBackgroundMid],
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(64),
                              child: Image.asset(
                                'assets/images/logo1.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Brand Name
                  AnimatedBuilder(
                    animation: _textYAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _textYAnimation.value),
                        child: Opacity(
                          opacity: (1 - (_textYAnimation.value / 20)).clamp(0.0, 1.0),
                          child: Column(
                            children: [
                              const Text(
                                "EBONY",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  letterSpacing: 10,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(height: 1, width: 32, color: goldAccent.withOpacity(0.5)),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(
                                      "FURNITURE",
                                      style: TextStyle(
                                        color: goldAccent,
                                        fontSize: 10,
                                        letterSpacing: 4,
                                      ),
                                    ),
                                  ),
                                  Container(height: 1, width: 32, color: goldAccent.withOpacity(0.5)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // Tagline
                  const Text(
                    "Handcrafted Excellence",
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Loading Indicator
                  Column(
                    children: [
                      // Progress bar
                      Container(
                        width: 192,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: AnimatedBuilder(
                          animation: _progressController,
                          builder: (context, child) {
                            return FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: _progressController.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [goldAccent, goldLight],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: goldAccent.withOpacity(0.5),
                                      blurRadius: 8,
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Loading Text
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(goldAccent),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Loading your experience...",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 10,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Bottom dots
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) => _PulsingDot(index: index, color: goldAccent)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final int index;
  final Color color;
  const _PulsingDot({required this.index, required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    Future.delayed(Duration(milliseconds: widget.index * 200), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 4,
          height: 4,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withOpacity(0.3 + (_controller.value * 0.3)),
          ),
        );
      },
    );
  }
}

class Particle {
  late double x;
  late double y;
  late double speed;
  late double delay;

  Particle() {
    reset();
    y = math.Random().nextDouble(); // Start at random Y initially
  }

  void reset() {
    x = math.Random().nextDouble();
    y = -0.1;
    speed = 0.5 + math.Random().nextDouble() * 0.5;
    delay = math.Random().nextDouble() * 3;
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;
  final Color color;

  ParticlePainter({required this.particles, required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    for (var particle in particles) {
      double currentY = (progress * particle.speed + particle.delay) % 1.2 - 0.1;
      double opacity = 0.0;
      if (currentY > 0 && currentY < 1) {
        opacity = (1.0 - (currentY - 0.5).abs() * 2.0).clamp(0.0, 0.3);
      }

      paint.color = color.withOpacity(opacity);
      canvas.drawCircle(
        Offset(particle.x * size.width, currentY * size.height),
        1.5,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
