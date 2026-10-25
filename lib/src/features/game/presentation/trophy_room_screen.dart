import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/game_theme.dart';
import '../application/season_provider.dart';

class TrophyRoomScreen extends ConsumerWidget {
  const TrophyRoomScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final season = ref.watch(seasonProvider);
    final players = season.teams.expand((team) => team.players).toList();
    final runLeaders = [...players]..sort((a, b) => b.runs.compareTo(a.runs));
    final wicketLeaders = [...players]..sort((a, b) => b.wickets.compareTo(a.wickets));
    final history = season.matchHistory;
    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      appBar: AppBar(title: const Text('TROPHY ROOM • ALL-TIME RECORDS')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _section('ALL-TIME RUN SCORERS', Icons.sports_cricket, runLeaders.take(10).toList(), true),
        const SizedBox(height: 16),
        _section('ALL-TIME WICKET TAKERS', Icons.sports, wicketLeaders.take(10).toList(), false),
        const SizedBox(height: 20),
        const Text('MATCH ANALYTICS', style: TextStyle(color: GamePalette.gold, fontWeight: FontWeight.w900, letterSpacing: 1)),
        const SizedBox(height: 8),
        if (history.isEmpty)
          const Text('Simulate fixtures to create your universe records and match analytics.', style: TextStyle(color: Colors.white60))
        else
          for (final match in history.reversed.take(10))
            Card(color: GamePalette.panel, child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${match['home']}  vs  ${match['away']}', style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text('${match['homeScore']}  •  ${match['awayScore']}', style: const TextStyle(color: GamePalette.gold, fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                _runRateBars(match),
                const SizedBox(height: 6),
                Text('Run-rate comparison (runs per over)', style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ]),
            )),
      ]),
    );
  }

  Widget _section(String title, IconData icon, List<dynamic> players, bool batting) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: GamePalette.panel, borderRadius: BorderRadius.circular(16), border: Border.all(color: GamePalette.line)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(icon, color: GamePalette.gold), const SizedBox(width: 8), Text(title, style: const TextStyle(color: GamePalette.gold, fontWeight: FontWeight.w900, letterSpacing: .6))]),
      const SizedBox(height: 10),
      if (players.isEmpty) const Text('No player records yet. Add players and simulate matches.', style: TextStyle(color: Colors.white54))
      else for (var i = 0; i < players.length; i++)
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(backgroundColor: GamePalette.gold.withValues(alpha: .15), child: Text('${i + 1}', style: const TextStyle(color: GamePalette.gold, fontWeight: FontWeight.w900))),
          title: Text(players[i].name, style: const TextStyle(fontWeight: FontWeight.w800)),
          subtitle: Text(batting ? '${players[i].role} · HS ${players[i].highScore} · 50s ${players[i].fifties} · 100s ${players[i].hundreds}' : '${players[i].role} · Best ${players[i].bestBowlingWickets}/${players[i].bestBowlingRuns} · Econ ${players[i].ballsBowled == 0 ? '—' : (players[i].runsConceded * 6 / players[i].ballsBowled).toStringAsFixed(2)}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
          trailing: Text('${batting ? players[i].runs : players[i].wickets}', style: const TextStyle(color: GamePalette.gold, fontSize: 20, fontWeight: FontWeight.w900)),
        ),
    ]),
  );

  Widget _runRateBars(Map<String, Object?> match) {
    double rate(String key, String ballsKey) {
      final score = (match[key] as num?)?.toDouble() ?? 0;
      final balls = (match[ballsKey] as num?)?.toDouble() ?? 120;
      return balls <= 0 ? 0 : (score * 6 / balls).clamp(0, 20);
    }
    final homeRate = rate('homeRunsRaw', 'homeBallsRaw');
    final awayRate = rate('awayRunsRaw', 'awayBallsRaw');
    return Column(children: [
      _rateBar('Home', homeRate),
      const SizedBox(height: 6),
      _rateBar('Away', awayRate),
    ]);
  }

  Widget _rateBar(String label, double rate) => Row(children: [
    SizedBox(width: 48, child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11))),
    Expanded(child: LinearProgressIndicator(value: (rate / 20).clamp(0, 1), minHeight: 8, backgroundColor: Colors.white10, color: GamePalette.emerald)),
    const SizedBox(width: 8),
    Text(rate.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
  ]);
}
