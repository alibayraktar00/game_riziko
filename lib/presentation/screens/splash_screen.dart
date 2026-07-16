import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/glass_card.dart';

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
      body: Stack(
        children: [
          // Shared background treatment (same asset+overlay every screen uses)
          Positioned.fill(child: Container(decoration: AppTheme.neonGradient)),

          // Soft decorative background glow circles (Mesh gradient effect)
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD500F9).withValues(alpha: 0.12),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 6.seconds)
             .blur(begin: const Offset(60, 60), end: const Offset(90, 90)),
          ),
          Positioned(
            bottom: -120,
            left: -120,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .scale(begin: const Offset(1, 1), end: const Offset(1.15, 1.15), duration: 7.seconds)
             .blur(begin: const Offset(70, 70), end: const Offset(100, 100)),
          ),
          
          // Foreground Content
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  
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
                          child: GlassCard(
                            radius: AppRadius.hero,
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl, horizontal: AppSpacing.xl + 8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Premium logo image
                                Image.asset(
                                  'assets/images/logo.png',
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.contain,
                                  cacheWidth: 300,
                                  cacheHeight: 300,
                                ).animate(onPlay: (c) => c.repeat(reverse: true))
                                 .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 2.seconds, curve: Curves.easeInOut),
                                const SizedBox(height: AppSpacing.lg),
                                Text(
                                  'RİZİKO',
                                  style: AppTheme.titleStyle.copyWith(fontSize: 48, letterSpacing: 12),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  'Çok Oyunculu Quiz Deneyimi',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(letterSpacing: 1.5),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const Spacer(),
                  
                  // Animated Start Button
                  AnimatedBuilder(
                    animation: _buttonSlide,
                    builder: (context, child) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.5),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _buttonController,
                          curve: Curves.easeOutCubic,
                        )),
                        child: FadeTransition(
                          opacity: _buttonSlide,
                          child: child!,
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                      child: Container(
                        width: 280,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00FF87), Color(0xFF60EFFF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.button),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00FF87).withValues(alpha: 0.35),
                              blurRadius: 24,
                              spreadRadius: 1,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1.2,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => context.go('/mode-selection'),
                            borderRadius: BorderRadius.circular(20),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.play_arrow_rounded,
                                    color: Color(0xFF070913),
                                    size: 30,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'OYUNA BAŞLA',
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF070913),
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ).animate(onPlay: (c) => c.repeat(reverse: true))
                     .shimmer(duration: 4.seconds, color: Colors.white30),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
