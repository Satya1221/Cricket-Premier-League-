import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../match/domain/stadium_pitch_engine.dart';
import 'academy_provider.dart';
import 'stadium_provider.dart';

/// Derived, read-only registry of career upgrades that affect simulations.
/// Keep these modifiers in one place so screens and domain controllers do not
/// each invent their own upgrade math.
class GameModifiers {
  const GameModifiers({
    required this.youthDevelopmentMultiplier,
    required this.matchXpMultiplier,
    required this.recoveryMultiplier,
    required this.spinAssist,
    required this.swingAssist,
    required this.seamAssist,
  });

  final double youthDevelopmentMultiplier;
  final double matchXpMultiplier;
  final double recoveryMultiplier;
  final double spinAssist;
  final double swingAssist;
  final double seamAssist;
}

final modifiersProvider = Provider<GameModifiers>((ref) {
  final academy = ref.watch(academyProvider);
  final stadium = ref.watch(stadiumProvider).selectedStadium;

  // Each facility level above level 1 adds 10% player development. Level 2
  // therefore yields 1.10x, and level 5 yields 1.40x.
  final trainingLevelsAboveBase = academy.facilities.trainingLevel - 1;
  final youthLevelsAboveBase = academy.facilities.youthAcademyLevel - 1;
  final youthCoachLevels = academy.staff
      .where((coach) => coach.specialty.name == 'youthDevelopment')
      .fold<int>(0, (total, coach) => total + coach.level);
  final fitnessCoachLevels = academy.staff
      .where((coach) => coach.specialty.name == 'fitness')
      .fold<int>(0, (total, coach) => total + coach.level);

  final pitch = switch (stadium.pitchType) {
    StadiumPitchType.dryDustySpinner => (spin: 1.70, swing: 0.70, seam: 0.80),
    StadiumPitchType.greenTopSeamer => (spin: 0.65, swing: 1.60, seam: 1.65),
    StadiumPitchType.flatBattingParadise => (spin: 0.80, swing: 0.80, seam: 0.85),
    StadiumPitchType.wearingBalanced => (spin: 1.00, swing: 1.00, seam: 1.00),
  };

  return GameModifiers(
    youthDevelopmentMultiplier: 1.0 + youthLevelsAboveBase * 0.10 + youthCoachLevels * 0.05,
    matchXpMultiplier: 1.0 + trainingLevelsAboveBase * 0.10,
    recoveryMultiplier: (0.5 + fitnessCoachLevels * 0.15).clamp(0.5, 1.0).toDouble(),
    spinAssist: pitch.spin,
    swingAssist: pitch.swing,
    seamAssist: pitch.seam,
  );
});
