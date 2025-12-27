import 'package:flutter/material.dart';
import 'dart:math' as math;

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _breathingController;
  late AnimationController _textController;
  late AnimationController _loadingController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoBlur;
  late Animation<double> _logoTranslateY;
  late Animation<double> _breathingGlow;
  late Animation<double> _textOpacity;
  late Animation<double> _textTranslateY;

  @override
  void initState() {
    super.initState();

    // Logo animation controller (soft-enter)
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Breathing glow animation
    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Text reveal animation
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Loading bar animation
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Logo animations
    _logoScale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Cubic(0.2, 0.8, 0.2, 1),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Cubic(0.2, 0.8, 0.2, 1),
      ),
    );

    _logoBlur = Tween<double>(begin: 8.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Cubic(0.2, 0.8, 0.2, 1),
      ),
    );

    _logoTranslateY = Tween<double>(begin: 10.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Cubic(0.2, 0.8, 0.2, 1),
      ),
    );

    // Breathing glow animation
    _breathingGlow = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: Curves.easeInOut,
      ),
    );

    // Text animations
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOut,
      ),
    );

    _textTranslateY = Tween<double>(begin: 5.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOut,
      ),
    );

    // Start animations
    _logoController.forward();
    _breathingController.repeat(reverse: true);
    _loadingController.repeat();

    // Delay text animation
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _textController.forward();
      }
    });

    // Navigate to home after splash
    _navigateToHome();
  }

  void _navigateToHome() {
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _breathingController.dispose();
    _textController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111121) : const Color(0xFFF6F6F8),
      body: Stack(
        children: [
          // Background blur circles
          Positioned(
            top: -screenSize.height * 0.1,
            right: -screenSize.width * 0.1,
            child: Container(
              width: screenSize.width * 0.6,
              height: screenSize.width * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2D2DE6).withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -screenSize.height * 0.1,
            left: -screenSize.width * 0.1,
            child: Container(
              width: screenSize.width * 0.7,
              height: screenSize.width * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.shade400.withOpacity(0.05),
              ),
            ),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated logo
                AnimatedBuilder(
                  animation: Listenable.merge([_logoController, _breathingController]),
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _logoTranslateY.value),
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: Opacity(
                          opacity: _logoOpacity.value,
                          child: _buildLogo(isDark),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // Animated text
                AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _textTranslateY.value),
                      child: Opacity(
                        opacity: _textOpacity.value,
                        child: Column(
                          children: [
                            Text(
                              'DeutschCards',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                color: isDark ? Colors.white : const Color(0xFF0E0E1B),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Учи немецкий играючи',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Loading indicator at bottom
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _textController,
              builder: (context, child) {
                return Opacity(
                  opacity: _textOpacity.value * 0.6,
                  child: Column(
                    children: [
                      // Loading bar
                      Container(
                        width: 48,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: AnimatedBuilder(
                            animation: _loadingController,
                            builder: (context, child) {
                              return CustomPaint(
                                painter: _LoadingBarPainter(
                                  progress: _loadingController.value,
                                  color: const Color(0xFF2D2DE6),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'LOADING',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(bool isDark) {
    return AnimatedBuilder(
      animation: _breathingController,
      builder: (context, child) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Glow effect behind logo
            Positioned.fill(
              child: Transform.scale(
                scale: 1.1,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2D2DE6).withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Main logo container with breathing glow
            Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF2D2DE6),
                    Color(0xFF4C4CFF),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? Colors.white.withOpacity(0.1) : Colors.white,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(
                      45,
                      45,
                      230,
                      _breathingGlow.value,
                    ),
                    blurRadius: 25 + (_breathingGlow.value * 40),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Center(
                child: Transform.rotate(
                  angle: -6 * math.pi / 180, // -6 degrees rotation
                  child: const Icon(
                    Icons.style,
                    size: 64,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bolt badge
            Positioned(
              top: -8,
              right: -8,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF111121) : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.bolt,
                    size: 20,
                    color: Color(0xFF2D2DE6),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Custom painter for loading bar animation
class _LoadingBarPainter extends CustomPainter {
  final double progress;
  final Color color;

  _LoadingBarPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Calculate position and width based on progress
    double width;
    double marginLeft;

    if (progress < 0.5) {
      // First half: grow and move
      width = size.width * 0.6 * (progress * 2);
      marginLeft = size.width * 0.2 * (progress * 2);
    } else {
      // Second half: shrink and move out
      width = size.width * 0.6 * (1 - (progress - 0.5) * 2);
      marginLeft = size.width * 0.2 + size.width * 0.8 * ((progress - 0.5) * 2);
    }

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(marginLeft, 0, width.clamp(0, size.width - marginLeft), size.height),
      const Radius.circular(3),
    );

    canvas.drawRRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _LoadingBarPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
