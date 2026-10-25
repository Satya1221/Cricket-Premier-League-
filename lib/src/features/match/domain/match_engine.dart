import 'dart:math';

enum PitchType { green, dusty, flat }
enum WeatherType { sunny, overcast }
enum MatchPhase { powerplay, middleOvers, deathOvers }
enum BowlingStyle { fast, swing, leftArmOrthodox, legSpin, offSpin }
enum BattingIntent { consolidate, rotateStrike, balanced, slog }
enum FieldPreset { attacking, defensive, boundarySaving }
enum HighlightType { none, boundary, wicket, lbwAppeal, droppedCatch, tightChase }

class MatchEnvironment {
  const MatchEnvironment({
    required this.pitch, required this.weather, required this.isNightMatch,
    this.dew = 0, this.pitchWear = 0, this.oversOld = 0,
  }) : assert(dew >= 0 && dew <= 1), assert(pitchWear >= 0 && pitchWear <= 1), assert(oversOld >= 0);
  final PitchType pitch;
  final WeatherType weather;
  final bool isNightMatch;
  final double dew, pitchWear;
  final int oversOld;

  MatchEnvironment afterBall({bool completedOver = false}) => MatchEnvironment(
    pitch: pitch, weather: weather, isNightMatch: isNightMatch, dew: dew,
    pitchWear: (pitchWear + (completedOver ? 0.012 : 0.001)).clamp(0.0, 1.0),
    oversOld: oversOld + (completedOver ? 1 : 0),
  );
}

class BatterMatchState {
  const BatterMatchState({required this.skill, this.concentration = 0, this.boundariesThroughCover = 0})
      : assert(skill >= 1 && skill <= 100), assert(concentration >= 0 && concentration <= 100);
  final int skill;
  final double concentration;
  final int boundariesThroughCover;
  BatterMatchState facedBall({required bool survived}) => BatterMatchState(
    skill: skill,
    concentration: (concentration + (survived ? 6.0 : 2.0)).clamp(0.0, 100.0),
    boundariesThroughCover: boundariesThroughCover,
  );
}

class BowlerMatchState {
  const BowlerMatchState({required this.skill, required this.style, this.stamina = 100, this.consecutiveOvers = 0})
      : assert(skill >= 1 && skill <= 100), assert(stamina >= 0 && stamina <= 100), assert(consecutiveOvers >= 0);
  final int skill;
  final BowlingStyle style;
  final double stamina;
  final int consecutiveOvers;
}

class BallContext {
  const BallContext({
    required this.environment, required this.batter, required this.bowler, required this.phase,
    required this.isBatterLeftHanded, required this.intent, required this.field,
    required this.runsRequired, required this.ballsRemaining, required this.seed,
  });
  final MatchEnvironment environment;
  final BatterMatchState batter;
  final BowlerMatchState bowler;
  final MatchPhase phase;
  final bool isBatterLeftHanded;
  final BattingIntent intent;
  final FieldPreset field;
  final int runsRequired, ballsRemaining, seed;
}

class BallOutcome {
  const BallOutcome({
    required this.runs, required this.isWicket, required this.isWide, required this.isBoundary,
    required this.commentary, required this.highlight, required this.wicketProbability,
    required this.boundaryProbability, required this.nextEnvironment, required this.nextBatter,
    required this.nextBowler, required this.directorShouldShow3D,
  });
  final int runs;
  final bool isWicket, isWide, isBoundary, directorShouldShow3D;
  final String commentary;
  final HighlightType highlight;
  final double wicketProbability, boundaryProbability;
  final MatchEnvironment nextEnvironment;
  final BatterMatchState nextBatter;
  final BowlerMatchState nextBowler;
}

/// Pure seeded ball resolver; independent of UI and rendering frame rate.
class MatchEngine {
  const MatchEngine();

  BallOutcome simulateBall(BallContext c) {
    final rng = Random(c.seed);
    final e = c.environment;
    final b = c.batter;
    final w = c.bowler;
    final fast = w.style == BowlingStyle.fast || w.style == BowlingStyle.swing;
    final spin = !fast;
    var swing = 0.0;
    if (fast) {
      swing += e.oversOld < 5 ? 0.10 : max(0, 0.10 - e.oversOld * 0.004);
      if (e.weather == WeatherType.overcast) swing += 0.10;
      if (e.pitch == PitchType.green && e.oversOld < 5) swing += 0.15;
      if (e.pitchWear > 0.55 && c.phase == MatchPhase.deathOvers && e.oversOld >= 20) swing += 0.12;
    }
    final wetSpinPenalty = spin && e.isNightMatch ? e.dew * 0.24 : 0.0;
    final dustSpinBonus = spin && e.pitch == PitchType.dusty ? 0.04 + e.pitchWear * 0.20 : 0.0;
    final handBonus = w.style == BowlingStyle.leftArmOrthodox
        ? (c.isBatterLeftHanded ? -0.035 : 0.035) : 0.0;
    final staminaPenalty = fast
        ? max(0, (100 - w.stamina) / 100 * 0.10 + max(0, w.consecutiveOvers - 1) * 0.035)
        : max(0, (100 - w.stamina) / 100 * 0.04);
    final eyeIn = b.concentration >= 90 ? 0.055 : b.concentration >= 60 ? 0.025 : 0.0;
    final slogRisk = c.intent == BattingIntent.slog
        ? (b.concentration < 30 ? 0.13 : 0.055)
        : c.intent == BattingIntent.consolidate ? -0.035 : 0.0;
    final pitchChaos = e.pitch == PitchType.dusty ? e.pitchWear * 0.08 : 0.0;
    final wicketP = (0.055 + (w.skill - b.skill) * 0.0012 + swing * 0.16 +
        dustSpinBonus + handBonus + wetSpinPenalty * 0.5 + staminaPenalty +
        slogRisk + pitchChaos - eyeIn).clamp(0.015, 0.42).toDouble();
    var boundaryP = (0.12 + (b.skill - w.skill) * 0.0018 + eyeIn +
        (c.intent == BattingIntent.slog ? 0.16 : 0) - swing * 0.12 -
        dustSpinBonus * 0.35 - (c.field == FieldPreset.boundarySaving ? 0.055 : 0) -
        (c.field == FieldPreset.defensive ? 0.025 : 0) - wetSpinPenalty * 0.12)
        .clamp(0.015, 0.58).toDouble();
    if (b.boundariesThroughCover >= 2 && c.field == FieldPreset.attacking) {
      boundaryP = (boundaryP - 0.035).clamp(0.015, 0.58);
    }
    final wicket = rng.nextDouble() < wicketP;
    final wide = !wicket && rng.nextDouble() < (0.018 + staminaPenalty * 0.22);
    final boundary = !wicket && !wide && rng.nextDouble() < boundaryP;
    final runs = wicket ? 0 : wide ? 1 : boundary ? (rng.nextDouble() < 0.22 ? 6 : 4) : rng.nextInt(3);
    final highlight = wicket
        ? (rng.nextDouble() < 0.18 ? HighlightType.lbwAppeal : HighlightType.wicket)
        : boundary ? HighlightType.boundary
        : c.ballsRemaining <= 6 && c.runsRequired > 0 &&
          c.runsRequired <= c.ballsRemaining * 2 && (runs >= 4 || c.ballsRemaining <= 2)
          ? HighlightType.tightChase : HighlightType.none;
    final commentary = wicket ? 'OUT! The bowler wins the contest.'
        : wide ? 'Wide down the line. Extra run.'
        : runs == 6 ? 'SIX! Launched into the stands.'
        : runs == 4 ? 'FOUR! Split the field with precision.'
        : runs == 0 ? 'Beaten. A valuable dot ball.'
        : 'Runs added; the fielders close in.';
    return BallOutcome(
      runs: runs, isWicket: wicket, isWide: wide, isBoundary: boundary,
      commentary: commentary, highlight: highlight, wicketProbability: wicketP,
      boundaryProbability: boundaryP, nextEnvironment: e.afterBall(),
      nextBatter: b.facedBall(survived: !wicket),
      nextBowler: BowlerMatchState(
        skill: w.skill, style: w.style,
        stamina: (w.stamina - (fast ? 1.8 : 0.9)).clamp(0.0, 100.0),
        consecutiveOvers: w.consecutiveOvers,
      ),
      directorShouldShow3D: highlight != HighlightType.none,
    );
  }
}
