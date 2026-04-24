import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.quiz_rounded,
                  size: 100,
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .scaleXY(begin: 1.0, end: 1.05, duration: 2.seconds, curve: Curves.easeInOut),
              const SizedBox(height: 32),
              Text(
                'RIZIKO',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 8,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Theme.of(context).colorScheme.primary,
                          blurRadius: 20,
                        ),
                      ],
                    ),
              ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.5, end: 0, curve: Curves.easeOutBack),
              const SizedBox(height: 12),
              Text(
                'THE ULTIMATE TEAM QUIZ',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white54,
                      letterSpacing: 4,
                    ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.5, end: 0),
              const SizedBox(height: 64),
              ElevatedButton(
                onPressed: () => context.push('/team-setup'),
                child: const Text('START GAME'),
              ).animate().fadeIn(delay: 800.ms).scaleXY(begin: 0.8, end: 1.0, curve: Curves.easeOutBack),
            ],
          ),
        ),
      ),
    );
  }
}
