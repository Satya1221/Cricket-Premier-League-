import 'package:flutter_test/flutter_test.dart';
import 'package:cricket_premier_league/src/features/match/domain/match_engine.dart';

void main() {
  const engine = MatchEngine();
  BallContext makeContext({
    int seed = 42, PitchType pitch = PitchType.green, WeatherType weather = WeatherType.overcast,
    BowlingStyle style = BowlingStyle.fast, double stamina = 100, int consecutiveOvers = 0,
    double concentration = 0, BattingIntent intent = BattingIntent.balanced,
    FieldPreset field = FieldPreset.attacking, double dew = 0, int oversOld = 0,
    double pitchWear = 0, bool leftHanded = false,
  }) => BallContext(
    environment: MatchEnvironment(pitch: pitch, weather: weather, isNightMatch: dew > 0,
      dew: dew, pitchWear: pitchWear, oversOld: oversOld),
    batter: BatterMatchState(skill: 75, concentration: concentration),
    bowler: BowlerMatchState(skill: 78, style: style, stamina: stamina, consecutiveOvers: consecutiveOvers),
    phase: MatchPhase.deathOvers, isBatterLeftHanded: leftHanded, intent: intent,
    field: field, runsRequired: 10, ballsRemaining: 6, seed: seed,
  );

  test('same seed reproduces outcome', () {
    final a = engine.simulateBall(makeContext(seed: 9));
    final b = engine.simulateBall(makeContext(seed: 9));
    expect(a.runs, b.runs);
    expect(a.isWicket, b.isWicket);
    expect(a.commentary, b.commentary);
  });
  test('probabilities remain bounded under extreme conditions', () {
    final o = engine.simulateBall(makeContext(pitch: PitchType.dusty, pitchWear: 1,
      stamina: 0, consecutiveOvers: 5, intent: BattingIntent.slog, dew: 1));
    expect(o.wicketProbability, inInclusiveRange(0.015, 0.42));
    expect(o.boundaryProbability, inInclusiveRange(0.015, 0.58));
  });
  test('low concentration slog increases wicket risk', () {
    final safe = engine.simulateBall(makeContext(concentration: 80));
    final risky = engine.simulateBall(makeContext(concentration: 0, intent: BattingIntent.slog));
    expect(risky.wicketProbability, greaterThan(safe.wicketProbability));
  });
  test('3D director activates only for highlight events', () {
    final o = engine.simulateBall(makeContext(seed: 5));
    expect(o.directorShouldShow3D, o.highlight != HighlightType.none);
  });
  test('ball aging advances only after a completed over', () {
    const e = MatchEnvironment(pitch: PitchType.dusty, weather: WeatherType.sunny, isNightMatch: false);
    expect(e.afterBall().oversOld, 0);
    expect(e.afterBall(completedOver: true).oversOld, 1);
  });
}
