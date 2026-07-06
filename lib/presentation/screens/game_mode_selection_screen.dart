import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/riziko_scaffold.dart';

class GameModeSelectionScreen extends StatelessWidget {
  const GameModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RizikoScaffold(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => context.go('/'),
      ),
      body: Stack(
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

          // Sparkle star decoration at bottom right
          Positioned(
            bottom: 40,
            right: 40,
            child: Opacity(
              opacity: 0.3,
              child: const Icon(
                Icons.star_rounded,
                size: 36,
                color: Colors.white,
              ).animate(onPlay: (c) => c.repeat(reverse: true))
               .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.3, 1.3), duration: 2.seconds),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'MOD SEÇİMİ',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(letterSpacing: 2.5),
                  ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0),

                  const SizedBox(height: AppSpacing.xxl),

                  // Single Device Mode (Tek Oyuncu)
                  _ModeCard(
                    title: 'TEK OYUNCU',
                    subtitle: 'Kendi başına oyna,\nbecerilerini geliştir.',
                    glowColor: const Color(0xFF00E5FF), // Cyan glow
                    bgAssetPath: 'assets/images/singleplayer_btn.png',
                    onTap: () => context.go('/team-setup'),
                  ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: AppSpacing.lg + 4),

                  // Multi-Device Mode (Çok Oyuncu)
                  _ModeCard(
                    title: 'ÇOK OYUNCU',
                    subtitle: 'Arkadaşlarınla veya dünyadaki\ndiğer oyuncularla yarış!',
                    glowColor: const Color(0xFFFFB300), // Orange/Gold glow
                    bgAssetPath: 'assets/images/multiplayer_btn.png',
                    onTap: () => _showMultiplayerOptions(context),
                  ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.1, end: 0),
                ],
              ),
            ),
          ),
        ],
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

class _ModeCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final Color glowColor;
  final String bgAssetPath;
  final VoidCallback onTap;

  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.glowColor,
    required this.bgAssetPath,
    required this.onTap,
  });

  @override
  State<_ModeCard> createState() => _ModeCardState();
}

class _ModeCardState extends State<_ModeCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: 320,
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            image: DecorationImage(
              image: AssetImage(widget.bgAssetPath),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withValues(alpha: _isPressed ? 0.4 : 0.22),
                blurRadius: _isPressed ? 32 : 20,
                spreadRadius: _isPressed ? 2 : -1,
              ),
            ],
            border: Border.all(
              color: widget.glowColor.withValues(alpha: _isPressed ? 0.75 : 0.35),
              width: _isPressed ? 2.5 : 1.5,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.8),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title
                Text(
                  widget.title,
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        color: widget.glowColor.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                // Subtitle
                Text(
                  widget.subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
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
                const SizedBox(width: AppSpacing.md),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(color: color, letterSpacing: 1.2),
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
