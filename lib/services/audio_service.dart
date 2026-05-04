import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'settings_service.dart';

class AudioService {
  final SettingsService _settingsService;
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _tickPlayer = AudioPlayer();

  bool _isMusicPlaying = false;

  AudioService(this._settingsService);

  // Placeholder URLs for immediate testing. 
  // In a production app, these should be replaced with local AssetSource('sounds/ding.mp3')
  static const String _dingUrl = 'https://www.soundjay.com/buttons/sounds/button-09.mp3';
  static const String _buzzerUrl = 'https://www.soundjay.com/buttons/sounds/button-10.mp3';
  static const String _tickUrl = 'https://www.soundjay.com/clock/sounds/clock-ticking-2.mp3';
  static const String _bgmUrl = 'https://www.soundjay.com/free-music/sounds/deep-space-01.mp3';

  Future<void> playBackgroundMusic() async {
    if (!_settingsService.getMusicEnabled() || _isMusicPlaying) return;
    try {
      _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.play(UrlSource(_bgmUrl), volume: 0.3);
      _isMusicPlaying = true;
    } catch (e) {
      // print('AudioService Error: $e');
    }
  }

  Future<void> stopBackgroundMusic() async {
    await _musicPlayer.stop();
    _isMusicPlaying = false;
  }

  Future<void> playTick() async {
    if (!_settingsService.getSfxEnabled()) return;
    try {
      if (_tickPlayer.state != PlayerState.playing) {
        await _tickPlayer.play(UrlSource(_tickUrl), volume: 0.5);
      }
    } catch (e) {
      // print('AudioService Error: $e');
    }
  }

  Future<void> stopTick() async {
    await _tickPlayer.stop();
  }

  Future<void> playDing() async {
    if (!_settingsService.getSfxEnabled()) return;
    try {
      await _sfxPlayer.play(UrlSource(_dingUrl), volume: 1.0);
    } catch (e) {
      // print('AudioService Error: $e');
    }
  }

  Future<void> playBuzzer() async {
    if (!_settingsService.getSfxEnabled()) return;
    try {
      await _sfxPlayer.play(UrlSource(_buzzerUrl), volume: 1.0);
    } catch (e) {
      // print('AudioService Error: $e');
    }
  }
}

final audioServiceProvider = Provider<AudioService>((ref) {
  final settingsService = ref.watch(settingsServiceProvider);
  return AudioService(settingsService);
});
