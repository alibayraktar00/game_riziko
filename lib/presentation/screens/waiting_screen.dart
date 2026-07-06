import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/riziko_scaffold.dart';

class WaitingScreen extends StatefulWidget {
  final String gameCode;
  final String playerId;
  
  const WaitingScreen({
    super.key,
    required this.gameCode,
    required this.playerId,
  });

  @override
  State<WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen> {
  late DatabaseReference _gameRef;
  late StreamSubscription<DatabaseEvent> _gameSubscription;
  late final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 2));
  bool _gameStarted = false;
  int _playerCount = 0;

  @override
  void initState() {
    super.initState();
    _gameRef = FirebaseDatabase.instance.ref('games/${widget.gameCode}');
    _listenToGameStatus();
    _listenToPlayerCount();
  }

  void _listenToGameStatus() {
    _gameSubscription = _gameRef.child('status').onValue.listen((event) {
      if (event.snapshot.value == 'started' && !_gameStarted) {
        setState(() {
          _gameStarted = true;
        });
        _confettiController.play();

        // Navigate to game screen
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            context.go('/game/${widget.gameCode}?playerId=${widget.playerId}');
          }
        });
      }
    });
  }

  void _listenToPlayerCount() {
    _gameRef.child('playerCount').onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          _playerCount = event.snapshot.value as int;
        });
      }
    });
  }

  @override
  void dispose() {
    _gameSubscription.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return RizikoScaffold(
      title: 'BEKLEME ODASI',
      leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: AlertDialog(
                  backgroundColor: const Color(0xFF0F1322).withValues(alpha: 0.95),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  title: Text(
                    'Odadan Çıkılsın mı?',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  content: Text(
                    'Bekleme odasından çıkmak istediğinize emin misiniz?',
                    style: GoogleFonts.outfit(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(
                        'HAYIR',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.go('/mode-selection');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF3B30),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'EVET',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      body: Stack(
        children: [
          Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_gameStarted) ...[
                  // Waiting Lottie Animation with Glow
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.primary.withValues(alpha: 0.05),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          blurRadius: 40,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Lottie.asset(
                        'assets/animations/loading.json',
                        width: 220,
                        height: 220,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: CircularProgressIndicator(color: colorScheme.primary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Waiting Info Card
                  GlassCard(
                    radius: AppRadius.hero,
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                          children: [
                            Text(
                              'Yönetici oyunu başlatmayı bekliyor...',
                              style: GoogleFonts.outfit(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: colorScheme.primary,
                                height: 1.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            Divider(color: Colors.white.withValues(alpha: 0.08)),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Oyun Kodu:',
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                ),
                                Text(
                                  widget.gameCode,
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Katılan Oyuncular:',
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                ),
                                Text(
                                  '$_playerCount',
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                  ),
                ] else ...[
                  // Game Started Animation (Glassmorphic)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00FF87), Color(0xFF60EFFF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00FF87).withValues(alpha: 0.4),
                              blurRadius: 30,
                              spreadRadius: 2,
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          size: 96,
                          color: Color(0xFF070913),
                        ),
                      ),
                    ),
                  ).animate().scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1.0, 1.0),
                    duration: 500.ms,
                    curve: Curves.elasticOut,
                  ),
                  const SizedBox(height: 48),
                  Text(
                    'OYUN BAŞLIYOR!',
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF00FF87),
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          color: const Color(0xFF00FF87).withValues(alpha: 0.4),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ).animate().scale(duration: 400.ms).then().shimmer(duration: 2.seconds),
                  const SizedBox(height: 16),
                  Text(
                    'Oyuna yönlendiriliyorsunuz...',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 24,
              gravity: 0.15,
            ),
          ),
        ],
      ),
    );
  }
}
