import 'package:flutter/material.dart';

import '../../../theme/game_theme.dart';
import '../domain/granular_player_profile.dart';

/// Reusable attribute panel for player profile and squad selection screens.
class PlayerAttributePanel extends StatelessWidget {
  const PlayerAttributePanel({super.key, required this.player});
  final GranularPlayerProfile player;

  @override
  Widget build(BuildContext context) {
    final groups = <(String, List<(String, int)>)>[
      ('BATTING', [('BAT', player.batting.bat), ('POWER', player.batting.pow),
        ('TECH', player.batting.tec), ('TEMP', player.batting.tmp),
        ('AGG', player.batting.agg), ('STYLE', player.batting.sty),
        ('RUN', player.batting.run), ('VS PACE', player.batting.vp),
        ('VS SPIN', player.batting.vs)]),
      ('BOWLING', [('BOWL', player.bowling.bowl), ('CONTROL', player.bowling.ctrl),
        ('DEATH', player.bowling.dth), ('PACE', player.bowling.pace),
        ('VAR', player.bowling.varStat), ('COMPOSURE', player.bowling.comp)]),
      ('FIELDING', [('CATCH', player.fielding.cat), ('FIELD', player.fielding.fld),
        ('FITNESS', player.fielding.fit)]),
      ('CONDITION', [('FORM', player.condition.form), ('MORALE', player.condition.mor),
        ('FITNESS', player.condition.fitness)]),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(player.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
      const SizedBox(height: 4),
      Text('${player.age}y • ${player.battingHand} • ${player.role}',
        style: const TextStyle(color: Colors.white60, fontSize: 12)),
      const SizedBox(height: 16),
      for (final group in groups) ...[
        Text(group.$1, style: const TextStyle(color: GamePalette.gold, fontWeight: FontWeight.w900, letterSpacing: 1)),
        const SizedBox(height: 8),
        for (final item in group.$2) _AttributeBar(label: item.$1, value: item.$2),
        const SizedBox(height: 14),
      ],
      if (player.traits.favouriteShots.isNotEmpty) ...[
        const Text('FAVOURITE SHOTS', style: TextStyle(color: GamePalette.gold, fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        Wrap(spacing: 6, runSpacing: 6, children: player.traits.favouriteShots.map((v) => _TraitChip(text: v)).toList()),
        const SizedBox(height: 12),
      ],
      if (player.traits.weaknesses.isNotEmpty) ...[
        const Text('WEAKNESSES', style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        Wrap(spacing: 6, runSpacing: 6, children: player.traits.weaknesses.map((v) => _TraitChip(text: v, warning: true)).toList()),
      ],
    ]);
  }
}

class _AttributeBar extends StatelessWidget {
  const _AttributeBar({required this.label, required this.value});
  final String label;
  final int value;
  @override
  Widget build(BuildContext context) {
    final color = value >= 85 ? Colors.greenAccent : value >= 65 ? GamePalette.gold : value >= 45 ? Colors.white70 : Colors.orangeAccent;
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [
      SizedBox(width: 76, child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w800))),
      Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(
        value: value.clamp(0, 100) / 100, minHeight: 6, backgroundColor: Colors.white10, color: color))),
      const SizedBox(width: 10),
      SizedBox(width: 26, child: Text('$value', textAlign: TextAlign.end, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w900))),
    ]));
  }
}

class _TraitChip extends StatelessWidget {
  const _TraitChip({required this.text, this.warning = false});
  final String text;
  final bool warning;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(color: (warning ? Colors.orangeAccent : GamePalette.emerald).withValues(alpha: .12),
      border: Border.all(color: (warning ? Colors.orangeAccent : GamePalette.emerald).withValues(alpha: .55)),
      borderRadius: BorderRadius.circular(20)),
    child: Text(text, style: TextStyle(color: warning ? Colors.orangeAccent : Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.w700)),
  );
}
