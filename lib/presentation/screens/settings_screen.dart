import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_provider.dart';
import '../../services/settings_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late bool _musicEnabled;
  late bool _sfxEnabled;
  late double _timerDuration;

  @override
  void initState() {
    super.initState();
    final settingsService = ref.read(settingsServiceProvider);
    _musicEnabled = settingsService.getMusicEnabled();
    _sfxEnabled = settingsService.getSfxEnabled();
    _timerDuration = settingsService.getTimerDuration().toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final t = AppLocalizations(locale);
    final settingsService = ref.read(settingsServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('settings'), style: const TextStyle(letterSpacing: 2)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionHeader('AUDIO'),
          SwitchListTile(
            title: const Text('Background Music'),
            value: _musicEnabled,
            activeTrackColor: Theme.of(context).colorScheme.primary,
            onChanged: (value) {
              setState(() => _musicEnabled = value);
              settingsService.setMusicEnabled(value);
            },
          ),
          SwitchListTile(
            title: const Text('Sound Effects'),
            value: _sfxEnabled,
            activeTrackColor: Theme.of(context).colorScheme.primary,
            onChanged: (value) {
              setState(() => _sfxEnabled = value);
              settingsService.setSfxEnabled(value);
            },
          ),
          const SizedBox(height: 32),
          _buildSectionHeader('GAMEPLAY'),
          ListTile(
            title: const Text('Question Timer Duration'),
            subtitle: Text('${_timerDuration.toInt()} seconds'),
          ),
          Slider(
            value: _timerDuration,
            min: 15,
            max: 90,
            divisions: 5,
            activeColor: Theme.of(context).colorScheme.primary,
            label: '${_timerDuration.toInt()}s',
            onChanged: (value) {
              setState(() => _timerDuration = value);
            },
            onChangeEnd: (value) {
              settingsService.setTimerDuration(value.toInt());
            },
          ),
          const SizedBox(height: 32),
          _buildSectionHeader('LANGUAGE'),
          ListTile(
            title: const Text('Current Language'),
            trailing: DropdownButton<String>(
              value: locale.languageCode,
              dropdownColor: Theme.of(context).colorScheme.surface,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'tr', child: Text('Türkçe (TR)')),
                DropdownMenuItem(value: 'en', child: Text('English (EN)')),
              ],
              onChanged: (value) {
                if (value != null) {
                  ref.read(localeProvider.notifier).setLocale(Locale(value));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
  }
}
