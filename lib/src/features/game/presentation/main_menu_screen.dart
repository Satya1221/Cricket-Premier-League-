import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../state/user_preferences_provider.dart';
import '../../../../state/franchise_roster_provider.dart';
import '../../auction/application/auction_controller.dart';
import '../../../theme/game_theme.dart';
import '../application/game_controller.dart';
import '../data/campaign_store.dart';
import 'home_screen.dart';
import 'startup_screen.dart';

/// First entry point. Keep campaign setup separate from the active franchise
/// dashboard so launching the app does not silently start a new career.
class MainMenuScreen extends ConsumerWidget {
  const MainMenuScreen({super.key});

  void _startNewGame(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const StartupScreen()),
    );
  }

  Future<void> _openLoadGame(BuildContext context, WidgetRef ref) async {
    final saves = CampaignStore.listSaves();
    if (saves.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No saved campaigns yet. Start a new campaign first.'),
        ),
      );
      return;
    }

    final chosen = await showDialog<CampaignSave>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: GamePalette.panel,
        title: const Text(
          'LOAD CAMPAIGN',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final save in saves)
                ListTile(
                  leading: const Icon(Icons.sports_cricket_rounded, color: GamePalette.gold),
                  title: Text(
                    '${save.franchiseName} \u00b7 ${save.league}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    'Season ${save.seasonNumber} \u00b7 ${save.squadCount} players \u00b7 \u20b9${save.purseCr.toStringAsFixed(1)} Cr\n${_savedLabel(save.lastSavedAt)}',
                    style: const TextStyle(color: Colors.white60, fontSize: 11),
                  ),
                  isThreeLine: true,
                  onTap: () => Navigator.of(dialogContext).pop(save),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CANCEL'),
          ),
        ],
      ),
    );
    if (chosen == null) return;

    await CampaignStore.setActiveCampaign(chosen.id);
    ref.read(auctionControllerProvider.notifier).loadActiveCampaign();
    ref.read(franchiseRosterProvider.notifier).loadActiveCampaign();
    ref.read(gameControllerProvider.notifier).restoreCampaign(
      campaignId: chosen.id,
      league: chosen.league,
      franchiseName: chosen.franchiseName,
      purseCr: chosen.purseCr,
      difficulty: chosen.difficulty,
      seasonNumber: chosen.seasonNumber,
      completedMatches: chosen.completedMatches,
      phase: chosen.phase,
      lastAction: chosen.lastAction,
    );

    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
    );
  }

  static String _savedLabel(DateTime? savedAt) {
    if (savedAt == null) return 'Not saved yet';
    final local = savedAt.toLocal();
    String two(int value) => value.toString().padLeft(2, '0');
    return 'Saved ${two(local.day)}/${two(local.month)}/${local.year} '
        '${two(local.hour)}:${two(local.minute)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: GamePalette.ink,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 190,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [GamePalette.emerald, GamePalette.ink],
                      ),
                      border: Border.all(color: GamePalette.gold.withValues(alpha: .4)),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sports_cricket_rounded, size: 64, color: GamePalette.gold),
                        SizedBox(height: 18),
                        Text(
                          'CRICKET PREMIER LEAGUE',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 19, letterSpacing: 2, fontWeight: FontWeight.w900),
                        ),
                        SizedBox(height: 7),
                        Text(
                          'BUILD YOUR FRANCHISE. CREATE YOUR LEGACY.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 9, letterSpacing: 1.2, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 34),
                  FilledButton.icon(
                    onPressed: () => _startNewGame(context),
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    label: const Text('NEW CAMPAIGN'),
                    style: FilledButton.styleFrom(
                      backgroundColor: GamePalette.gold,
                      foregroundColor: GamePalette.ink,
                      minimumSize: const Size.fromHeight(58),
                      textStyle: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: .8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _openLoadGame(context, ref),
                    icon: const Icon(Icons.folder_open_rounded),
                    label: const Text('LOAD GAME'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: GamePalette.line),
                      minimumSize: const Size.fromHeight(54),
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (dialogContext) => Consumer(
                        builder: (context, dialogRef, _) {
                          final preferences = dialogRef.watch(userPreferencesProvider);
                          final actions = dialogRef.read(userPreferencesProvider.notifier);
                          return AlertDialog(
                            title: const Text('GAME SETTINGS'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                DropdownButtonFormField<String>(
                                  initialValue: preferences.difficulty,
                                  decoration: const InputDecoration(labelText: 'Difficulty'),
                                  items: const ['Easy', 'Normal', 'Hard'].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      actions.setDifficulty(value);
                                    }
                                  },
                                ),
                                SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text('Sound effects'),
                                  value: preferences.soundEnabled,
                                  onChanged: actions.setSoundEnabled,
                                ),
                              ],
                            ),
                            actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('DONE'))],
                          );
                        },
                      ),
                    ),
                    icon: const Icon(Icons.tune_rounded),
                    label: const Text('SETTINGS'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: GamePalette.line),
                      minimumSize: const Size.fromHeight(54),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'CAREER MODE • FRANCHISE MANAGEMENT • MATCHDAY',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: GamePalette.muted, fontSize: 9, letterSpacing: 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
