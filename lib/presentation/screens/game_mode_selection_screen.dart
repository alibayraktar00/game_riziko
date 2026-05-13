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
        child: SafeArea(
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
                  color1: const Color(0xFF00FF88),
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
      ),
    );
  }

  void _showMultiplayerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
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
              color: const Color(0xFF00FF88),
              onTap: () {
                context.pop();
                context.go('/player');
              },
            ),
            const SizedBox(height: 16),
          ],
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
        gradient: LinearGradient(
          colors: [color1, color2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color1.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
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
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 32),
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
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 20),
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
    return Material(
      color: Colors.white.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            border: Border.all(color: color.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(16),
          ),
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
    );
  }
}
