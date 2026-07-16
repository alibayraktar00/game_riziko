import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_provider.dart';
import '../providers/game_provider.dart';
import '../providers/providers.dart';
import '../widgets/language_picker_button.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/team.dart';
import '../../domain/entities/question.dart';
import '../widgets/glass_card.dart';
import '../widgets/riziko_scaffold.dart';
import '../../core/category_icons.dart';

class CategorySelectionScreen extends ConsumerWidget {
  const CategorySelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsAsync = ref.watch(questionsProvider);
    final gameSession = ref.watch(gameProvider);
    final availableQuestions = gameSession.availableQuestions;
    final locale = ref.watch(localeProvider);
    final t = AppLocalizations(locale);
    final colorScheme = Theme.of(context).colorScheme;

    return RizikoScaffold(
      title: t.translate('categories').toUpperCase(),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => context.go('/team-setup'),
      ),
      actions: [
        const LanguagePickerButton(),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.leaderboard_rounded),
          color: colorScheme.primary,
          onPressed: () => context.push('/scoreboard'),
        ).animate(onPlay: (c) => c.repeat(reverse: true))
         .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.1, 1.1), duration: 1.seconds),
        const SizedBox(width: AppSpacing.sm),
      ],
      body: questionsAsync.when(
          data: (originalQuestions) {
            // Get selected categories from gameSession, or fallback to categories from remaining questions.
            // Fallback tarafında da aynı kategorinin farklı yazımları (özel sorularda
            // kullanıcı serbest metin girebiliyor) tek kategori olarak sayılmalı.
            final activeCategories = gameSession.selectedCategories.isNotEmpty
                ? gameSession.selectedCategories
                : () {
                    final seen = <String>{};
                    final result = <String>[];
                    for (final q in availableQuestions) {
                      if (seen.add(q.category.trim().toLowerCase())) {
                        result.add(q.category.trim());
                      }
                    }
                    return result;
                  }();

            // Find all possible categories in the original questions —
            // aynı kategorinin farklı yazımları (büyük/küçük harf, boşluk)
            // tek kategori sayılır.
            final seenCategories = <String>{};
            final allOriginalCategories = <String>[];
            for (final q in originalQuestions) {
              if (seenCategories.add(q.category.trim().toLowerCase())) {
                allOriginalCategories.add(q.category.trim());
              }
            }
            allOriginalCategories.sort();

            // Upcoming categories are those in original questions but not selected for this game
            final activeNormalized =
                activeCategories.map((c) => c.trim().toLowerCase()).toSet();
            final upcomingCategories = allOriginalCategories
                .where((c) => !activeNormalized.contains(c.trim().toLowerCase()))
                .toList();

            if (activeCategories.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.amber.withValues(alpha: 0.08),
                        boxShadow: [
                          BoxShadow(color: Colors.amber.withValues(alpha: 0.25), blurRadius: 30, spreadRadius: 2),
                        ],
                      ),
                      child: const Icon(Icons.emoji_events_rounded, size: 64, color: Colors.amber),
                    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.6, 0.6), end: const Offset(1.0, 1.0), curve: Curves.elasticOut),
                    const SizedBox(height: 24),
                    Text(
                      t.translate('game_over'),
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ).animate().fadeIn(delay: 200.ms).scale(),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.push('/scoreboard'),
                      child: Text(t.translate('view_final_scores')),
                    ).animate().fadeIn(delay: 500.ms),
                  ],
                ),
              );
            }

            final currentTeam = gameSession.currentTeam;
            final sortedTeams = List<Team>.from(gameSession.teams)
              ..sort((a, b) => b.score.compareTo(a.score));

            final totalQuestionsCount = activeCategories.length * 5;
            final completedQuestionsCount = totalQuestionsCount - availableQuestions.length;

            return SafeArea(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                children: [
                  // 1. Leaderboard & Profile Progress Card
                  _buildLeaderboardHeader(context, currentTeam, sortedTeams, completedQuestionsCount, totalQuestionsCount),
                  
                  const SizedBox(height: 24),

                  // 2. Active Categories List
                  ...activeCategories.asMap().entries.map((entry) {
                    final index = entry.key;
                    final category = entry.value;
                    
                    // Filter questions still available in this category
                    final catAvailableQuestions = availableQuestions.where((q) => q.category.trim().toLowerCase() == category.trim().toLowerCase()).toList();
                    
                    return _CategoryRow(
                      category: category,
                      availableQuestions: catAvailableQuestions,
                      index: index,
                      t: t,
                    );
                  }),

                  const SizedBox(height: 24),

                  // 3. "SONRAKİ KATEGORİLER" (Upcoming Categories) Section
                  if (upcomingCategories.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
                      child: Text(
                        'SONRAKİ KATEGORİLER',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withValues(alpha: 0.8),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    _buildUpcomingCategoriesGrid(upcomingCategories, t),
                    const SizedBox(height: 32),
                  ],
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),
    );
  }

  Widget _buildLeaderboardHeader(BuildContext context, Team currentTeam, List<Team> sortedTeams, int completedCount, int totalCount) {
    final colorScheme = Theme.of(context).colorScheme;
    final progressPercentage = totalCount > 0 ? (completedCount / totalCount).clamp(0.0, 1.0) : 0.0;
    final avatarEmoji = _getEmojiForTeam(currentTeam.name);

    return GlassCard(
      radius: AppRadius.hero,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
            children: [
              // Leaderboard Avatar
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [colorScheme.primary.withValues(alpha: 0.3), colorScheme.primary.withValues(alpha: 0.1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: colorScheme.primary.withValues(alpha: 0.4), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.15),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    avatarEmoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Progress Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LİDERLİK PANOSU',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.5),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currentTeam.name.toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: colorScheme.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Progress Bar — scales to actual available width instead
                    // of a hardcoded pixel value.
                    LayoutBuilder(
                      builder: (context, constraints) => ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Stack(
                          children: [
                            Container(
                              height: 6,
                              width: constraints.maxWidth,
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              height: 6,
                              width: constraints.maxWidth * progressPercentage,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [colorScheme.primary, colorScheme.secondary],
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$completedCount / $totalCount Seviye',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              
              // "En İyiler" (Top Players) list
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'EN İYİLER',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white.withValues(alpha: 0.5),
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: sortedTeams.take(3).map((team) {
                      final emoji = _getEmojiForTeam(team.name);
                      return Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.05),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1.2),
                          ),
                          child: Center(
                            child: Text(emoji, style: const TextStyle(fontSize: 13)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ],
          ),
    );
  }

  Widget _buildUpcomingCategoriesGrid(List<String> upcomingCategories, AppLocalizations t) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemCount: upcomingCategories.length,
      itemBuilder: (context, index) {
        final category = upcomingCategories[index];
        final catIcon = categoryIcon(category);

        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06), width: 1.2),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -10,
                  bottom: -10,
                  child: Opacity(
                    opacity: 0.1,
                    child: Icon(catIcon, size: 56, color: Colors.white),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      child: Text(
                        'KİLİTLİ',
                        style: GoogleFonts.outfit(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withValues(alpha: 0.4),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Text(
                      t.translate(category.toLowerCase()).toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white.withValues(alpha: 0.6),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getEmojiForTeam(String name) {
    final lower = name.toLowerCase();
    if (lower == 'ali') {
      return '🦁'; // Lion emoji for Ali, matching mockup!
    }
    final code = name.hashCode.abs();
    final emojis = ['🦊', '🐯', '🐻', '🐼', '🦁', '🐨', '🐙', '🐸', '🦄'];
    return emojis[code % emojis.length];
  }
}

class _CategoryRow extends StatelessWidget {
  final String category;
  final List<Question> availableQuestions;
  final int index;
  final AppLocalizations t;

  const _CategoryRow({
    required this.category,
    required this.availableQuestions,
    required this.index,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    final catIcon = categoryIcon(category);
    final categoryColor = _getCategoryMainColor(category);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            categoryColor.withValues(alpha: 0.15),
            categoryColor.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: categoryColor.withValues(alpha: 0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: categoryColor.withValues(alpha: 0.04),
            blurRadius: 15,
            spreadRadius: -2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
              // Left background watermark icon
              Positioned(
                left: 10,
                bottom: -10,
                child: Opacity(
                  opacity: 0.04,
                  child: Icon(
                    _getCategoryLeftWatermark(category),
                    size: 110,
                    color: categoryColor,
                  ),
                ),
              ),
              // Right background watermark icon
              Positioned(
                right: -10,
                bottom: -20,
                child: Opacity(
                  opacity: 0.06,
                  child: Icon(
                    _getCategoryRightWatermark(category),
                    size: 140,
                    color: categoryColor,
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Header Line
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.translate(category.toLowerCase()).toUpperCase(),
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                                color: Colors.white,
                                shadows: [
                                  Shadow(color: categoryColor.withValues(alpha: 0.4), blurRadius: 10),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 3,
                              width: 32,
                              decoration: BoxDecoration(
                                color: categoryColor,
                                borderRadius: BorderRadius.circular(1.5),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: categoryColor.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: categoryColor.withValues(alpha: 0.25),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            catIcon,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Seviye Indicators + Subtexts
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(5, (idx) {
                        final level = idx + 1;
                        
                        // Check if it's currently available (unanswered)
                        final isPlayable = availableQuestions.any((q) => q.difficulty == level);
                        
                        // Completed = not available anymore
                        final isCompleted = !isPlayable;
                        final isSpecial = (category.toLowerCase().contains('entertainment') || category.toLowerCase().contains('eğlence')) && level == 3;

                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              children: [
                                _DifficultyIndicator(
                                  level: level,
                                  isPlayable: isPlayable,
                                  isCompleted: isCompleted,
                                  category: category,
                                  color: categoryColor,
                                  isSpecial: isSpecial,
                                ),
                                const SizedBox(height: 8),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    _getLevelSubtext(category, level, isCompleted),
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.outfit(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: isCompleted
                                          ? const Color(0xFF00FF87)
                                          : Colors.white.withValues(alpha: 0.4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                    
                    // Bottom Badge
                    const SizedBox(height: 16),
                    _buildBottomBadge(category, categoryColor),
                  ],
                ),
              ),
            ],
          ),
        ),
    ).animate().fadeIn(delay: (index * 80).ms).slideY(begin: 0.05, end: 0, duration: 400.ms);
  }

  Widget _buildBottomBadge(String category, Color categoryColor) {
    final lower = category.toLowerCase();
    String text = 'LİDERLİK TURNUVASI';
    IconData icon = Icons.emoji_events_rounded;
    Color iconColor = const Color(0xFFFFD700); // Gold
    
    if (lower.contains('history') || lower.contains('tarih')) {
      text = 'Yeni Başarı Kazandın!';
      icon = Icons.star_rounded;
    } else if (lower.contains('geography') || lower.contains('coğrafya')) {
      text = 'Yeni Coğrafya Turnuvası - Katıl!';
      icon = Icons.explore_rounded;
      iconColor = const Color(0xFF00FF87);
    } else if (lower.contains('entertainment') || lower.contains('eğlence')) {
      text = 'Kategori Temaları';
      icon = Icons.local_movies_rounded;
    } else if (lower.contains('art') || lower.contains('sanat')) {
      text = 'Sanat Uzmanı Rozeti';
      icon = Icons.palette_rounded;
    } else if (lower.contains('general culture') || lower.contains('genel kültür')) {
      text = 'Genel Kültür Uzmanı';
      icon = Icons.lightbulb_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: categoryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: categoryColor.withValues(alpha: 0.2),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: iconColor,
          ),
          const SizedBox(width: 6),
          Text(
            text.toUpperCase(),
            style: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Colors.white.withValues(alpha: 0.9),
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  static IconData _getCategoryLeftWatermark(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('history') || lower.contains('tarih')) {
      return Icons.map_outlined;
    } else if (lower.contains('geography') || lower.contains('coğrafya')) {
      return Icons.explore_outlined;
    } else if (lower.contains('entertainment') || lower.contains('eğlence')) {
      return Icons.music_note_outlined;
    } else if (lower.contains('art') || lower.contains('sanat')) {
      return Icons.brush_outlined;
    } else if (lower.contains('general culture') || lower.contains('genel kültür')) {
      return Icons.menu_book_outlined;
    }
    return Icons.bubble_chart_outlined;
  }

  static IconData _getCategoryRightWatermark(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('history') || lower.contains('tarih')) {
      return Icons.castle_outlined;
    } else if (lower.contains('geography') || lower.contains('coğrafya')) {
      return Icons.public_outlined;
    } else if (lower.contains('entertainment') || lower.contains('eğlence')) {
      return Icons.movie_creation_outlined;
    } else if (lower.contains('art') || lower.contains('sanat')) {
      return Icons.palette_outlined;
    } else if (lower.contains('general culture') || lower.contains('genel kültür')) {
      return Icons.lightbulb_outlined;
    }
    return Icons.category_outlined;
  }


  String _getLevelSubtext(String category, int level, bool isCompleted) {
    if (isCompleted) {
      return 'Tamamlandı';
    }
    
    final lower = category.toLowerCase();
    if (lower.contains('general culture') || lower.contains('genel kültür')) {
      switch (level) {
        case 1: return '1 - Temel';
        case 2: return '2 - Bilgi';
        case 3: return '3 - Bilge';
        case 4: return '4 - Bilge';
        case 5: return '5 - Koyu';
      }
    } else if (lower.contains('art') || lower.contains('sanat')) {
      switch (level) {
        case 1: return '1 - Acemi';
        case 2: return '2 - Bilgi';
        case 3: return '3 - Bilge';
        case 4: return '4 - Bilge';
        case 5: return '5 - Usta';
      }
    }
    
    // Default subtext
    switch (level) {
      case 1: return '1 - Seviye';
      case 2: return '2 - Soru';
      case 3: return '3 - Bilge';
      case 4: return '4 - Bilge';
      case 5: return '5 - Koyu';
    }
    return '$level. Seviye';
  }

  Color _getCategoryMainColor(String category) {
    final lowerCategory = category.toLowerCase();
    if (lowerCategory.contains('science') || lowerCategory.contains('bilim')) {
      return const Color(0xFF00E5FF); // Cyan
    } else if (lowerCategory.contains('history') || lowerCategory.contains('tarih')) {
      return const Color(0xFFFFB300); // Amber/Gold
    } else if (lowerCategory.contains('geography') || lowerCategory.contains('coğrafya')) {
      return const Color(0xFF00C853); // Emerald Green
    } else if (lowerCategory.contains('sports') || lowerCategory.contains('spor')) {
      return const Color(0xFFFF6D00); // Deep Orange
    } else if (lowerCategory.contains('entertainment') || lowerCategory.contains('eğlence')) {
      return const Color(0xFFD500F9); // Purple
    } else if (lowerCategory.contains('art') || lowerCategory.contains('sanat')) {
      return const Color(0xFFFF1744); // Red/Pink
    } else if (lowerCategory.contains('technology') || lowerCategory.contains('teknoloji')) {
      return const Color(0xFF2979FF); // Royal Blue
    } else if (lowerCategory.contains('general culture') || lowerCategory.contains('genel kültür')) {
      return const Color(0xFFAA00FF); // Deep Purple
    }
    return const Color(0xFF00E5FF);
  }
}

class _DifficultyIndicator extends StatelessWidget {
  final int level;
  final bool isPlayable;
  final bool isCompleted;
  final String category;
  final Color color;
  final bool isSpecial;

  const _DifficultyIndicator({
    required this.level,
    required this.isPlayable,
    required this.isCompleted,
    required this.category,
    required this.color,
    this.isSpecial = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isPlayable
              ? () => context.push('/question', extra: {'category': category, 'difficulty': level})
              : null,
            borderRadius: BorderRadius.circular(18),
            child: AnimatedContainer(
              duration: 300.ms,
              height: 60,
              decoration: BoxDecoration(
                gradient: isCompleted
                    ? LinearGradient(
                        colors: [const Color(0xFF00E5FF).withValues(alpha: 0.8), const Color(0xFF00B0FF).withValues(alpha: 0.6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [Colors.white.withValues(alpha: 0.08), Colors.white.withValues(alpha: 0.02)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isCompleted 
                      ? const Color(0xFF00E5FF).withValues(alpha: 0.8) 
                      : Colors.white.withValues(alpha: 0.12),
                  width: 1.5,
                ),
                boxShadow: isCompleted
                    ? [
                        BoxShadow(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
                          blurRadius: 8,
                          spreadRadius: 1,
                        )
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  '$level',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
        
        // Green checkmark badge at top-right for completed questions
        if (isCompleted)
          Positioned(
            top: -6,
            right: -6,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Color(0xFF00FF87),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Color(0xFF070913),
                size: 12,
                weight: 3.0,
              ),
            ),
          ),
          
        // Gold medal badge at top-right for special level (Eğlence Level 3)
        if (!isCompleted && isSpecial)
          Positioned(
            top: -8,
            right: -8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Color(0xFFFFD700),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.star_rounded,
                color: Color(0xFF070913),
                size: 14,
              ),
            ),
          ),
      ],
    );
  }
}
