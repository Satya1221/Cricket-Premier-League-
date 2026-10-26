import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/display_labels.dart';
import '../../../theme/tokens.dart';
import '../../../widgets/ui/empty_state.dart';
import '../../../widgets/ui/game_page_scaffold.dart';
import '../application/season_provider.dart';
import '../domain/career_simulation_engine.dart';

class TrophyRoomScreen extends ConsumerWidget {
  const TrophyRoomScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final season = ref.watch(seasonProvider);
    final players = season.teams.expand((team) => team.players).toList();
    final runLeaders = players.where((player) => player.runs > 0).toList()
      ..sort((a, b) => b.runs.compareTo(a.runs));
    final wicketLeaders = players.where((player) => player.wickets > 0).toList()
      ..sort((a, b) => b.wickets.compareTo(a.wickets));
    final history = season.matchHistory;

    return GamePageScaffold(
      title: 'TROPHY ROOM',
      bodyPadding: EdgeInsets.zero,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpace.lg, AppSpace.lg, AppSpace.lg, AppSpace.huge,
        ),
        children: [
          _section(
            context,
            title: 'RUN SCORERS',
            subtitle: 'Season ${season.seasonNumber} · runs scored',
            icon: Icons.sports_cricket_rounded,
            players: runLeaders.take(10).toList(),
            batting: true,
          ),
          const SizedBox(height: AppSpace.lg),
          _section(
            context,
            title: 'WICKET TAKERS',
            subtitle: 'Season ${season.seasonNumber} · wickets taken',
            icon: Icons.sports_rounded,
            players: wicketLeaders.take(10).toList(),
            batting: false,
          ),
          const SizedBox(height: AppSpace.xl),
          Text(
            'MATCH ANALYTICS',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.action,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: AppSpace.sm),
          if (history.isEmpty)
            const EmptyState(
              icon: Icons.query_stats_rounded,
              title: 'Your records start here',
              message: 'Play or simulate a fixture to build player records and compare team run rates.',
              compact: true,
            )
          else
            for (final match in history.reversed.take(10))
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpace.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${match['home']} vs ${match['away']}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: AppSpace.xs),
                      Text(
                        '${match['homeScore']}  •  ${match['awayScore']}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: AppSpace.sm),
                      _runRateBars(match),
                      const SizedBox(height: AppSpace.xs),
                      const Text(
                        'Run rate is measured in runs per over.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _section(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required List<CareerPlayer> players,
    required bool batting,
  }) =>
      Container(
        padding: const EdgeInsets.all(AppSpace.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.action),
                const SizedBox(width: AppSpace.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.action,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .6,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.sm),
            if (players.isEmpty)
              EmptyState(
                icon: batting ? Icons.sports_cricket_rounded : Icons.sports_rounded,
                title: batting ? 'No run records yet' : 'No wickets recorded yet',
                message: 'Complete fixtures to populate this leaderboard. Players without match results are hidden instead of showing misleading zeros.',
                compact: true,
              )
            else
              for (var i = 0; i < players.length; i++)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: AppColors.action.withValues(alpha: .14),
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        color: AppColors.action,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  title: Text(
                    players[i].name,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    batting
                        ? '${DisplayLabels.display(players[i].role)} · High score ${players[i].highScore} · Fifties ${players[i].fifties} · Centuries ${players[i].hundreds}'
                        : '${DisplayLabels.display(players[i].role)} · Best bowling ${players[i].bestBowlingWickets}/${players[i].bestBowlingRuns} · Economy ${players[i].ballsBowled == 0 ? '—' : (players[i].runsConceded * 6 / players[i].ballsBowled).toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  trailing: Text(
                    '${batting ? players[i].runs : players[i].wickets}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
          ],
        ),
      );

  Widget _runRateBars(Map<String, Object?> match) {
    double rate(String key, String ballsKey) {
      final score = (match[key] as num?)?.toDouble() ?? 0;
      final balls = (match[ballsKey] as num?)?.toDouble() ?? 120;
      return balls <= 0 ? 0 : (score * 6 / balls).clamp(0, 20);
    }

    final homeRate = rate('homeRunsRaw', 'homeBallsRaw');
    final awayRate = rate('awayRunsRaw', 'awayBallsRaw');
    return Column(
      children: [
        _rateBar('Home', homeRate),
        const SizedBox(height: AppSpace.xs),
        _rateBar('Away', awayRate),
      ],
    );
  }

  Widget _rateBar(String label, double rate) => Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: (rate / 20).clamp(0, 1),
              minHeight: 8,
              backgroundColor: AppColors.border,
              color: AppColors.positive,
            ),
          ),
          const SizedBox(width: AppSpace.sm),
          Text(
            rate.toStringAsFixed(2),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
        ],
      );
}
