import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:tabib/screens/auth/login_screen.dart';
import 'package:tabib/screens/home/home_screen.dart';

class TabibHMSSplashScreen extends StatefulWidget {
  const TabibHMSSplashScreen({super.key});

  @override
  State<TabibHMSSplashScreen> createState() => _TabibHMSSplashScreenState();
}

class _TabibHMSSplashScreenState extends State<TabibHMSSplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late AnimationController _backgroundController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _progressValue;
  late Animation<double> _pulseScale;
  late Animation<double> _backgroundAnimation;

  // Professional color scheme
  static const Color primaryBlue = Color(0xFF0B7285);
  static const Color secondaryBlue = Color(0xFF0891B2);
  static const Color backgroundColor = Color(0xFFF8FFFE);
  static const Color headingTextColor = Color(0xFF0E7490);
  static const Color secondaryTextColor = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOut),
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic));

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    _progressValue = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseScale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );
  }

  void _startAnimationSequence() async {
    _backgroundController.forward();
    
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    _pulseController.repeat(reverse: true);

    await Future.delayed(const Duration(milliseconds: 600));
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    _progressController.forward();

    await Future.delayed(const Duration(milliseconds: 3000));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Login()),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    _pulseController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: AnimatedBuilder(
        animation: _backgroundController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  backgroundColor,
                  backgroundColor.withOpacity(0.95),
                  primaryBlue.withOpacity(0.05),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Professional background pattern
                CustomPaint(
                  painter: MedicalPatternPainter(_backgroundAnimation.value),
                  size: Size.infinite,
                ),
                
                // Main content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Professional logo with enhanced design
                      AnimatedBuilder(
                        animation: _logoController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _logoScale.value,
                            child: Opacity(
                              opacity: _logoOpacity.value,
                              child: AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _pulseScale.value,
                                    child: Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(24),
                                        boxShadow: [
                                          BoxShadow(
                                            color: primaryBlue.withOpacity(0.2),
                                            blurRadius: 40,
                                            offset: const Offset(0, 15),
                                            spreadRadius: 5,
                                          ),
                                          BoxShadow(
                                            color: secondaryBlue.withOpacity(0.1),
                                            blurRadius: 20,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Container(
                                        margin: const EdgeInsets.all(24),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              primaryBlue,
                                              secondaryBlue,
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: const Icon(
                                          Icons.local_hospital_rounded,
                                          size: 42,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 40),

                      // Enhanced professional text
                      AnimatedBuilder(
                        animation: _textController,
                        builder: (context, child) {
                          return SlideTransition(
                            position: _textSlide,
                            child: Opacity(
                              opacity: _textOpacity.value,
                              child: Column(
                                children: [
                                  ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: [primaryBlue, secondaryBlue],
                                    ).createShader(bounds),
                                    child: const Text(
                                      "Tabib HMS",
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "Health Management System",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: headingTextColor,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20, 
                                      vertical: 8
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          primaryBlue.withOpacity(0.1),
                                          secondaryBlue.withOpacity(0.1),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: primaryBlue.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      "Professional Healthcare Solution",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: primaryBlue,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 80),

                      // Enhanced progress indicator
                      AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          return Column(
                            children: [
                              Container(
                                width: 240,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: secondaryTextColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Stack(
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 100),
                                      width: 240 * _progressValue.value,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [primaryBlue, secondaryBlue],
                                        ),
                                        borderRadius: BorderRadius.circular(2),
                                        boxShadow: [
                                          BoxShadow(
                                            color: primaryBlue.withOpacity(0.4),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                "Initializing Healthcare System...",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: secondaryTextColor,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Professional branding footer
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _textOpacity.value * 0.7,
                        child: Column(
                          children: [
                            Text(
                              "Powered by Advanced Medical Technology",
                              style: TextStyle(
                                fontSize: 12,
                                color: secondaryTextColor.withOpacity(0.8),
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: primaryBlue.withOpacity(0.6),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Version 2.0",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: secondaryTextColor.withOpacity(0.6),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
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
        },
      ),
    );
  }
}

class MedicalPatternPainter extends CustomPainter {
  final double animation;
  static const Color primaryBlue = Color(0xFF0B7285);
  static const Color secondaryBlue = Color(0xFF0891B2);

  MedicalPatternPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryBlue.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    // Draw subtle medical crosses pattern
    for (double x = 0; x < size.width; x += 100) {
      for (double y = 0; y < size.height; y += 100) {
        final opacity = (math.sin(animation * 2 * math.pi + x * 0.008) + 1) / 2;
        paint.color = primaryBlue.withOpacity(0.015 * opacity);
        
        // Draw enhanced cross
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(x, y), width: 16, height: 4),
            const Radius.circular(2),
          ),
          paint,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(x, y), width: 4, height: 16),
            const Radius.circular(2),
          ),
          paint,
        );
      }
    }

    // Draw elegant pulse rings
    final ringPaint = Paint()
      ..color = secondaryBlue.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);
    for (int i = 0; i < 4; i++) {
      final radius = 180 + (i * 60) + (math.sin(animation * 2 * math.pi) * 15);
      final opacity = 1 - (i * 0.2);
      ringPaint.color = primaryBlue.withOpacity(0.02 * opacity);
      canvas.drawCircle(center, radius, ringPaint);
    }

    // Add floating particles
    final particlePaint = Paint()
      ..color = primaryBlue.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * math.pi + animation * math.pi;
      final radius = 120 + math.sin(animation * 3 * math.pi + i) * 20;
      final x = center.dx + math.cos(angle) * radius;
      final y = center.dy + math.sin(angle) * radius;
      
      canvas.drawCircle(
        Offset(x, y),
        2 + math.sin(animation * 4 * math.pi + i) * 1,
        particlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}