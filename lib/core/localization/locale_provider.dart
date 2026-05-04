import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/settings_service.dart';

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final settingsService = ref.watch(settingsServiceProvider);
    return Locale(settingsService.getLocaleCode());
  }

  void setLocale(Locale locale) {
    state = locale;
    ref.read(settingsServiceProvider).setLocaleCode(locale.languageCode);
  }

  void toggleLocale() {
    final newLocale = state.languageCode == 'tr' ? const Locale('en') : const Locale('tr');
    setLocale(newLocale);
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(() {
  return LocaleNotifier();
});
