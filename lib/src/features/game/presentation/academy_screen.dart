import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/game_theme.dart';
import '../application/academy_provider.dart';
import '../application/modifiers_provider.dart';
import '../domain/academy_engine.dart';

class AcademyScreen extends ConsumerWidget {
  const AcademyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(academyProvider);
    final c = ref.read(academyProvider.notifier);
    final modifiers = ref.watch(modifiersProvider);
    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      appBar: AppBar(title: const Text('ACADEMY & STAFF')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF1C2541),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FRANCHISE DEVELOPMENT FUND',
                  style: TextStyle(color: Colors.white60, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  '${s.budget} credits',
                  style: const TextStyle(color: GamePalette.gold, fontSize: 30, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  'Youth potential cap preview: ${c.potentialCap(75)} OVR',
                  style: const TextStyle(color: Colors.greenAccent),
                ),
                const SizedBox(height: 8),
                Text(
                  'Active bonuses: XP ×${modifiers.matchXpMultiplier.toStringAsFixed(2)} · Youth development ×${modifiers.youthDevelopmentMultiplier.toStringAsFixed(2)} · Recovery ×${modifiers.recoveryMultiplier.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _facility(
            context,
            title: 'TRAINING FACILITIES',
            level: s.facilities.trainingLevel,
            cost: s.facilities.upgradeCostTraining,
            note: '+10% player XP per match and -1 day recovery time per level.',
            onUpgrade: () => _showResult(context, c.upgrade(youthAcademy: false)),
          ),
          const SizedBox(height: 12),
          _facility(
            context,
            title: 'YOUTH ACADEMY',
            level: s.facilities.youthAcademyLevel,
            cost: s.facilities.upgradeCostAcademy,
            note: 'Raises the youth potential cap by +3 OVR per level (75 \u2192 82 at level 2).',
            onUpgrade: () => _showResult(context, c.upgrade(youthAcademy: true)),
            onInfo: () => showDialog<void>(context: context, builder: (dialogContext) => AlertDialog(
              title: const Text('YOUTH ACADEMY'),
              content: Text('Increases maximum potential of generated rookies. Current Cap: ${c.potentialCap(75)}. Next Cap: ${c.potentialCap(75) + 3}.'),
              actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('GOT IT'))],
            )),
          ),
          const SizedBox(height: 20),
          const Text(
            'COACHING STAFF',
            style: TextStyle(color: GamePalette.gold, fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
          for (final specialty in CoachSpecialty.values)
            Card(
              color: const Color(0xFF1C2541),
              child: ListTile(
                leading: const Icon(Icons.sports, color: GamePalette.gold),
                title: Text(
                  _coachName(specialty),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  s.staff.any((x) => x.specialty == specialty)
                      ? 'Hired \u00b7 ${_coachEffect(specialty)}'
                      : '${_coachEffect(specialty)}\nHire cost: 100 credits/season',
                  style: const TextStyle(color: Colors.white60),
                ),
                isThreeLine: true,
                trailing: s.staff.any((x) => x.specialty == specialty)
                    ? const Icon(Icons.check_circle, color: Colors.greenAccent)
                    : IconButton(
                        onPressed: () {
                          final message = c.hireCoach(CoachingStaff(
                            name: _coachName(specialty),
                            specialty: specialty,
                            level: 1,
                            salaryPerSeason: 100,
                          ));
                          _showResult(context, message);
                        },
                        icon: const Icon(Icons.add_circle_outline, color: GamePalette.gold),
                      ),
              ),
            ),
          const SizedBox(height: 8),
          const Text(
            'Upgrades and staff currently live in Riverpod memory for this session; permanent save support is not connected.',
            style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }
}

Widget _facility(
  BuildContext context, {
  required String title,
  required int level,
  required int cost,
  required String note,
  required VoidCallback onUpgrade,
  VoidCallback? onInfo,
}) =>
    Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2541),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GamePalette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                'LEVEL $level/5',
                style: const TextStyle(color: GamePalette.gold, fontWeight: FontWeight.w900),
              ),
              if (onInfo != null) IconButton(tooltip: 'Upgrade details', onPressed: onInfo, icon: const Icon(Icons.info_outline, color: GamePalette.gold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            note,
            style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.3),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: level / 5,
            color: GamePalette.emerald,
            backgroundColor: Colors.white12,
            minHeight: 6,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: cost == 0 ? null : onUpgrade,
              child: Text(cost == 0 ? 'MAX LEVEL' : 'UPGRADE \u00b7 $cost CREDITS'),
            ),
          ),
        ],
      ),
    );

String _coachName(CoachSpecialty s) => switch (s) {
      CoachSpecialty.batting => 'Batting Coach',
      CoachSpecialty.paceBowling => 'Pace Bowling Coach',
      CoachSpecialty.spinBowling => 'Spin Bowling Consultant',
      CoachSpecialty.fielding => 'Fielding Coach',
      CoachSpecialty.fitness => 'Fitness Coach',
      CoachSpecialty.youthDevelopment => 'Youth Development Coach',
    };

String _coachEffect(CoachSpecialty s) => switch (s) {
      CoachSpecialty.batting => '+5% batter concentration recovery during an innings.',
      CoachSpecialty.paceBowling => '+4% pace threat and seam movement.',
      CoachSpecialty.spinBowling => '+4% spin threat and turn.',
      CoachSpecialty.fielding => '+5% catching support in the field.',
      CoachSpecialty.fitness => '-15% workload fatigue accumulated per over.',
      CoachSpecialty.youthDevelopment => '+2 youth potential cap while employed.',
    };

void _showResult(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
}
