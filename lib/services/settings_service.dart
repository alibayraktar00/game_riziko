import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _localeKey = 'settings_locale';
  static const String _musicEnabledKey = 'settings_music_enabled';
  static const String _sfxEnabledKey = 'settings_sfx_enabled';
  static const String _timerDurationKey = 'settings_timer_duration';
  static const String _themeKey = 'settings_theme_mode';

  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  // --- Theme ---
  String getThemeMode() {
    return _prefs.getString(_themeKey) ?? 'neon';
  }

  Future<void> setThemeMode(String theme) async {
    await _prefs.setString(_themeKey, theme);
  }

  // --- Locale ---
  String getLocaleCode() {
    return _prefs.getString(_localeKey) ?? 'tr';
  }

  Future<void> setLocaleCode(String code) async {
    await _prefs.setString(_localeKey, code);
  }

  // --- Audio ---
  bool getMusicEnabled() {
    return _prefs.getBool(_musicEnabledKey) ?? true;
  }

  Future<void> setMusicEnabled(bool enabled) async {
    await _prefs.setBool(_musicEnabledKey, enabled);
  }

  bool getSfxEnabled() {
    return _prefs.getBool(_sfxEnabledKey) ?? true;
  }

  Future<void> setSfxEnabled(bool enabled) async {
    await _prefs.setBool(_sfxEnabledKey, enabled);
  }

  // --- Game Settings ---
  int getTimerDuration() {
    return _prefs.getInt(_timerDurationKey) ?? 30;
  }

  Future<void> setTimerDuration(int seconds) async {
    await _prefs.setInt(_timerDurationKey, seconds);
  }
}

// Provider for SharedPreferences instance. Must be overridden in main.dart
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

final settingsServiceProvider = Provider<SettingsService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsService(prefs);
});
