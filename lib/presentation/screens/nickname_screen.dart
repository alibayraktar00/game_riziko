import 'dart:async';
import 'dart:ui';
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
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFFF3B30),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'TAKMA AD SEÇİN',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/player'),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: AppTheme.neonGradient,
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Game Code Display Card (Glassmorphic)
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      width: 320,
                      padding: const EdgeInsets.all(20),
                      decoration: AppTheme.cardGradient,
                      child: Column(
                        children: [
                          Text(
                            'OYUN KODU',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.5),
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.gameCode,
                            style: GoogleFonts.outfit(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: colorScheme.primary,
                              letterSpacing: 4,
                              shadows: [
                                Shadow(
                                  color: colorScheme.primary.withValues(alpha: 0.4),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Nickname Input Card (Glassmorphic)
                ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      width: 320,
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                      decoration: AppTheme.cardGradient,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colorScheme.primary.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Icon(
                              Icons.person_rounded,
                              size: 48,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Takma Adınızı Girin',
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _nicknameController,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Takma adınız',
                              hintStyle: GoogleFonts.outfit(
                                color: Colors.white.withValues(alpha: 0.3),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.02),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  width: 1.2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  width: 1.2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: colorScheme.primary.withValues(alpha: 0.7),
                                  width: 2,
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
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                disabledBackgroundColor: Colors.white.withValues(alpha: 0.1),
                                disabledForegroundColor: Colors.white.withValues(alpha: 0.3),
                                elevation: _isJoining ? 0 : 8,
                                shadowColor: colorScheme.primary.withValues(alpha: 0.4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isJoining
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              colorScheme.onPrimary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'KATILIYOR...',
                                          style: GoogleFonts.outfit(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Text(
                                      'OYUNA KATIL',
                                      style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
