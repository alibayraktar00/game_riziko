import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  late String _gameCode;
  late DatabaseReference _gameRef;
  late StreamSubscription<DatabaseEvent> _playersSubscription;
  final List<Map<String, dynamic>> _players = [];
  bool _gameStarted = false;

  @override
  void initState() {
    super.initState();
    _gameCode = _generateGameCode();
    _gameRef = FirebaseDatabase.instance.ref('games/$_gameCode');
    _initializeGame();
    _listenToPlayers();
  }

  Future<void> _initializeGame() async {
    await _gameRef.set({
      'status': 'waiting',
      'playerCount': 0,
      'createdAt': ServerValue.timestamp,
      'code': _gameCode,
    });
  }

  String _generateGameCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    String code = '';
    
    for (int i = 0; i < 4; i++) {
      code += chars[(random + i) % chars.length];
    }
    
    return code;
  }

  void _listenToPlayers() {
    _playersSubscription = _gameRef.child('players').onValue.listen((event) {
      if (event.snapshot.value != null) {
        final Map<dynamic, dynamic> playersData = event.snapshot.value as Map;
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
    });
  }

  void _startGame() {
    if (_players.isEmpty) return;

    _gameRef.update({
      'status': 'started',
      'startedAt': ServerValue.timestamp,
    });

    setState(() {
      _gameStarted = true;
    });

    // Navigate to game screen
    context.go('/game/$_gameCode');
  }

  @override
  void dispose() {
    _playersSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'YÖNETİCİ PANELİ',
          style: GoogleFonts.orbitron(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/mode-selection'),
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: const Color(0xFFFFD700),
        elevation: 0,
      ),
      body: Container(
        decoration: AppTheme.neonGradient,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Game Code Section
              Container(
                padding: const EdgeInsets.all(32),
                decoration: AppTheme.cardGradient,
                child: Column(
                  children: [
                    Text(
                      'OYUN KODU',
                      style: GoogleFonts.orbitron(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFFD700),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _gameCode,
                      style: GoogleFonts.orbitron(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFFFD700),
                        letterSpacing: 8,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // QR Code
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: 'riziko://game?code=$_gameCode',
                        version: QrVersions.auto,
                        size: 200.0,
                        backgroundColor: Colors.white,
                        dataModuleStyle: const QrDataModuleStyle(
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    Text(
                      'Oyuncular bu QR kodu tarayarak katılabilir',
                      style: GoogleFonts.orbitron(
                        fontSize: 14,
                        color: const Color(0xFFF1F5F9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Players Section
              Container(
                decoration: AppTheme.cardGradient,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'KATILAN OYUNCULAR',
                              style: GoogleFonts.orbitron(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFFFD700),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_players.length}',
                              style: GoogleFonts.orbitron(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFFFD700),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const Divider(color: Color(0xFF334155), height: 1),
                    
                    // Players List
                    _players.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(40),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.person_off,
                                    size: 64,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Henüz oyuncu katılmadı',
                                    style: GoogleFonts.orbitron(
                                      fontSize: 16,
                                      color: const Color(0xFF94A3B8),
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
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A1A2E).withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: const Color(0xFFFFD700),
                                      child: Text(
                                        player['nickname'][0].toString().toUpperCase(),
                                        style: GoogleFonts.orbitron(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF1A1A2E),
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
                                            style: GoogleFonts.orbitron(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFFF1F5F9),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Katıldı: ${_formatTime(player['joinedAt'])}',
                                            style: GoogleFonts.orbitron(
                                              fontSize: 12,
                                              color: const Color(0xFF94A3B8),
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
              
              const SizedBox(height: 24),
              
              // Start Game Button
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  gradient: _players.isNotEmpty && !_gameStarted
                      ? const LinearGradient(
                          colors: [Color(0xFF00FF88), Color(0xFF00D084)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: [
                            Colors.grey.withValues(alpha: 0.3),
                            Colors.grey.withValues(alpha: 0.1),
                          ],
                        ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _players.isNotEmpty && !_gameStarted
                      ? [
                          AppTheme.neonShadow,
                          BoxShadow(
                            color: const Color(0xFF00FF88).withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 0,
                          ),
                        ]
                      : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _players.isNotEmpty && !_gameStarted ? _startGame : null,
                    borderRadius: BorderRadius.circular(16),
                    child: Center(
                      child: _gameStarted
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.play_arrow,
                                  color: Color(0xFF1A1A2E),
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'OYUN BAŞLADI',
                                      style: GoogleFonts.orbitron(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1A1A2E),
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
                                  style: GoogleFonts.orbitron(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _players.isEmpty 
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF1A1A2E),
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
