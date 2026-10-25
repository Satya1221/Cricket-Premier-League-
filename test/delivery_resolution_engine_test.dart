import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:cricket_premier_league/src/features/match/domain/living_pitch.dart';
import 'package:cricket_premier_league/src/features/match/domain/delivery_resolution_engine.dart';

void main() {
  MatchEnvironment environment() =>
      MatchEnvironment(pitchType: PitchType.dusty, weather: Weather.sunny);

  test('resolution is reproducible with a seeded random generator', () {
    final a = DeliveryResolutionEngine(random: Random(7)).resolve(
      environment: environment(),
      bowler: ResolutionBowler(name: 'Bowler', baseAccuracy: 80, baseMovement: 85, isSpinner: true),
      batter: ResolutionBatter(name: 'Batter', baseTiming: 70, baseDefense: 72),
    );
    final b = DeliveryResolutionEngine(random: Random(7)).resolve(
      environment: environment(),
      bowler: ResolutionBowler(name: 'Bowler', baseAccuracy: 80, baseMovement: 85, isSpinner: true),
      batter: ResolutionBatter(name: 'Batter', baseTiming: 70, baseDefense: 72),
    );
    expect(a.outcome, b.outcome);
    expect(a.roll, b.roll);
    expect(a.pitchModifiers['spin'], b.pitchModifiers['spin']);
  });

  test('bowler tires after a delivery and surviving batter gains focus', () {
    final bowler = ResolutionBowler(name: 'Bowler', baseAccuracy: 80, baseMovement: 80, isSpinner: false);
    final batter = ResolutionBatter(name: 'Batter', baseTiming: 70, baseDefense: 70);
    DeliveryResolutionEngine(random: Random(2)).resolve(
      environment: environment(), bowler: bowler, batter: batter,
    );
    expect(bowler.stamina, 0.995);
    expect(batter.concentration, greaterThanOrEqualTo(0.4));
    expect(batter.concentration, lessThanOrEqualTo(1.0));
  });

  test('slog plus attack widens wicket and six outcome bands', () {
    final result = DeliveryResolutionEngine(random: Random(1)).resolve(
      environment: environment(),
      bowler: ResolutionBowler(name: 'Bowler', baseAccuracy: 70, baseMovement: 70, isSpinner: false),
      batter: ResolutionBatter(name: 'Batter', baseTiming: 70, baseDefense: 70, concentration: 1),
      intent: BatterIntent.slog,
      tactic: BowlerTactic.attack,
    );
    expect(result.thresholds['wicket'], closeTo(21, 0.01));
    expect(result.thresholds['four'], closeTo(64, 0.01));
  });

  test('contain tactic protects boundaries and reduces wicket threshold', () {
    final result = DeliveryResolutionEngine(random: Random(1)).resolve(
      environment: environment(),
      bowler: ResolutionBowler(name: 'Bowler', baseAccuracy: 70, baseMovement: 70, isSpinner: false),
      batter: ResolutionBatter(name: 'Batter', baseTiming: 70, baseDefense: 70, concentration: 1),
      intent: BatterIntent.rotate,
      tactic: BowlerTactic.contain,
    );
    expect(result.thresholds['wicket'], closeTo(2.4, 0.01));
    expect(result.thresholds['four'], 99);
    expect(result.thresholds['dot'], greaterThan(25));
  });

  test('concentration and pitch modifiers affect the debug calculations', () {
    final result = DeliveryResolutionEngine(random: Random(1)).resolve(
      environment: environment(),
      bowler: ResolutionBowler(name: 'Spinner', baseAccuracy: 90, baseMovement: 90, isSpinner: true),
      batter: ResolutionBatter(name: 'New Batter', baseTiming: 60, baseDefense: 60),
    );
    expect(result.bowlerThreat, greaterThan(0));
    expect(result.batterControl, greaterThan(0));
    expect(result.roll.isFinite, isTrue);
  });
}
