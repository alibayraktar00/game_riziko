import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/game_session.dart';
import '../providers/multiplayer_provider.dart';

class MultiplayerLobbyScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const MultiplayerLobbyScreen({
    super.key,
    required this.sessionId,
  });

  @override
  ConsumerState<MultiplayerLobbyScreen> createState() => _MultiplayerLobbyScreenState();
}

class _MultiplayerLobbyScreenState extends ConsumerState<MultiplayerLobbyScreen> {
  GameSession? _currentSession;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  void _loadSession() {
    final multiplayerService = ref.read(multiplayerServiceProvider);
    
    multiplayerService.watchSession(widget.sessionId).listen(
      (session) {
        setState(() {
          _currentSession = session;
          _isLoading = false;
          _error = null;
        });
      },
      onError: (error) {
        setState(() {
          _isLoading = false;
          _error = error.toString();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null || _currentSession == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Oyun Odası'),
          backgroundColor: Colors.red[800],
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[600],
              ),
              const SizedBox(height: 16),
              Text(
                _error ?? 'Oyun bulunamadı',
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Ana Sayfaya Dön'),
              ),
            ],
          ),
        ),
      );
    }

    final session = _currentSession!;
    final multiplayerService = ref.read(multiplayerServiceProvider);
    final isHost = multiplayerService.isHost(session);
    final playerCount = multiplayerService.getConnectedPlayerCount(session);

    return Scaffold(
      appBar: AppBar(
        title: Text('Oyun Odası - ${widget.sessionId}'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          if (isHost)
            IconButton(
              onPressed: _showSettings,
              icon: const Icon(Icons.settings),
              tooltip: 'Ayarlar',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Oyun Durumu Kartı
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Oyun Durumu',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(session.status),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getStatusText(session.status),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.people, color: Colors.blue[600]),
                        const SizedBox(width: 8),
                        Text(
                          'Bağlı Oyuncular: $playerCount',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    if (isHost) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.admin_panel_settings, color: Colors.green[600]),
                          const SizedBox(width: 8),
                          const Text(
                            'Siz Oyun Sahibisiniz',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Takımlar
            Expanded(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Takımlar',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          itemCount: session.teams.length,
                          itemBuilder: (context, index) {
                            final team = session.teams[index];
                            final isCurrentTeam = index == session.currentTeamIndex;
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              color: isCurrentTeam ? Colors.blue[50] : null,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isCurrentTeam 
                                      ? Colors.blue[600] 
                                      : Colors.grey[400],
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  team.name,
                                  style: TextStyle(
                                    fontWeight: isCurrentTeam 
                                        ? FontWeight.bold 
                                        : FontWeight.normal,
                                  ),
                                ),
                                subtitle: Text('Puan: ${team.score}'),
                                trailing: isCurrentTeam
                                    ? const Icon(Icons.play_arrow, color: Colors.blue)
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Butonlar
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/multiplayer/qr/${widget.sessionId}'),
                    icon: const Icon(Icons.qr_code),
                    label: const Text('QR Kodu Göster'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                if (isHost)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: session.status == GameStatus.waiting
                          ? _startGame
                          : null,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Oyunu Başlat'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _leaveGame,
                      icon: const Icon(Icons.exit_to_app),
                      label: const Text('Oyundan Ayrıl'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(GameStatus status) {
    switch (status) {
      case GameStatus.waiting:
        return Colors.orange;
      case GameStatus.inProgress:
        return Colors.green;
      case GameStatus.paused:
        return Colors.blue;
      case GameStatus.finished:
        return Colors.grey;
    }
  }

  String _getStatusText(GameStatus status) {
    switch (status) {
      case GameStatus.waiting:
        return 'Bekleniyor';
      case GameStatus.inProgress:
        return 'Oyunda';
      case GameStatus.paused:
        return 'Duraklatıldı';
      case GameStatus.finished:
        return 'Bitti';
    }
  }

  void _startGame() async {
    try {
      final multiplayerService = ref.read(multiplayerServiceProvider);
      await multiplayerService.startGame(widget.sessionId);
      
      if (mounted) {
        context.go('/game/${widget.sessionId}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Oyun başlatılamadı: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _leaveGame() async {
    try {
      final multiplayerService = ref.read(multiplayerServiceProvider);
      await multiplayerService.leaveSession(widget.sessionId);
      
      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Oyundan ayrılırken hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Oyun Ayarları'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Oyun ID'),
              subtitle: Text(widget.sessionId),
              trailing: IconButton(
                onPressed: () {
                  // Copy to clipboard
                },
                icon: const Icon(Icons.copy),
              ),
            ),
            ListTile(
              title: const Text('Oyuncu Sayısı'),
              subtitle: Text('${_currentSession?.connectedDeviceIds.length ?? 0}'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }
}
