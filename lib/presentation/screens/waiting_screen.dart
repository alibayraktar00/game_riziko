import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'BEKLEME EKRANI',
          style: GoogleFonts.orbitron(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: const Color(0xFFFFD700),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: AppTheme.neonGradient,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_gameStarted) ...[
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Lottie.asset(
                    'assets/animations/loading.json',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Yönetici oyunu başlatmayı bekliyor...',
                  style: GoogleFonts.orbitron(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFFD700),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Oyun Kodu: ${widget.gameCode}',
                  style: GoogleFonts.orbitron(
                    fontSize: 18,
                    color: const Color(0xFFF1F5F9),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Katılan Oyuncular: $_playerCount',
                  style: GoogleFonts.orbitron(
                    fontSize: 16,
                    color: const Color(0xFFF1F5F9),
                  ),
                ),
              ] else ...[
                // Game Started Animation
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00FF88), Color(0xFF00D084)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00FF88).withValues(alpha: 0.4),
                        blurRadius: 30,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'OYUN BAŞLIYOR!',
                  style: GoogleFonts.orbitron(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00FF88),
                    shadows: [
                      const Shadow(
                        color:  Color(0xFF00FF88),
                        blurRadius: 20,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Oyuna yönlendiriliyorsunuz...',
                  style: GoogleFonts.orbitron(
                    fontSize: 16,
                    color: const Color(0xFFF1F5F9),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
