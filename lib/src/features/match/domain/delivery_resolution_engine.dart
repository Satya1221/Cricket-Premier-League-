import 'dart:math';

import 'living_pitch.dart';
import 'granular_player_profile.dart';

enum DeliveryOutcomeType { wicket, dot, one, two, four, six }
enum BatterIntent { defend, rotate, slog }
enum BowlerTactic { attack, contain, balanced }

class ResolutionBowler {
  ResolutionBowler({
    required this.name,
    required this.baseAccuracy,
    required this.baseMovement,
    required this.isSpinner,
    this.stamina = 1.0,
    this.attributes,
    this.condition,
  }) : assert(baseAccuracy >= 1 && baseAccuracy <= 100),
       assert(baseMovement >= 1 && baseMovement <= 100),
       assert(stamina >= 0.5 && stamina <= 1.0);

  final String name;
  final double baseAccuracy;
  final double baseMovement;
  final bool isSpinner;
  final BowlingStats? attributes;
  final PlayerCondition? condition;
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
    this.attributes,
    this.condition,
    this.traits,
  }) : assert(baseTiming >= 1 && baseTiming <= 100),
       assert(baseDefense >= 1 && baseDefense <= 100),
       assert(concentration >= 0.4 && concentration <= 1.0);

  final String name;
  final double baseTiming;
  final double baseDefense;
  final BattingStats? attributes;
  final PlayerCondition? condition;
  final PlayerTraits? traits;
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
    required this.intent,
    required this.tactic,
    required this.thresholds,
  });

  final DeliveryOutcomeType outcome;
  final String commentary;
  final double bowlerThreat;
  final double batterControl;
  final double advantage;
  final double roll;
  final Map<String, double> pitchModifiers;
  final BatterIntent intent;
  final BowlerTactic tactic;
  final Map<String, double> thresholds;
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
    BatterIntent intent = BatterIntent.rotate,
    BowlerTactic tactic = BowlerTactic.balanced,
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

    // Tactics reshape the outcome bands, not the players' underlying skills.
    // Clamp thresholds into a monotonic sequence to avoid impossible bands.
    var wicketChance = 10.0;
    var dotChance = 35.0;
    var oneTwoChance = 75.0;
    var fourChance = 90.0;
    switch (intent) {
      case BatterIntent.defend:
        wicketChance -= 6;
        dotChance += 30;
        oneTwoChance += 5;
        fourChance += 10;
        break;
      case BatterIntent.rotate:
        dotChance -= 10;
        break;
      case BatterIntent.slog:
        wicketChance += 15;
        dotChance -= 15;
        oneTwoChance -= 15;
        fourChance -= 20;
        break;
    }
    switch (tactic) {
      case BowlerTactic.attack:
        wicketChance += 5;
        fourChance -= 10;
        break;
      case BowlerTactic.contain:
        wicketChance -= 5;
        fourChance += 15;
        dotChance += 10;
        break;
      case BowlerTactic.balanced:
        break;
    }
    wicketChance = wicketChance.clamp(0.0, 35.0);
    dotChance = dotChance.clamp(wicketChance, 70.0);
    oneTwoChance = oneTwoChance.clamp(dotChance, 85.0);
    fourChance = fourChance.clamp(oneTwoChance, 99.0);
    final thresholds = <String, double>{
      'wicket': wicketChance,
      'dot': dotChance,
      'oneTwo': oneTwoChance,
      'four': fourChance,
    };
    final outcome = roll <= wicketChance
        ? DeliveryOutcomeType.wicket
        : roll <= dotChance
            ? DeliveryOutcomeType.dot
            : roll <= oneTwoChance
                ? (_random.nextBool() ? DeliveryOutcomeType.one : DeliveryOutcomeType.two)
                : roll <= fourChance
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
      intent: intent,
      tactic: tactic,
      thresholds: Map.unmodifiable(thresholds),
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
