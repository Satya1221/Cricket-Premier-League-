import 'dart:math';

import 'living_pitch.dart';
import '../../squad/domain/granular_player_profile.dart';

enum DeliveryOutcomeType { wicket, dot, one, two, four, six }
enum DismissalType { bowled, caught, lbw, stumped, runOut }
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
    stamina = max(0.0, stamina - 0.005);
  }

  /// Additional over-end workload drain; a 0.08 drop is applied per completed over.
  void settleOver() { stamina = max(0.0, stamina - 0.08); }
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
    this.dismissal,
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
  final DismissalType? dismissal;
}

/// Resolves a delivery using environment-adjusted bowler threat versus
/// concentration-adjusted batter control. Inject a seeded Random for replayable
/// simulations and tests. No Flutter dependencies.
class DeliveryResolutionEngine {
  DeliveryResolutionEngine({
    Random? random,
    this.rollShiftScale = 0.12,
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
    Map<String, double> tacticalModifiers = const {},
    Map<int, int> fieldersByZone = const {},
    Map<int, int>? fieldingForm,
  }) {
    assert(pressureMultiplier >= 0 && pressureMultiplier <= 1.5);
    final modifiers = environment.getDeliveryModifiers();
    final pitchModifier = bowler.isSpinner
        ? modifiers['spin']!
        : (modifiers['swing']! * 0.55 + (modifiers['seam'] ?? 1.0) * 0.45);
    final attributeControl = bowler.isSpinner
        ? (batter.attributes?.vs ?? batter.baseDefense)
        : (batter.attributes?.tec ?? batter.baseDefense);
    final movementSkill = bowler.attributes?.varStat ?? bowler.baseMovement;
    final deliveryThreat =
        ((bowler.baseAccuracy * 0.4) +
            (movementSkill * 0.6 * pitchModifier)) *
        bowler.stamina;
    final batterControl =
        ((attributeControl * 0.6) + (batter.baseTiming * 0.4)) *
        batter.concentration *
        pressureMultiplier +
        captaincyBonus;
    final advantage = batterControl - deliveryThreat;
    // The skill gap nudges the roll but is bounded, so a big mismatch can no
    // longer swamp the outcome bands (this was the main cause of the
    // "7 wickets in 2 overs" bug).
    final roll = (_random.nextDouble() * 100 + advantage.clamp(-30.0, 30.0).toDouble() * rollShiftScale).clamp(0.0, 100.0).toDouble();

    // Tactics reshape the outcome bands, not the players' underlying skills.
    // Clamp thresholds into a monotonic sequence to avoid impossible bands.
    // Intent-specific outcome weights. Wicket risk is a multiplier of the
    // 6% base; remaining outcomes are sampled from intent-specific weights.
    final wicketMultiplier = switch (intent) {
      BatterIntent.defend => 0.15,
      BatterIntent.rotate => 0.40,
      BatterIntent.slog => 2.50,
    };
    var wicketChance = 6.0 * wicketMultiplier;
    var dotWeight = switch (intent) {
      BatterIntent.defend => 75.0,
      BatterIntent.rotate => 30.0,
      BatterIntent.slog => 25.0,
    };
    var boundaryWeight = switch (intent) {
      BatterIntent.defend => 2.0,
      BatterIntent.rotate => 8.0,
      BatterIntent.slog => 45.0,
    };
    var singleDoubleWeight = switch (intent) {
      BatterIntent.defend => 23.0,
      BatterIntent.rotate => 62.0,
      BatterIntent.slog => 30.0,
    };
    final boundaryFactor = (modifiers['boundary'] ?? 1.0).clamp(0.75, 1.25);
    boundaryWeight *= boundaryFactor;
    wicketChance += (modifiers['irregularBounceRisk'] ?? 0.0) * 12;
    final wicketModifier = ((tacticalModifiers['lbwMultiplier'] ?? 1.0) +
      (tacticalModifiers['stumpingMultiplier'] ?? 1.0) +
      (tacticalModifiers['edgeProbability'] ?? 1.0)) / 3;
    wicketChance *= wicketModifier.clamp(0.5, 2.0);
    switch (tactic) {
      case BowlerTactic.attack:
        wicketChance *= 1.4;
        boundaryWeight *= 0.9;
        break;
      case BowlerTactic.contain:
        wicketChance *= 0.8;
        dotWeight += 8;
        boundaryWeight *= 0.8;
        break;
      case BowlerTactic.balanced:
        break;
    }
    // Below 40% stamina, bad deliveries become 1.5x more likely to leak
    // boundaries. The same effect is applied to the boundary weight.
    if (bowler.stamina < 0.4) boundaryWeight *= 1.5;
    wicketChance = wicketChance.clamp(0.0, intent == BatterIntent.slog ? 18.0 : 8.0);
    dotWeight *= (tacticalModifiers['dotBallMultiplier'] ?? 1.0);
    boundaryWeight *= (tacticalModifiers['boundaryMultiplier'] ?? 1.0);
    final weightTotal = dotWeight + singleDoubleWeight + boundaryWeight;
    final available = 100.0 - wicketChance;
    final dotChance = wicketChance + available * dotWeight / weightTotal;
    final oneTwoChance = dotChance + available * singleDoubleWeight / weightTotal;
    final fourChance = 100.0;

    final thresholds = <String, double>{
      'wicket': wicketChance,
      'dot': dotChance,
      'oneTwo': oneTwoChance,
      'four': fourChance,
    };
    var outcome = roll <= wicketChance
        ? DeliveryOutcomeType.wicket
        : roll <= dotChance
            ? DeliveryOutcomeType.dot
            : roll <= oneTwoChance
                ? (_random.nextBool() ? DeliveryOutcomeType.one : DeliveryOutcomeType.two)
                : (_random.nextBool() ? DeliveryOutcomeType.four : DeliveryOutcomeType.six);
    DismissalType? dismissal;
    if (intent == BatterIntent.slog &&
        (outcome == DeliveryOutcomeType.four || outcome == DeliveryOutcomeType.six)) {
      // Lofted shots select one of eight directional zones. A stationed fielder
      // can turn the boundary into a caught wicket; a drop penalizes their form.
      final zone = _random.nextInt(8) + 1;
      final fielderSkill = fieldersByZone[zone];
      if (fielderSkill != null) {
        final catchChance = 0.15 + fielderSkill.clamp(0, 100) / 100 * 0.55;
        if (_random.nextDouble() < catchChance) {
          outcome = DeliveryOutcomeType.wicket;
          dismissal = DismissalType.caught;
        } else if (fieldingForm != null) {
          fieldingForm[zone] = (fieldingForm[zone] ?? 100) - 1;
        }
      }
    }
    if (outcome == DeliveryOutcomeType.wicket && dismissal == null) {
      // The current match engine does not model a full ball trajectory. Select a
      // plausible dismissal subtype using the tactical profile as a weighted cue.
      final lbwWeight = (tacticalModifiers['lbwMultiplier'] ?? 1.0).clamp(0.1, 2.2);
      final edgeWeight = (tacticalModifiers['edgeProbability'] ?? 1.0).clamp(0.1, 2.2);
      final stumpWeight = (tacticalModifiers['stumpingMultiplier'] ?? 1.0).clamp(0.1, 2.2);
      final total = lbwWeight + edgeWeight + stumpWeight + 1.0;
      final dismissalRoll = _random.nextDouble() * total;
      if (dismissalRoll < lbwWeight) {
        dismissal = DismissalType.lbw;
      } else if (dismissalRoll < lbwWeight + edgeWeight) {
        dismissal = DismissalType.caught;
      } else if (dismissalRoll < lbwWeight + edgeWeight + stumpWeight) {
        dismissal = DismissalType.stumped;
      } else {
        dismissal = DismissalType.bowled;
      }
    }
    final commentary = switch (outcome) {
      DeliveryOutcomeType.wicket => switch (dismissal!) {
        DismissalType.bowled => 'WICKET! Bowled through the gate.',
        DismissalType.caught => 'WICKET! Outside edge and taken by the keeper/slip.',
        DismissalType.lbw => 'WICKET! Trapped in front — LBW.',
        DismissalType.stumped => 'WICKET! Beaten in flight and stumped.',
        DismissalType.runOut => 'WICKET! Run out attempting a quick single.',
      },
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
      dismissal: dismissal,
    );
  }
}
