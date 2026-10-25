import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/game_theme.dart';
import '../../../../state/medical_workload_provider.dart';
import '../application/medical_provider.dart';
import '../domain/medical_center_engine.dart';
class MedicalCenterScreen extends ConsumerWidget {
  const MedicalCenterScreen({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(medicalCenterProvider); final actions = ref.read(medicalCenterProvider.notifier);
    final workloads = ref.watch(medicalWorkloadProvider);
    final workloadActions = ref.read(medicalWorkloadProvider.notifier);
    return Scaffold(backgroundColor: const Color(0xFF0B132B), appBar: AppBar(title: const Text('MEDICAL CENTER')), body: ListView(padding: const EdgeInsets.all(16), children: [
      _panel('PHYSIO DEPARTMENT', 'Physio level ${state.physioLevel}/5 · Higher levels shorten recovery estimates.', Icons.health_and_safety_rounded),
      Slider(value: state.physioLevel.toDouble(), min: 0, max: 5, divisions: 5, label: 'Level ${state.physioLevel}', onChanged: (v) => actions.setPhysioLevel(v.round())),
      const SizedBox(height: 10),
      const Text('SQUAD FATIGUE & AVAILABILITY', style: TextStyle(color: GamePalette.gold, fontWeight: FontWeight.w900, letterSpacing: 1)),
      if (workloads.isEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('No saved workload records yet. Workload is recorded as player match-settlement hooks are connected.', style: TextStyle(color: Colors.white54))),
      for (final player in workloads.values) Card(color: const Color(0xFF1C2541), child: ListTile(
        title: Text(player.playerId, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        subtitle: Text(player.unavailable ? '${player.injuryType ?? 'Injured'} · ${player.injuryWeeksRemaining} week(s) unavailable' : 'Available', style: const TextStyle(color: Colors.white60)),
        trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('${player.fatigue}%', style: TextStyle(color: player.fatigue > 75 ? Colors.redAccent : GamePalette.emerald, fontWeight: FontWeight.w900)), if (player.unavailable) const Icon(Icons.medical_services, color: Colors.orangeAccent, size: 16)]),
      )),
      OutlinedButton.icon(onPressed: () => workloadActions.advanceWeek(physioLevel: state.physioLevel), icon: const Icon(Icons.healing), label: const Text('ADVANCE RECOVERY WEEK')),
      const SizedBox(height: 10), const Text('INJURY LIST', style: TextStyle(color: GamePalette.gold, fontWeight: FontWeight.w900, letterSpacing: 1)),
      if (state.injuries.isEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 22), child: Text('No recorded injuries. Run a workload assessment after a match to evaluate risk.', style: TextStyle(color: Colors.white60, height: 1.4))),
      for (final injury in state.injuries) Card(color: const Color(0xFF1C2541), child: ListTile(leading: const Icon(Icons.personal_injury_rounded, color: Colors.orangeAccent), title: Text(injury.playerId, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)), subtitle: Text('${injury.injuryType}\n${injury.notes}', style: const TextStyle(color: Colors.white60)), isThreeLine: true, trailing: IconButton(tooltip: 'Mark recovered', onPressed: () => actions.recoverPlayer(injury.playerId), icon: const Icon(Icons.check_circle_outline, color: Colors.greenAccent)))),
      const SizedBox(height: 12), const Text('LATEST WORKLOAD ASSESSMENTS', style: TextStyle(color: GamePalette.gold, fontWeight: FontWeight.w900)),
      for (final a in state.assessments) Card(color: const Color(0xFF1C2541), child: ListTile(title: Text(a.playerId, style: const TextStyle(color: Colors.white)), subtitle: Text('${a.reasons.isEmpty ? 'No specific warning' : a.reasons.join(' · ')}\nRecommended rest: ${a.recommendedRestDays} days', style: const TextStyle(color: Colors.white60)), trailing: Text('${a.risk}/100', style: TextStyle(color: a.risk >= 60 ? Colors.redAccent : a.risk >= 35 ? Colors.orangeAccent : Colors.greenAccent, fontWeight: FontWeight.w900)))),
      const SizedBox(height: 10), OutlinedButton.icon(onPressed: () => actions.assessWorkloads(const [PlayerWorkload(playerId: 'Fast Bowler A', age: 31, pace: 94, fatigue: 82, recentBowlingBalls: 210, consecutiveMatchDays: 4), PlayerWorkload(playerId: 'Spinner B', age: 25, pace: 55, fatigue: 35, recentBowlingBalls: 90, consecutiveMatchDays: 2)]), icon: const Icon(Icons.monitor_heart), label: const Text('DEMO: ASSESS RECENT WORKLOAD')),
    ]));
  }
}
Widget _panel(String title, String body, IconData icon) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF1C2541), borderRadius: BorderRadius.circular(16), border: Border.all(color: GamePalette.line)), child: Row(children: [Icon(icon, color: GamePalette.gold, size: 30), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)), const SizedBox(height: 5), Text(body, style: const TextStyle(color: Colors.white60, height: 1.3))]))]));