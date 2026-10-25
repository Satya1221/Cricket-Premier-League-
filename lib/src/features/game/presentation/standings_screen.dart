import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/game_theme.dart';
import '../application/season_provider.dart';
import '../application/game_controller.dart';
import '../../../../state/league_standings_provider.dart';

class StandingsScreen extends ConsumerWidget {
  const StandingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final season = ref.watch(seasonProvider);
    final session = ref.watch(gameControllerProvider);
    final seasonActive = session.phase == GamePhase.season;
    final controller = ref.read(seasonProvider.notifier);
    final ranked = ref.watch(leagueStandingsProvider);
    final pendingFixtures = season.fixtures.where((f) => !f.played).toList();
    final nextFixture = pendingFixtures.isEmpty ? null : pendingFixtures.first;
    return Scaffold(
      appBar: AppBar(title: Text('SEASON ${season.seasonNumber} • LEAGUE TABLE')),
      backgroundColor: const Color(0xFF0B132B),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: GamePalette.panel, borderRadius: BorderRadius.circular(16), border: Border.all(color: GamePalette.line)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('ROUND ROBIN SEASON', style: TextStyle(color: GamePalette.gold, fontWeight: FontWeight.w900, letterSpacing: 1)),
              const SizedBox(height: 8),
              Text('${season.fixtures.where((f) => f.played).length} / ${season.fixtures.length} fixtures played', style: const TextStyle(color: Colors.white70)),
              if (nextFixture != null) ...[
                const SizedBox(height: 8),
                Text('Next: ${season.teams.firstWhere((t) => t.id == nextFixture.homeTeamId).name} vs ${season.teams.firstWhere((t) => t.id == nextFixture.awayTeamId).name}', style: const TextStyle(fontWeight: FontWeight.w800)),
              ],
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: [
                FilledButton.icon(onPressed: nextFixture == null || !seasonActive ? null : () => controller.simulateNextMatch(), icon: const Icon(Icons.play_arrow), label: const Text('SIMULATE NEXT')),
                OutlinedButton.icon(onPressed: nextFixture == null || !seasonActive ? null : () => controller.simulateRemainingRound(), icon: const Icon(Icons.fast_forward), label: const Text('SIMULATE ROUND')),
                OutlinedButton.icon(
                  onPressed: () async {
                    final ok = await controller.load();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(ok ? 'Career loaded.' : 'No saved career found yet.')),
                      );
                    }
                  },
                  icon: const Icon(Icons.folder_open),
                  label: const Text('LOAD SAVE'),
                ),
                OutlinedButton.icon(onPressed: controller.save, icon: const Icon(Icons.save), label: const Text('SAVE')),
                if (!seasonActive && season.seasonNumber > 1 && pendingFixtures.isNotEmpty)
                  FilledButton.icon(
                    onPressed: () => ref.read(gameControllerProvider.notifier).startSeason(),
                    icon: const Icon(Icons.play_circle_fill_rounded),
                    label: const Text('START SEASON'),
                  ),
                if (pendingFixtures.isEmpty && seasonActive)
                  FilledButton.icon(
                    onPressed: () async {
                      await controller.endSeason();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Season ${season.seasonNumber} archived. Season ${season.seasonNumber + 1} is ready.')),
                        );
                      }
                    },
                    icon: const Icon(Icons.flag_rounded),
                    label: const Text('END SEASON & ADVANCE'),
                  ),
              ]),
            ]),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(color: GamePalette.panel, borderRadius: BorderRadius.circular(16), border: Border.all(color: GamePalette.line)),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('#')), DataColumn(label: Text('TEAM')),
                  DataColumn(label: Text('P')), DataColumn(label: Text('W')),
                  DataColumn(label: Text('L')), DataColumn(label: Text('PTS')),
                  DataColumn(label: Text('NRR')),
                ],
                rows: [
                  for (var i = 0; i < ranked.length; i++)
                    DataRow(cells: [
                      DataCell(Text('${i + 1}')),
                      DataCell(Text(season.teams.firstWhere((team) => team.id == ranked[i].teamId).name)),
                      DataCell(Text('${ranked[i].played}')),
                      DataCell(Text('${ranked[i].won}')),
                      DataCell(Text('${ranked[i].lost}')),
                      DataCell(Text('${ranked[i].points}', style: const TextStyle(color: GamePalette.gold, fontWeight: FontWeight.w900))),
                      DataCell(Text(ranked[i].nrr.toStringAsFixed(3))),
                    ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text('RECENT RESULTS', style: TextStyle(color: GamePalette.gold, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 8),
          if (season.matchHistory.isEmpty)
            const Text('No fixtures simulated yet.', style: TextStyle(color: Colors.white54))
          else
            for (final match in season.matchHistory.reversed.take(8))
              Card(
                color: GamePalette.panel,
                child: ListTile(
                  title: Text('${match['home']}  ${match['homeScore']}  •  ${match['awayScore']}  ${match['away']}'),
                  subtitle: Text('Winner: ${season.teams.firstWhere((t) => t.id == match['winnerTeamId']).name}'),
                ),
              ),
        ],
      ),
    );
  }
}
