import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/language_picker_button.dart';

extension DurationExtensions on int {
  Duration get ms => Duration(milliseconds: this);
  Duration get seconds => Duration(seconds: this);
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [
              colorScheme.primary.withValues(alpha: 0.15),
              const Color(0xFF131B2F),
              const Color(0xFF0B0F19),
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Decorative background elements
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.secondary.withValues(alpha: 0.05),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
               .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 5.seconds)
               .blur(begin: const Offset(50, 50), end: const Offset(80, 80)),
            ),
            
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    // Logo with Glow
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [colorScheme.primary, colorScheme.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withValues(alpha: 0.5),
                              blurRadius: 40,
                              spreadRadius: 5,
                            ),
                            BoxShadow(
                              color: colorScheme.secondary.withValues(alpha: 0.3),
                              blurRadius: 60,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.quiz_rounded, size: 80, color: Colors.white),
                      ).animate(onPlay: (c) => c.repeat(reverse: true))
                       .shimmer(duration: 3.seconds, color: Colors.white24)
                       .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 2.seconds, curve: Curves.easeInOut),
                    ),
                  const SizedBox(height: 40),
                    
                    // Title
                    Text(
                      'RIZIKO',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 12,
                            color: Colors.white,
                            fontSize: 64,
                            shadows: [
                              Shadow(color: colorScheme.primary, blurRadius: 20),
                            ],
                          ),
                    ).animate().fadeIn(duration: 1.seconds).slideY(begin: 0.2, end: 0),
                    
                    Text(
                      'THE ULTIMATE TEAM QUIZ',
                      style: TextStyle(
                        color: colorScheme.primary.withValues(alpha: 0.7),
                        letterSpacing: 6,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ).animate().fadeIn(delay: 500.ms),
                    
                    const Spacer(),
                    
                    // Main Action
                    SizedBox(
                      width: double.infinity,
                      height: 64,
                      child: ElevatedButton(
                        onPressed: () => context.push('/team-setup'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 10,
                          shadowColor: colorScheme.primary.withValues(alpha: 0.5),
                        ),
                        child: const Text(
                          'OYUNA BAŞLA',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2),
                        ),
                      ),
                    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.5, end: 0),
                    
                    const SizedBox(height: 24),
                    
                    // Multiplayer Section (Glassmorphism)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'ÇOK OYUNCULU',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: _MultiplayerButton(
                                      onPressed: () => _createMultiplayerGame(context, ref),
                                      icon: Icons.add_box_rounded,
                                      label: 'OLUŞTUR',
                                      color: Colors.greenAccent,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _MultiplayerButton(
                                      onPressed: () => context.push('/multiplayer/scan'),
                                      icon: Icons.qr_code_scanner_rounded,
                                      label: 'KATIL',
                                      color: Colors.orangeAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 1.seconds).scaleXY(begin: 0.9, end: 1),
                    
                    const SizedBox(height: 40),
                    const LanguagePickerButton().animate().fadeIn(delay: 1.2.seconds),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createMultiplayerGame(BuildContext context, WidgetRef ref) async {
    try {
      final sessionId = 'mock-session-id';
      if (context.mounted) {
        context.push('/multiplayer/qr/$sessionId');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Oyun oluşturulamadı: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _MultiplayerButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color color;

  const _MultiplayerButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
