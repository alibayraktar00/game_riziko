import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../providers/game_provider.dart';
import '../providers/providers.dart';
import '../widgets/riziko_scaffold.dart';
import '../widgets/selectable_card.dart';
import '../../core/category_icons.dart';

class CategoryPickerScreen extends ConsumerStatefulWidget {
  const CategoryPickerScreen({super.key});

  @override
  ConsumerState<CategoryPickerScreen> createState() => _CategoryPickerScreenState();
}

class _CategoryPickerScreenState extends ConsumerState<CategoryPickerScreen> {
  final Set<String> _selectedCategories = {};
  static const int _requiredCount = 5;

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(questionsProvider);
    final locale = ref.watch(localeProvider);
    final t = AppLocalizations(locale);
    final textTheme = Theme.of(context).textTheme;
    final isComplete = _selectedCategories.length == _requiredCount;

    return RizikoScaffold(
      title: 'KATEGORİ SEÇİMİ',
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => context.go('/team-setup'),
      ),
      body: questionsAsync.when(
        data: (questions) {
          // Aynı kategorinin farklı yazımları (büyük/küçük harf, boşluk)
          // listede iki kez görünmesin — ilk görülen yazım gösterilir,
          // eşleştirme oyun başlatılırken zaten normalize yapılıyor.
          final seen = <String>{};
          final allCategories = <String>[];
          for (final q in questions) {
            if (seen.add(q.category.trim().toLowerCase())) {
              allCategories.add(q.category.trim());
            }
          }
          allCategories.sort();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
                child: Column(
                  children: [
                    Text(
                      '$_requiredCount KATEGORİ SEÇİN',
                      style: textTheme.headlineMedium?.copyWith(letterSpacing: 2),
                    ).animate().fadeIn().slideY(begin: -0.2, end: 0),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Seçilen: ${_selectedCategories.length} / $_requiredCount',
                      style: textTheme.bodyMedium?.copyWith(
                        color: isComplete ? Colors.greenAccent : null,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  itemCount: allCategories.length,
                  itemBuilder: (context, index) {
                    final category = allCategories[index];
                    final isSelected = _selectedCategories.contains(category);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: SelectableCard(
                        icon: categoryIcon(category),
                        title: t.translate(category.toLowerCase()).toUpperCase(),
                        selected: isSelected,
                        showHud: false,
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedCategories.remove(category);
                            } else if (_selectedCategories.length < _requiredCount) {
                              _selectedCategories.add(category);
                            }
                          });
                        },
                      ),
                    ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1, end: 0);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isComplete
                        ? () {
                            ref.read(gameProvider.notifier).startGameWithCategories(
                                  questions,
                                  _selectedCategories.toList(),
                                );
                            context.go('/category-selection');
                          }
                        : null,
                    child: const Text('OYUNU BAŞLAT'),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Hata: $error', style: textTheme.bodyMedium)),
      ),
    );
  }
}
