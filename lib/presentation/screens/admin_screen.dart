import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../providers/multiplayer_provider.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  String? _gameCode;
  late DatabaseReference _gameRef;
  StreamSubscription<DatabaseEvent>? _playersSubscription;
  final List<Map<String, dynamic>> _players = [];
  bool _gameStarted = false;

  @override
  void initState() {
    super.initState();
    _setupGame();
  }

  Future<void> _setupGame() async {
    final multiplayerService = ref.read(multiplayerServiceProvider);
    
    // Create session using service
    final code = await multiplayerService.createMultiplayerSession(
      teams: [], // Empty initially
      availableQuestions: [],
    );

    if (mounted) {
      setState(() {
        _gameCode = code;
        _gameRef = FirebaseDatabase.instance.ref('games/$_gameCode');
      });
      _listenToPlayers();
    }
  }

  void _listenToPlayers() {
    _playersSubscription = _gameRef.child('players').onValue.listen((event) {
      if (event.snapshot.value != null) {
        final Map<dynamic, dynamic> playersData = event.snapshot.value as Map;
        if (mounted) {
          setState(() {
            _players.clear();
            playersData.forEach((key, value) {
              _players.add({
                'nickname': value['nickname'],
                'joinedAt': value['joinedAt'],
                'uid': key,
              });
            });
          });
        }
      }
    });
  }

  void _startGame() async {
    if (_players.isEmpty || _gameCode == null) return;

    await ref.read(multiplayerServiceProvider).startGame(_gameCode!);

    if (mounted) {
      setState(() {
        _gameStarted = true;
      });
      context.go('/game/$_gameCode');
    }
  }

  @override
  void dispose() {
    _playersSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    if (_gameCode == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'YÖNETİCİ PANELİ',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/mode-selection'),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: AppTheme.neonGradient,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Game Code Section (Glassmorphic)
                ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                      decoration: AppTheme.cardGradient,
                      child: Column(
                        children: [
                          Text(
                            'OYUN KODU',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.primary,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _gameCode ?? '',
                            style: GoogleFonts.outfit(
                              fontSize: 44,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 8,
                            ),
                          ),
                          const SizedBox(height: 28),
                          
                          // QR Code Container
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withValues(alpha: 0.25),
                                  blurRadius: 30,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: QrImageView(
                              data: 'riziko://game?code=${_gameCode ?? ''}',
                              version: QrVersions.auto,
                              size: 180.0,
                              backgroundColor: Colors.white,
                              dataModuleStyle: const QrDataModuleStyle(
                                color: Color(0xFF070913),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          Text(
                            'Oyuncular bu QR kodu tarayarak katılabilir',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Players Section (Glassmorphic)
                ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      decoration: AppTheme.cardGradient,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'KATILAN OYUNCULAR',
                                    style: GoogleFonts.outfit(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: colorScheme.primary,
                                      letterSpacing: 1.0,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: colorScheme.primary.withValues(alpha: 0.25),
                                    ),
                                  ),
                                  child: Text(
                                    '${_players.length}',
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
                          
                          // Players List
                          _players.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.person_off_rounded,
                                          size: 56,
                                          color: Colors.white.withValues(alpha: 0.2),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Henüz oyuncu katılmadı',
                                          style: GoogleFonts.outfit(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white.withValues(alpha: 0.35),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.all(16),
                                  itemCount: _players.length,
                                  itemBuilder: (context, index) {
                                    final player = _players[index];
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.02),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.06),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: colorScheme.primary,
                                            foregroundColor: colorScheme.onPrimary,
                                            child: Text(
                                              player['nickname'][0].toString().toUpperCase(),
                                              style: GoogleFonts.outfit(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  player['nickname'],
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Katıldı: ${_formatTime(player['joinedAt'])}',
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white.withValues(alpha: 0.4),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Start Game Button
                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: _players.isNotEmpty && !_gameStarted
                        ? const LinearGradient(
                            colors: [Color(0xFF00FF87), Color(0xFF60EFFF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.05),
                              Colors.white.withValues(alpha: 0.02),
                            ],
                          ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _players.isNotEmpty && !_gameStarted
                          ? Colors.white.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.06),
                      width: 1.2,
                    ),
                    boxShadow: _players.isNotEmpty && !_gameStarted
                        ? [
                            BoxShadow(
                              color: const Color(0xFF00FF87).withValues(alpha: 0.35),
                              blurRadius: 24,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _players.isNotEmpty && !_gameStarted ? _startGame : null,
                      borderRadius: BorderRadius.circular(20),
                      child: Center(
                        child: _gameStarted
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.play_arrow_rounded,
                                    color: Color(0xFF070913),
                                    size: 28,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        'OYUN BAŞLADI',
                                        style: GoogleFonts.outfit(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF070913),
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    _players.isEmpty ? 'EN AZ 1 OYUNCU GEREKLİ' : 'OYUNU BAŞLAT',
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: _players.isEmpty 
                                          ? Colors.white.withValues(alpha: 0.25)
                                          : const Color(0xFF070913),
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                              ),
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

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return 'Bilinmiyor';
    
    final time = DateTime.fromMillisecondsSinceEpoch(
      timestamp is int ? timestamp : (timestamp as Map)['_seconds'] * 1000,
    );
    
    return '${time.hour.toString().padLeft(2, '0')}:'
           '${time.minute.toString().padLeft(2, '0')}:'
           '${time.second.toString().padLeft(2, '0')}';
  }
}
