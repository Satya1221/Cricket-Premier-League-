import 'dart:math';

import 'living_pitch.dart';

enum DeliveryOutcomeType { wicket, dot, one, two, four, six }

class ResolutionBowler {
  ResolutionBowler({
    required this.name,
    required this.baseAccuracy,
    required this.baseMovement,
    required this.isSpinner,
    this.stamina = 1.0,
  }) : assert(baseAccuracy >= 1 && baseAccuracy <= 100),
       assert(baseMovement >= 1 && baseMovement <= 100),
       assert(stamina >= 0.5 && stamina <= 1.0);

  final String name;
  final double baseAccuracy;
  final double baseMovement;
  final bool isSpinner;
  double stamina;

  void recoverOrTireAfterBall() {
    stamina = max(0.5, stamina - 0.005);
  }
}

class ResolutionBatter {
  ResolutionBatter({
    required this.name,
    required this.baseTiming,
    required this.baseDefense,
    this.concentration = 0.4,
  }) : assert(baseTiming >= 1 && baseTiming <= 100),
       assert(baseDefense >= 1 && baseDefense <= 100),
       assert(concentration >= 0.4 && concentration <= 1.0);

  final String name;
  final double baseTiming;
  final double baseDefense;
  double concentration;

  void settleAfterSurvivingBall() {
    concentration = min(1.0, concentration + 0.03);
  }
}

class DeliveryResolution {
  const DeliveryResolution({
    required this.outcome,
    required this.commentary,
    required this.bowlerThreat,
    required this.batterControl,
    required this.advantage,
    required this.roll,
    required this.pitchModifiers,
  });

  final DeliveryOutcomeType outcome;
  final String commentary;
  final double bowlerThreat;
  final double batterControl;
  final double advantage;
  final double roll;
  final Map<String, double> pitchModifiers;
}

/// Resolves a delivery using environment-adjusted bowler threat versus
/// concentration-adjusted batter control. Inject a seeded Random for replayable
/// simulations and tests. No Flutter dependencies.
class DeliveryResolutionEngine {
  DeliveryResolutionEngine({
    Random? random,
    this.rollShiftScale = 0.5,
  }) : _random = random ?? Random(), assert(rollShiftScale >= 0);

  final Random _random;
  final double rollShiftScale;

  DeliveryResolution resolve({
    required MatchEnvironment environment,
    required ResolutionBowler bowler,
    required ResolutionBatter batter,
    double captaincyBonus = 0,
    double pressureMultiplier = 1,
    bool batterSurvived = true,
  }) {
    assert(pressureMultiplier >= 0 && pressureMultiplier <= 1.5);
    final modifiers = environment.getDeliveryModifiers();
    final pitchModifier = bowler.isSpinner ? modifiers['spin']! : modifiers['swing']!;
    final deliveryThreat =
        ((bowler.baseAccuracy * 0.4) +
            (bowler.baseMovement * 0.6 * pitchModifier)) *
        bowler.stamina;
    final batterControl =
        ((batter.baseDefense * 0.6) + (batter.baseTiming * 0.4)) *
        batter.concentration *
        pressureMultiplier +
        captaincyBonus;
    final advantage = batterControl - deliveryThreat;
    final roll = _random.nextDouble() * 100 + advantage * rollShiftScale;

    // Thresholds are intentionally centralized for balance tuning.
    final outcome = roll < 10
        ? DeliveryOutcomeType.wicket
        : roll < 35
            ? DeliveryOutcomeType.dot
            : roll < 60
                ? DeliveryOutcomeType.one
                : roll < 75
                    ? DeliveryOutcomeType.two
                    : roll < 90
                        ? DeliveryOutcomeType.four
                        : DeliveryOutcomeType.six;
    final commentary = switch (outcome) {
      DeliveryOutcomeType.wicket => 'WICKET! Edged and taken.',
      DeliveryOutcomeType.dot => 'Dot ball. Beaten by the movement.',
      DeliveryOutcomeType.one => '1 run. Worked into the gaps.',
      DeliveryOutcomeType.two => '2 runs. Excellent running.',
      DeliveryOutcomeType.four => 'FOUR! Beautifully timed.',
      DeliveryOutcomeType.six => 'SIX! Smashed over the ropes!',
    };

    bowler.recoverOrTireAfterBall();
    if (batterSurvived && outcome != DeliveryOutcomeType.wicket) {
      batter.settleAfterSurvivingBall();
    }

    return DeliveryResolution(
      outcome: outcome,
      commentary: commentary,
      bowlerThreat: deliveryThreat,
      batterControl: batterControl,
      advantage: advantage,
      roll: roll,
      pitchModifiers: Map.unmodifiable(modifiers),
    );
  }
}

void main() {
  final environment = MatchEnvironment(pitchType: PitchType.dusty, weather: Weather.sunny);
  final bowler = ResolutionBowler(
    name: 'Demo Spinner',
    baseAccuracy: 90,
    baseMovement: 95,
    isSpinner: true,
  );
  final batter = ResolutionBatter(name: 'Rookie Batter', baseTiming: 60, baseDefense: 70);
  final engine = DeliveryResolutionEngine();

  print('--- Over Starts ---');
  for (var ball = 1; ball <= 6; ball++) {
    final result = engine.resolve(
      environment: environment,
      bowler: bowler,
      batter: batter,
    );
    print('Ball $ball: ${result.commentary}');
    print('  [Debug] Threat: ${result.bowlerThreat.toStringAsFixed(1)}'
        ' | Control: ${result.batterControl.toStringAsFixed(1)}'
        ' | Focus: ${(batter.concentration * 100).toInt()}%'
        ' | Stamina: ${(bowler.stamina * 100).toInt()}%');
  }
}
