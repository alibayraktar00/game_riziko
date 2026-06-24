import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class GameModeSelectionScreen extends StatelessWidget {
  const GameModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => context.go('/'),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: AppTheme.neonGradient,
        child: Stack(
          children: [
            // Soft decorative background glow circles (Mesh gradient effect)
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFD500F9).withValues(alpha: 0.08),
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
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.08),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
               .scale(begin: const Offset(1, 1), end: const Offset(1.15, 1.15), duration: 7.seconds)
               .blur(begin: const Offset(70, 70), end: const Offset(100, 100)),
            ),
            
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'OYUN MODU SEÇİN',
                      style: AppTheme.titleStyle.copyWith(fontSize: 32),
                    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0),
                    
                    const SizedBox(height: 60),
                    
                    // Single Device Mode
                    _ModeButton(
                      title: 'TEK CİHAZ',
                      subtitle: 'Aynı cihaz üzerinden sırayla oynayın',
                      icon: Icons.smartphone_rounded,
                      color1: const Color(0xFF00FF87),
                      color2: const Color(0xFF00D084),
                      onTap: () => context.go('/team-setup'),
                    ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideX(begin: -0.2, end: 0),
                    
                    const SizedBox(height: 24),
                    
                    // Multi-Device Mode
                    _ModeButton(
                      title: 'ÇOKLU CİHAZ',
                      subtitle: 'Herkes kendi cihazından katılsın',
                      icon: Icons.devices_rounded,
                      color1: const Color(0xFFFFD700),
                      color2: const Color(0xFFFF6B35),
                      onTap: () => _showMultiplayerOptions(context),
                    ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideX(begin: 0.2, end: 0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMultiplayerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.65),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 32),
                _OptionButton(
                  title: 'YÖNETİCİ GİRİŞİ',
                  icon: Icons.admin_panel_settings_rounded,
                  color: const Color(0xFFFF6B35),
                  onTap: () {
                    context.pop();
                    context.go('/admin');
                  },
                ),
                const SizedBox(height: 16),
                _OptionButton(
                  title: 'OYUNCU GİRİŞİ',
                  icon: Icons.videogame_asset_rounded,
                  color: const Color(0xFF00FF87),
                  onTap: () {
                    context.pop();
                    context.go('/player');
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color1;
  final Color color2;
  final VoidCallback onTap;

  const _ModeButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color1,
    required this.color2,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: color1.withValues(alpha: 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: color1.withValues(alpha: 0.15),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color1.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color1.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Icon(icon, color: color1, size: 32),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTheme.buttonStyle.copyWith(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: color1.withValues(alpha: 0.6), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _OptionButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 1.2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                Icon(Icons.chevron_right_rounded, color: color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
