import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_provider.dart';
import '../providers/game_provider.dart';
import '../widgets/language_picker_button.dart';
import 'package:uuid/uuid.dart';
import '../../services/custom_content_service.dart';
import '../../domain/entities/team_template.dart';

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

  void _startGame() {
    final locale = ref.read(localeProvider);
    final t = AppLocalizations(locale);
    final teams = ref.read(gameProvider).teams;
    if (teams.length >= 2) {
      context.go('/category-selection');
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
    final locale = ref.watch(localeProvider);
    final t = AppLocalizations(locale);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('setup_teams')),
        actions: const [
          LanguagePickerButton(),
          SizedBox(width: 12),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _teamController,
                    decoration: InputDecoration(
                      hintText: t.translate('enter_team_name'),
                      prefixIcon: const Icon(Icons.group_add),
                    ),
                    onSubmitted: (_) => _addTeam(),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white, size: 28),
                    onPressed: _addTeam,
                  ),
                ),
              ],
            ).animate().fadeIn().slideY(begin: -0.2, end: 0),
            const SizedBox(height: 32),
            Expanded(
              child: ListView.builder(
                itemCount: gameState.teams.length,
                itemBuilder: (context, index) {
                  final team = gameState.teams[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      title: Text(
                        team.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () {
                          ref.read(gameProvider.notifier).removeTeam(team.id);
                        },
                      ),
                    ),
                  ).animate().fadeIn().slideX(begin: 0.2, end: 0, delay: (index * 100).ms);
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showLoadTemplateDialog,
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('LOAD TEMPLATE'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: gameState.teams.isNotEmpty ? _showSaveTemplateDialog : null,
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('SAVE TEMPLATE'),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: gameState.teams.length >= 2 ? _startGame : null,
                child: Text(t.translate('continue_btn')),
              ).animate().fadeIn(delay: 300.ms),
            ),
          ],
        ),
      ),
    );
  }

  void _showSaveTemplateDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save Team Template'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter template name'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                final teams = ref.read(gameProvider).teams.map((t) => TeamPreset(name: t.name)).toList();
                final template = TeamTemplate(
                  id: const Uuid().v4(),
                  templateName: name,
                  teams: teams,
                );
                ref.read(customContentServiceProvider).saveTeamTemplate(template);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Template saved!')));
              }
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  void _showLoadTemplateDialog() {
    final templates = ref.read(customContentServiceProvider).getTeamTemplates();
    if (templates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No saved templates found.')));
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Load Template'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final t = templates[index];
              return ListTile(
                title: Text(t.templateName),
                subtitle: Text('${t.teams.length} teams'),
                onTap: () {
                  ref.read(gameProvider.notifier).resetGame();
                  for (final teamPreset in t.teams) {
                    ref.read(gameProvider.notifier).addTeam(teamPreset.name);
                  }
                  Navigator.pop(ctx);
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    ref.read(customContentServiceProvider).deleteTeamTemplate(t.id);
                    Navigator.pop(ctx);
                    _showLoadTemplateDialog();
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CLOSE')),
        ],
      ),
    );
  }
}
