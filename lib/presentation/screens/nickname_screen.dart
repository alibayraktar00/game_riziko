import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class NicknameScreen extends StatefulWidget {
  final String gameCode;
  
  const NicknameScreen({
    super.key,
    required this.gameCode,
  });

  @override
  State<NicknameScreen> createState() => _NicknameScreenState();
}

class _NicknameScreenState extends State<NicknameScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  bool _isJoining = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _joinGame() async {
    if (_nicknameController.text.trim().isEmpty) {
      _showError('Lütfen bir takma ad girin');
      return;
    }

    setState(() {
      _isJoining = true;
    });

    try {
      final playerId = const Uuid().v4();
      final gameRef = FirebaseDatabase.instance.ref('games/${widget.gameCode}');
      
      // Check if game exists
      final snapshot = await gameRef.child('status').get().timeout(const Duration(seconds: 5));
      if (!snapshot.exists) {
        throw 'Geçersiz oyun kodu. Lütfen tekrar taratın.';
      }

      // Add player to game
      await gameRef.child('players').child(playerId).set({
        'nickname': _nicknameController.text.trim(),
        'joinedAt': ServerValue.timestamp,
        'uid': playerId,
        'score': 0,
      }).timeout(const Duration(seconds: 5));

      // Update player count using increment (more reliable than transaction)
      await gameRef.child('playerCount').set(ServerValue.increment(1)).timeout(const Duration(seconds: 5));

      if (mounted) {
        context.go('/waiting?code=${widget.gameCode}&playerId=$playerId');
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = e.toString();
        if (e is TimeoutException) {
          errorMsg = 'Bağlantı zaman aşımına uğradı. Lütfen internetinizi kontrol edin.';
        }
        _showError(errorMsg);
      }
    } finally {
      setState(() {
        _isJoining = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.orbitron(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFFF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TAKMA ADI',
          style: GoogleFonts.orbitron(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/player'),
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: const Color(0xFFFFD700),
        elevation: 0,
      ),
      body: Container(
        decoration: AppTheme.neonGradient,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Game Code Display
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: AppTheme.cardGradient,
                  child: Column(
                    children: [
                      Text(
                        'OYUN KODU',
                        style: GoogleFonts.orbitron(
                          fontSize: 16,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.gameCode,
                        style: GoogleFonts.orbitron(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFFD700),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Nickname Input
                Container(
                  width: 320,
                  padding: const EdgeInsets.all(32),
                  decoration: AppTheme.cardGradient,
                  child: Column(
                    children: [
                      Icon(
                        Icons.person,
                        size: 64,
                        color: const Color(0xFFFFD700),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Takma Adını Gir',
                        style: GoogleFonts.orbitron(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFFD700),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _nicknameController,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.orbitron(
                          fontSize: 18,
                          color: const Color(0xFFF1F5F9),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Takma adı',
                          hintStyle: GoogleFonts.orbitron(
                            color: const Color(0xFF94A3B8),
                            fontSize: 16,
                          ),
                          filled: true,
                          fillColor: const Color(0xFF1A1A2E).withValues(alpha: 0.6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFFFD700),
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFFFD700),
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFFF6B35),
                              width: 3,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                        maxLength: 20,
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 24),
                      
                      // Join Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isJoining ? null : _joinGame,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD700),
                            foregroundColor: const Color(0xFF1A1A2E),
                            disabledBackgroundColor: const Color(0xFF94A3B8),
                            disabledForegroundColor: const Color(0xFF1A1A2E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isJoining
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          const Color(0xFF1A1A2E),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'KATILIYOR...',
                                      style: GoogleFonts.orbitron(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1A1A2E),
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  'OYUNA KATIL',
                                  style: GoogleFonts.orbitron(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1A1A2E),
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
      ),
    );
  }
}
