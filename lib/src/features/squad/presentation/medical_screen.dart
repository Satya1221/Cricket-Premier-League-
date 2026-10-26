import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/game_theme.dart';
import '../../../widgets/ui/empty_state.dart';
import '../../../core/display_labels.dart';
import '../../../../state/medical_workload_provider.dart';
import '../../auction/application/auction_controller.dart';
import '../../auction/domain/player.dart';
import '../application/medical_provider.dart';
import '../domain/medical_center_engine.dart';

class MedicalCenterScreen extends ConsumerWidget {
  const MedicalCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(medicalCenterProvider);
    final actions = ref.read(medicalCenterProvider.notifier);
    final workloads = ref.watch(medicalWorkloadProvider);
    final workloadActions = ref.read(medicalWorkloadProvider.notifier);
    final auction = ref.watch(auctionControllerProvider);
    final managedTeam = auction.teams.where((team) => team.id == 'cpl').toList();
    final squad = managedTeam.isEmpty ? <AuctionPlayer>[] : managedTeam.first.squad;

    return Scaffold(
      backgroundColor: GamePalette.ink,
      appBar: AppBar(title: const Text('MEDICAL CENTER')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          _panel(
            'PHYSIO DEPARTMENT',
            'Physio level ${state.physioLevel}/5 · Higher levels shorten recovery estimates.',
            Icons.health_and_safety_rounded,
          ),
          Slider(
            value: state.physioLevel.toDouble(),
            min: 0,
            max: 5,
            divisions: 5,
            label: 'Level ${state.physioLevel}',
            onChanged: (value) => actions.setPhysioLevel(value.round()),
          ),
          const SizedBox(height: 10),
          const Text(
            'SQUAD FATIGUE & AVAILABILITY',
            style: TextStyle(
              color: GamePalette.gold,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          if (workloads.isEmpty)
            const EmptyState(
              icon: Icons.monitor_heart_outlined,
              title: 'No workload history yet',
              message: 'Assess your actual squad to establish a baseline. Fatigue and injury status will be retained between sessions.',
              compact: true,
            )
          else
            for (final player in workloads.values)
              Card(
                child: ListTile(
                  title: Text(
                    _playerName(player.playerId, squad),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    player.unavailable
                        ? '${player.injuryType ?? 'Injured'} · ${player.injuryWeeksRemaining} week(s) unavailable'
                        : 'Available for selection',
                    style: const TextStyle(color: GamePalette.muted),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Fatigue ${player.fatigue}%',
                        style: TextStyle(
                          color: player.fatigue > 75
                              ? GamePalette.danger
                              : GamePalette.emerald,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (player.unavailable)
                        const Icon(
                          Icons.medical_services_rounded,
                          color: GamePalette.danger,
                          size: 16,
                        ),
                    ],
                  ),
                ),
              ),
          OutlinedButton.icon(
            onPressed: () => workloadActions.advanceWeek(
              physioLevel: state.physioLevel,
            ),
            icon: const Icon(Icons.healing_rounded),
            label: const Text('ADVANCE RECOVERY WEEK'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: squad.isEmpty
                ? null
                : () => actions.assessWorkloads([
                      for (final player in squad)
                        PlayerWorkload(
                          playerId: player.id,
                          age: player.age,
                          pace: player.bowling,
                          fatigue: workloads[player.id]?.fatigue ?? 0,
                          recentBowlingBalls: 0,
                          consecutiveMatchDays: 0,
                          existingInjury: workloads[player.id]?.unavailable ?? false,
                        ),
                    ]),
            icon: const Icon(Icons.monitor_heart_rounded),
            label: const Text('ASSESS CURRENT SQUAD'),
          ),
          if (squad.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Complete at least one auction signing before assessing the squad.',
                style: TextStyle(color: GamePalette.muted),
              ),
            ),
          const SizedBox(height: 10),
          const Text(
            'INJURY LIST',
            style: TextStyle(
              color: GamePalette.gold,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          if (state.injuries.isEmpty)
            const EmptyState(
              icon: Icons.health_and_safety_outlined,
              title: 'No injuries recorded',
              message: 'Risk assessments will identify players who need rest or closer monitoring.',
              compact: true,
            )
          else
            for (final injury in state.injuries)
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.personal_injury_rounded,
                    color: GamePalette.danger,
                  ),
                  title: Text(
                    _playerName(injury.playerId, squad),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    '${DisplayLabels.display(injury.injuryType)}\n${injury.notes}',
                    style: const TextStyle(color: GamePalette.muted),
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    tooltip: 'Mark recovered',
                    onPressed: () => actions.recoverPlayer(injury.playerId),
                    icon: const Icon(
                      Icons.check_circle_outline,
                      color: GamePalette.emerald,
                    ),
                  ),
                ),
              ),
          const SizedBox(height: 12),
          const Text(
            'LATEST WORKLOAD ASSESSMENTS',
            style: TextStyle(
              color: GamePalette.gold,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (state.assessments.isEmpty)
            const EmptyState(
              icon: Icons.assignment_outlined,
              title: 'No assessments yet',
              message: 'Run an assessment using the current squad to see risk scores and recommended recovery time.',
              compact: true,
            )
          else
            for (final assessment in state.assessments)
              Card(
                child: ListTile(
                  title: Text(
                    _playerName(assessment.playerId, squad),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    '${assessment.reasons.isEmpty ? 'No specific warning' : assessment.reasons.join(' · ')}\nRecommended rest: ${assessment.recommendedRestDays} days',
                    style: const TextStyle(color: GamePalette.muted),
                  ),
                  trailing: Text(
                    'Risk ${assessment.risk}/100',
                    style: TextStyle(
                      color: assessment.risk >= 60
                          ? GamePalette.danger
                          : assessment.risk >= 35
                              ? GamePalette.gold
                              : GamePalette.emerald,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  static String _playerName(String playerId, List<AuctionPlayer> squad) {
    for (final player in squad) {
      if (player.id == playerId) return player.name;
    }
    return playerId;
  }
}

Widget _panel(String title, String body, IconData icon) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GamePalette.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GamePalette.line),
      ),
      child: Row(
        children: [
          Icon(icon, color: GamePalette.gold, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  body,
                  style: const TextStyle(color: GamePalette.muted, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
