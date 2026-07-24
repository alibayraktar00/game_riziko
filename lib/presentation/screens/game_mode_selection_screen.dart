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
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5), // Arkası net gözüksün diye blur çok çok aza indirildi
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.transparent, // Siyahlık tamamen kaldırıldı, tam şeffaf yapıldı
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15), // Sadece dış çerçeve belirgin kalsın diye ince bir kenarlık
                        width: 1.5,
                      ),
                    ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'MOD SEÇİMİ',
                            style: GoogleFonts.orbitron(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 3.0,
                              shadows: [
                                Shadow(
                                  color: const Color(0xFF00E5FF).withValues(alpha: 0.8),
                                  blurRadius: 12,
                                ),
                                Shadow(
                                  color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                                  blurRadius: 24,
                                ),
                              ],
                            ),
                          ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0),

                          const SizedBox(height: AppSpacing.xl), // Başlık ile butonlar arası yaklaştırıldı

                          // Single Device Mode (Tek Oyuncu)
                          _ImageModeButton(
                            bgAssetPath: 'assets/images/singleplayer_btn.png',
                            rippleColor: const Color(0xFF00E5FF), // Mavi parlama efekti
                            onTap: () => context.go('/team-setup'),
                          ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.1, end: 0),

                          const SizedBox(height: 6), // Butonları birbirine iyice yaklaştırmak için boşluk çok azaltıldı

                          // Multi-Device Mode (Çok Oyuncu)
                          _ImageModeButton(
                            bgAssetPath: 'assets/images/multiplayer_btn.png',
                            rippleColor: const Color(0xFFFFB300), // Metalik sarı parlama efekti
                            onTap: () => _showMultiplayerOptions(context),
                          ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.1, end: 0),
                        ],
                      ),
                    ),
                  ),
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

class _ImageModeButton extends StatefulWidget {
  final String bgAssetPath;
  final Color rippleColor;
  final VoidCallback onTap;

  const _ImageModeButton({
    required this.bgAssetPath,
    required this.rippleColor,
    required this.onTap,
  });

  @override
  State<_ImageModeButton> createState() => _ImageModeButtonState();
}

class _ImageModeButtonState extends State<_ImageModeButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0, // Basıldığında biraz daha belirgin küçülme
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: 420, // Butonlar biraz daha büyütüldü
          height: 200, // Yükseklik de orantılı olarak artırıldı
          color: Colors.transparent,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. Dışarıya taşan ışık saçması efekti (Outer Glow)
              AnimatedOpacity(
                opacity: _isPressed ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 150),
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 16, sigmaY: 16), // Işığın yayılma miktarı
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      widget.rippleColor,
                      BlendMode.srcIn, // Görselin şeklini alıp istenilen rengi basar
                    ),
                    child: Image.asset(
                      widget.bgAssetPath,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              
              // 2. Orijinal Görsel
              Image.asset(
                widget.bgAssetPath,
                fit: BoxFit.contain,
              ),

              // 3. Üstteki hafif renk atması (İç parlama efekti)
              if (_isPressed)
                ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    widget.rippleColor.withValues(alpha: 0.25),
                    BlendMode.srcATop,
                  ),
                  child: Image.asset(
                    widget.bgAssetPath,
                    fit: BoxFit.contain,
                  ),
                ),
            ],
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
