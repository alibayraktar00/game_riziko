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

  static const String _dingAsset = 'sounds/ding.mp3';
  static const String _buzzerAsset = 'sounds/buzzer.mp3';
  static const String _tickAsset = 'sounds/tick.mp3';
  static const String _bgmAsset = 'sounds/background_music.mp3';

  Future<void> playBackgroundMusic() async {
    if (!_settingsService.getMusicEnabled() || _isMusicPlaying) return;
    try {
      _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.play(AssetSource(_bgmAsset), volume: 0.3);
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
        await _tickPlayer.play(AssetSource(_tickAsset), volume: 0.5);
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
      await _sfxPlayer.play(AssetSource(_dingAsset), volume: 1.0);
    } catch (e) {
      // print('AudioService Error: $e');
    }
  }

  Future<void> playBuzzer() async {
    if (!_settingsService.getSfxEnabled()) return;
    try {
      await _sfxPlayer.play(AssetSource(_buzzerAsset), volume: 1.0);
    } catch (e) {
      // print('AudioService Error: $e');
    }
  }
}

final audioServiceProvider = Provider<AudioService>((ref) {
  final settingsService = ref.watch(settingsServiceProvider);
  return AudioService(settingsService);
});
