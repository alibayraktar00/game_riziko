import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_provider.dart';
import '../providers/game_provider.dart';
import '../widgets/language_picker_button.dart';
import '../../core/theme/app_theme.dart';

class TeamSetupScreen extends ConsumerStatefulWidget {
  const TeamSetupScreen({super.key});

  @override
  ConsumerState<TeamSetupScreen> createState() => _TeamSetupScreenState();
}

class _TeamSetupScreenState extends ConsumerState<TeamSetupScreen> {
  final _teamController = TextEditingController();

  void _addTeam() {
    final name = _teamController.text.trim();
    if (name.isNotEmpty) {
      ref.read(gameProvider.notifier).addTeam(name);
      _teamController.clear();
    }
  }

  void _startGame() async {
    final t = AppLocalizations(ref.read(localeProvider));
    final teams = ref.read(gameProvider).teams;
    if (teams.length >= 2) {
      if (mounted) {
        context.go('/category-picker');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.translate('min_teams_warning'))),
      );
    }
  }

  @override
  void dispose() {
    _teamController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final t = AppLocalizations(ref.watch(localeProvider));
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          t.translate('setup_teams'),
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/mode-selection'),
        ),
        actions: const [
          LanguagePickerButton(),
          SizedBox(width: 12),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: AppTheme.neonGradient,
        child: Stack(
          children: [
            // Soft decorative background glow circles (Mesh gradient effect)
            Positioned(
              top: -120,
              right: -120,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.secondary.withValues(alpha: 0.08),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
               .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 6.seconds)
               .blur(begin: const Offset(60, 60), end: const Offset(90, 90)),
            ),
            Positioned(
              bottom: -150,
              left: -100,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary.withValues(alpha: 0.08),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
               .scale(begin: const Offset(1, 1), end: const Offset(1.15, 1.15), duration: 7.seconds)
               .blur(begin: const Offset(70, 70), end: const Offset(100, 100)),
            ),
            
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  children: [
                    // Modern Input Row
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _teamController,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              hintText: t.translate('enter_team_name'),
                              hintStyle: GoogleFonts.outfit(
                                color: Colors.white.withValues(alpha: 0.3),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                              prefixIcon: Icon(Icons.group_add_rounded, color: colorScheme.primary.withValues(alpha: 0.7)),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.02),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  width: 1.2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  width: 1.2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                  color: colorScheme.primary.withValues(alpha: 0.7),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            ),
                            onSubmitted: (_) => _addTeam(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          height: 56,
                          width: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [colorScheme.secondary, colorScheme.secondary.withValues(alpha: 0.8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.secondary.withValues(alpha: 0.35),
                                blurRadius: 16,
                                spreadRadius: 0,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _addTeam,
                              borderRadius: BorderRadius.circular(20),
                              child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn().slideY(begin: -0.2, end: 0, duration: 400.ms),
                    
                    const SizedBox(height: 32),
                    
                    // Teams List
                    Expanded(
                      child: gameState.teams.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.group_off_rounded,
                                    size: 64,
                                    color: Colors.white.withValues(alpha: 0.15),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    t.translate('no_teams_added'),
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withValues(alpha: 0.3),
                                    ),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(duration: 400.ms)
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: gameState.teams.length,
                              itemBuilder: (context, index) {
                                final team = gameState.teams[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                                      child: Container(
                                        decoration: AppTheme.cardGradient,
                                        child: ListTile(
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                          leading: Container(
                                            height: 40,
                                            width: 40,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [colorScheme.primary, colorScheme.primary.withValues(alpha: 0.7)],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${index + 1}',
                                                style: GoogleFonts.outfit(
                                                  fontWeight: FontWeight.w900,
                                                  color: colorScheme.onPrimary,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            team.name,
                                            style: GoogleFonts.outfit(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                          trailing: IconButton(
                                            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF453A), size: 24),
                                            onPressed: () {
                                              ref.read(gameProvider.notifier).removeTeam(team.id);
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ).animate().fadeIn().slideX(begin: 0.1, end: 0, delay: (index * 80).ms, duration: 350.ms);
                              },
                            ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Modern Continue Button
                    _buildContinueButton(gameState.teams.length >= 2, t, colorScheme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton(bool isEnabled, AppLocalizations t, ColorScheme colorScheme) {
    return GestureDetector(
      onTap: isEnabled ? _startGame : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: isEnabled
              ? LinearGradient(
                  colors: [colorScheme.primary, colorScheme.primary.withValues(alpha: 0.85)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.05),
                    Colors.white.withValues(alpha: 0.02),
                  ],
                ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isEnabled
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.06),
            width: 1.2,
          ),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.35),
                    blurRadius: 24,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            t.translate('continue_btn').toUpperCase(),
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isEnabled ? colorScheme.onPrimary : Colors.white.withValues(alpha: 0.25),
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms);
  }
}
