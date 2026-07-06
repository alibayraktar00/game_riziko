import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/riziko_scaffold.dart';

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
    
    final textTheme = Theme.of(context).textTheme;

    return RizikoScaffold(
      title: 'TAKMA AD SEÇİN',
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => context.go('/player'),
      ),
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Game Code Display Card
              GlassCard(
                padding: const EdgeInsets.all(AppSpacing.md + 4),
                child: SizedBox(
                  width: 320,
                  child: Column(
                    children: [
                      Text(
                        'OYUN KODU',
                        style: textTheme.bodySmall?.copyWith(letterSpacing: 1.5),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        widget.gameCode,
                        style: textTheme.headlineMedium?.copyWith(
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

              const SizedBox(height: AppSpacing.lg),

              // Nickname Input Card
              GlassCard(
                radius: AppRadius.hero,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl + 8, horizontal: AppSpacing.lg),
                child: SizedBox(
                  width: 320,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
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
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Takma Adınızı Girin',
                        style: textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.md + 4),
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
                                        Flexible(
                                          child: Text(
                                            'KATILIYOR...',
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.outfit(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 1.2,
                                            ),
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
                ],
              ),
            ),
          ),
      );
  }
}
