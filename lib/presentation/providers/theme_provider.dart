import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../services/settings_service.dart';

class ThemeNotifier extends Notifier<RizikoTheme> {
  @override
  RizikoTheme build() {
    final settingsService = ref.watch(settingsServiceProvider);
    final themeStr = settingsService.getThemeMode();
    return RizikoTheme.values.firstWhere(
      (t) => t.name == themeStr,
      orElse: () => RizikoTheme.neon,
    );
  }

  Future<void> setTheme(RizikoTheme theme) async {
    state = theme;
    final settingsService = ref.read(settingsServiceProvider);
    await settingsService.setThemeMode(theme.name);
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, RizikoTheme>(() {
  return ThemeNotifier();
});
