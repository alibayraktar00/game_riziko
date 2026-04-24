import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/game_provider.dart';

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
    final teams = ref.read(gameProvider).teams;
    if (teams.length >= 2) {
      context.go('/category-selection');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least 2 teams are required to start.')),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('SETUP TEAMS'),
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
                    decoration: const InputDecoration(
                      hintText: 'Enter Team Name',
                      prefixIcon: Icon(Icons.group_add),
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: gameState.teams.length >= 2 ? _startGame : null,
                child: const Text('CONTINUE'),
              ).animate().fadeIn(delay: 300.ms),
            ),
          ],
        ),
      ),
    );
  }
}
