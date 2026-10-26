import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../theme/game_theme.dart';
import '../../match/matchday_screen.dart';

class FirstMatchTutorialScreen extends ConsumerStatefulWidget {
  const FirstMatchTutorialScreen({super.key});
  @override
  ConsumerState<FirstMatchTutorialScreen> createState() => _FirstMatchTutorialScreenState();
}

class _FirstMatchTutorialScreenState extends ConsumerState<FirstMatchTutorialScreen> {
  bool _started = false;

  Future<void> _finish() async {
    await Hive.box<dynamic>('career_saves').put('ftue-complete', true);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: GamePalette.ink,
    appBar: AppBar(title: const Text('YOUR FIRST OVER')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      const Icon(Icons.school_rounded, color: GamePalette.gold, size: 56),
      const SizedBox(height: 16),
      const Text('WELCOME TO FRANCHISE CRICKET', style: TextStyle(color: GamePalette.gold, fontWeight: FontWeight.w900, letterSpacing: 1)),
      const SizedBox(height: 12),
      const Text('Learn the controls in a short exhibition before managing your franchise.', style: TextStyle(color: Colors.white70, height: 1.5)),
      const SizedBox(height: 18),
      _lesson('1', 'BATTER INTENT', 'DEFEND protects your wicket. ROTATE looks for singles and twos. SLOG trades risk for boundaries.'),
      _lesson('2', 'FIELD TRAPS', 'A field trap targets a batter’s scoring options. Bowling line, length and variation also affect each delivery.'),
      _lesson('3', 'READ THE PITCH', 'Pitch conditions and ball age influence movement. Fatigue and tactics should matter across a full match.'),
      const SizedBox(height: 20),
      if (!_started)
        FilledButton.icon(onPressed: () {
          setState(() => _started = true);
          Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const MatchdayScreen()));
        }, icon: const Icon(Icons.play_arrow), label: const Text('START EXHIBITION MATCH'))
      else
        FilledButton.icon(onPressed: _finish, icon: const Icon(Icons.check_circle_outline), label: const Text('FINISH TUTORIAL & ENTER HQ')),
      const SizedBox(height: 8),
      const Text('This tutorial uses the existing match engine; it does not force scripted boundaries or wickets.', style: TextStyle(color: Colors.white38, fontSize: 11)),
    ]),
  );

  Widget _lesson(String number, String title, String body) => Card(
    color: GamePalette.panel,
    child: ListTile(
      leading: CircleAvatar(backgroundColor: GamePalette.gold.withValues(alpha: .15), child: Text(number, style: const TextStyle(color: GamePalette.gold, fontWeight: FontWeight.w900))),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
      subtitle: Padding(padding: const EdgeInsets.only(top: 5), child: Text(body, style: const TextStyle(color: Colors.white60, height: 1.4))),
    ),
  );
}
