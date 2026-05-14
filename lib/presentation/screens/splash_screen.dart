import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _titleController;
  late AnimationController _buttonController;
  late Animation<double> _titleScale;
  late Animation<double> _titleOpacity;
  late Animation<double> _buttonSlide;

  @override
  void initState() {
    super.initState();
    
    _titleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _titleScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _titleController,
      curve: Curves.elasticOut,
    ));

    _titleOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _titleController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _buttonSlide = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeOutBack,
    ));

    _startAnimations();
  }

  void _startAnimations() async {
    _titleController.forward();
    
    await Future.delayed(const Duration(seconds: 1));
    _buttonController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.neonGradient,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated RIZIKO Title
              AnimatedBuilder(
                animation: _titleScale,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _titleScale.value,
                    child: AnimatedBuilder(
                      animation: _titleOpacity,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _titleOpacity.value,
                          child: child!,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 2,
                          ),
                          boxShadow: [
                            AppTheme.neonShadow,
                            BoxShadow(
                              color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
                              blurRadius: 40,
                              spreadRadius: -10,
                              offset: const Offset(0, -10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.quiz_rounded,
                              size: 80,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Color(0xFFFFD700),
                                  blurRadius: 20,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'RİZİKO',
                              style: AppTheme.titleStyle,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 80),
              
              // Animated Buttons
              AnimatedBuilder(
                animation: _buttonSlide,
                builder: (context, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 1.0),
                      end: Offset.zero,
                    ).animate(_buttonController),
                    child: FadeTransition(
                      opacity: _buttonSlide,
                      child: child!,
                    ),
                  );
                },
                child: Column(
                  children: [
                    // Start Button
                    Container(
                      width: 280,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00FF88), Color(0xFF00D084)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          AppTheme.neonShadow,
                          BoxShadow(
                            color: const Color(0xFF00FF88).withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => context.go('/mode-selection'),
                          borderRadius: BorderRadius.circular(16),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.play_arrow_rounded,
                                  color: Color(0xFF1A1A2E),
                                  size: 32,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'OYUNA BAŞLA',
                                  style: AppTheme.buttonStyle,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
