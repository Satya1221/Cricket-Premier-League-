import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/tokens.dart';
import '../../../widgets/ui/empty_state.dart';
import '../../../widgets/ui/game_page_scaffold.dart';
import '../application/season_provider.dart';
import '../application/game_controller.dart';
import '../domain/career_simulation_engine.dart';
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
    final playedFixtures = season.fixtures.where((fixture) => fixture.played).length;
    final pendingFixtures = season.fixtures.where((fixture) => !fixture.played).toList();
    final nextFixture = pendingFixtures.isEmpty ? null : pendingFixtures.first;
    final allComplete = season.fixtures.isNotEmpty && pendingFixtures.isEmpty;

    return GamePageScaffold(
      title: 'SEASON ${season.seasonNumber} · LEAGUE TABLE',
      bodyPadding: EdgeInsets.zero,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpace.lg, AppSpace.md, AppSpace.lg, AppSpace.huge,
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpace.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ROUND-ROBIN SEASON',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.action,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: AppSpace.sm),
                Text(
                  '$playedFixtures of ${season.fixtures.length} fixtures played',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                if (nextFixture != null) ...[
                  const SizedBox(height: AppSpace.sm),
                  Text(
                    'Next: ${_teamName(season.teams, nextFixture.homeTeamId)} vs ${_teamName(season.teams, nextFixture.awayTeamId)}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpace.md),
                Wrap(
                  spacing: AppSpace.sm,
                  runSpacing: AppSpace.sm,
                  children: [
                    if (seasonActive && nextFixture != null)
                      FilledButton.icon(
                        onPressed: controller.simulateNextMatch,
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('SIMULATE NEXT'),
                      ),
                    if (seasonActive && nextFixture != null)
                      OutlinedButton.icon(
                        onPressed: controller.simulateRemainingRound,
                        icon: const Icon(Icons.fast_forward_rounded),
                        label: const Text('SIMULATE ROUND'),
                      ),
                    if (!seasonActive && season.seasonNumber > 1 && nextFixture != null)
                      FilledButton.icon(
                        onPressed: () => ref.read(gameControllerProvider.notifier).startSeason(),
                        icon: const Icon(Icons.play_circle_fill_rounded),
                        label: const Text('START SEASON'),
                      ),
                    if (allComplete && seasonActive)
                      FilledButton.icon(
                        onPressed: () async {
                          try {
                            await controller.endSeason();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Season ${season.seasonNumber} archived. Season ${season.seasonNumber + 1} is ready.',
                                ),
                              ),
                            );
                          } on StateError catch (error) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(error.message)),
                            );
                          }
                        },
                        icon: const Icon(Icons.flag_rounded),
                        label: const Text('END SEASON'),
                      ),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final ok = await controller.load();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(ok ? 'Career loaded.' : 'No saved career found yet.'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.folder_open_rounded),
                      label: const Text('LOAD SAVE'),
                    ),
                    OutlinedButton.icon(
                      onPressed: controller.save,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('SAVE'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.lg),
          if (playedFixtures == 0)
            const Card(
              child: EmptyState(
                icon: Icons.emoji_events_outlined,
                title: 'The table is waiting for its first result',
                message: 'Once the season starts and the first fixture is completed, points and net run rate will appear here. New careers no longer show a wall of zeros.',
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('POS.')),
                    DataColumn(label: Text('TEAM')),
                    DataColumn(label: Text('PLAYED')),
                    DataColumn(label: Text('WON')),
                    DataColumn(label: Text('LOST')),
                    DataColumn(label: Text('POINTS')),
                    DataColumn(label: Text('NET RUN RATE')),
                  ],
                  rows: [
                    for (var i = 0; i < ranked.length; i++)
                      DataRow(
                        cells: [
                          DataCell(Text('${i + 1}')),
                          DataCell(Text(_teamName(season.teams, ranked[i].teamId))),
                          DataCell(Text('${ranked[i].played}')),
                          DataCell(Text('${ranked[i].won}')),
                          DataCell(Text('${ranked[i].lost}')),
                          DataCell(
                            Text(
                              '${ranked[i].points}',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          DataCell(Text(ranked[i].nrr.toStringAsFixed(3))),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: AppSpace.xl),
          Text(
            'RECENT RESULTS',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.action,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: AppSpace.sm),
          if (season.matchHistory.isEmpty)
            const EmptyState(
              icon: Icons.sports_cricket_rounded,
              title: 'No results to show',
              message: 'Completed match scorelines and winners will be archived here.',
              compact: true,
            )
          else
            for (final match in season.matchHistory.reversed.take(8))
              Card(
                child: ListTile(
                  title: Text(
                    '${match['home']}  ${match['homeScore']}  ·  ${match['awayScore']}  ${match['away']}',
                  ),
                  subtitle: Text(
                    'Winner: ${_teamName(season.teams, match['winnerTeamId'] as String? ?? '')}',
                  ),
                ),
              ),
        ],
      ),
    );
  }

  static String _teamName(List<CareerTeam> teams, String id) {
    for (final team in teams) {
      if (team.id == id) return team.name;
    }
    return 'Unknown team';
  }
}
