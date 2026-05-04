import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/locale_provider.dart';

/// Dil seçim butonu – AppBar actions veya Positioned içinde kullanılabilir.
class LanguagePickerButton extends ConsumerWidget {
  const LanguagePickerButton({super.key});

  void _showLanguagePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      // UncontrolledProviderScope ile ana widget ağacındaki Riverpod
      // container'ını bottom sheet'e aktarıyoruz.
      // Bu olmadan bottom sheet içindeki ref, üst ekranı rebuild etmiyor.
      builder: (_) => UncontrolledProviderScope(
        container: ProviderScope.containerOf(context),
        child: const _LanguageBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isTurkish = locale.languageCode == 'tr';

    return GestureDetector(
      onTap: () => _showLanguagePicker(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isTurkish ? '🇹🇷' : '🇬🇧',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 6),
            Text(
              isTurkish ? 'TR' : 'EN',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 1,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.expand_more_rounded,
              size: 16,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageBottomSheet extends ConsumerWidget {
  const _LanguageBottomSheet();

  static const _languages = [
    {'code': 'tr', 'flag': '🇹🇷', 'name': 'Türkçe', 'sub': 'Turkish'},
    {'code': 'en', 'flag': '🇬🇧', 'name': 'English', 'sub': 'İngilizce'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // build metodunun kendi ref'ini kullanıyoruz — constructor ref'i değil.
    final currentCode = ref.watch(localeProvider).languageCode;
    final primary = Theme.of(context).colorScheme.primary;
    final surface = Theme.of(context).colorScheme.surface;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: primary.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.15),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.language_rounded, color: primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Dil / Language',
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
          const SizedBox(height: 8),
          ..._languages.asMap().entries.map((entry) {
            final index = entry.key;
            final lang = entry.value;
            final isSelected = lang['code'] == currentCode;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  // build'in ref'ini kullanıyoruz — ana provider'ı günceller.
                  ref
                      .read(localeProvider.notifier)
                      .setLocale(Locale(lang['code']!));
                  Navigator.of(context).pop();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: isSelected
                        ? primary.withValues(alpha: 0.15)
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? primary.withValues(alpha: 0.5)
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(lang['flag']!, style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lang['name']!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? primary : Colors.white,
                            ),
                          ),
                          Text(
                            lang['sub']!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primary,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: Colors.black,
                          ),
                        ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: (index * 80).ms).slideY(begin: 0.1, end: 0),
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
