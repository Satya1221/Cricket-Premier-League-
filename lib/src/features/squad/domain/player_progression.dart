import 'dart:math';

/// Season-end organic progression. Pure Dart; no Flutter dependencies.
class ProgressionPlayer {
  ProgressionPlayer({
    required this.name,
    required this.age,
    required this.overallRating,
    required this.softCap,
    this.matchesPlayed = 0,
    this.averageForm = 0.5,
  })  : assert(age >= 15),
        assert(overallRating >= 30 && overallRating <= 99),
        assert(softCap >= 30 && softCap <= 99),
        assert(matchesPlayed >= 0),
        assert(averageForm >= 0 && averageForm <= 1);

  final String name;
  int age;
  double overallRating;
  double softCap;
  int matchesPlayed;
  double averageForm;
}

class ProgressionResult {
  const ProgressionResult({
    required this.oldRating,
    required this.newRating,
    required this.ratingDelta,
    required this.oldSoftCap,
    required this.newSoftCap,
    required this.capBoost,
    required this.benchPenaltyApplied,
  });

  final double oldRating, newRating, ratingDelta, oldSoftCap, newSoftCap, capBoost;
  final bool benchPenaltyApplied;
  bool get breakout => capBoost > 0;
}

/// Inject Random(seed: ...) in tests or saves for reproducible progression.
class ProgressionEngine {
  ProgressionEngine({Random? random}) : _random = random ?? Random();
  final Random _random;

  ProgressionResult processEndOfSeasonGrowth(
    ProgressionPlayer player, {
    required int seasonLength,
  }) {
    if (seasonLength <= 0) {
      throw ArgumentError.value(seasonLength, 'seasonLength', 'Must be positive');
    }
    if (player.matchesPlayed < 0 || player.matchesPlayed > seasonLength) {
      throw ArgumentError('matchesPlayed must be between 0 and seasonLength');
    }

    final oldRating = player.overallRating;
    final oldSoftCap = player.softCap;

    final ageDelta = player.age <= 22
        ? 3.0
        : player.age <= 28
            ? 1.0
            : player.age <= 33
                ? -0.5
                : -2.5;

    final playTimeRatio =
        (player.matchesPlayed / (seasonLength * 0.7)).clamp(0.0, 1.0);
    final formMultiplier = 0.5 + player.averageForm;
    final gapToCap = player.softCap - player.overallRating;
    final capFriction = gapToCap <= 0 ? 0.1 : gapToCap < 5 ? 0.5 : 1.0;

    var finalDelta =
        ageDelta * playTimeRatio * formMultiplier * capFriction;
    finalDelta += _random.nextDouble() - 0.5;

    final benchPenaltyApplied = player.age <= 23 && player.matchesPlayed < 3;
    if (benchPenaltyApplied) finalDelta -= 1.5;

    var capBoost = 0.0;
    if (gapToCap <= 0 && player.averageForm >= 0.85) {
      capBoost = 1.5 + _random.nextDouble();
      player.softCap = min(99.0, player.softCap + capBoost);
      capBoost = player.softCap - oldSoftCap;
    }

    player.overallRating = (player.overallRating + finalDelta).clamp(30.0, 99.0);
    final appliedDelta = player.overallRating - oldRating;
    player.age += 1;
    player.matchesPlayed = 0;
    player.averageForm = 0.5;

    return ProgressionResult(
      oldRating: oldRating,
      newRating: player.overallRating,
      ratingDelta: appliedDelta,
      oldSoftCap: oldSoftCap,
      newSoftCap: player.softCap,
      capBoost: capBoost,
      benchPenaltyApplied: benchPenaltyApplied,
    );
  }
}
