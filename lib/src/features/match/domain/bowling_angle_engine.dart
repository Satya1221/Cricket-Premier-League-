import 'dart:math';

enum BowlingArm { rightArm, leftArm }
enum BowlingStyleCode { fast, medium, offSpin, legSpin }
enum CreasePosition { overTheWicket, roundTheWicket }
enum BatterStance { rightHanded, leftHanded }
enum BowlingLine { outsideOff, offStump, middleStump, legStump, outsideLeg }
enum BowlingLength { yorker, full, goodLength, short, bouncer }
enum BowlingVariation { stock, outswinger, inswinger, cutter, slowerBall, googly, armBall, doosra }

class CreaseTactics {
  const CreaseTactics({required this.position, required this.arm, required this.style});
  final CreasePosition position;
  final BowlingArm arm;
  final BowlingStyleCode style;

  Map<String, double> resolveAngleGeometry({required BatterStance batterStance}) {
    var lbw = 1.0, wide = 1.0, edge = 1.0, stumping = 1.0;
    final oppositeHand = (arm == BowlingArm.rightArm && batterStance == BatterStance.leftHanded) ||
        (arm == BowlingArm.leftArm && batterStance == BatterStance.rightHanded);
    if (position == CreasePosition.roundTheWicket) {
      if (oppositeHand) {
        lbw = 1.45;
        edge = 1.3;
        wide = 0.8;
        stumping = style == BowlingStyleCode.offSpin || style == BowlingStyleCode.legSpin ? 1.2 : 1.0;
      } else {
        lbw = 0.8;
        wide = 1.4;
        edge = 1.05;
        stumping = 1.1;
      }
    }
    // Spin match-ups add turn-direction effects rather than treating all spin alike.
    if (style == BowlingStyleCode.offSpin && batterStance == BatterStance.rightHanded) {
      if (position == CreasePosition.overTheWicket) edge *= 1.12;
      else { lbw *= 1.12; stumping *= 1.08; }
    } else if (style == BowlingStyleCode.legSpin && batterStance == BatterStance.leftHanded) {
      if (position == CreasePosition.roundTheWicket) { edge *= 1.18; stumping *= 1.1; }
    }
    return {
      'lbwMultiplier': lbw.clamp(0.5, 1.8).toDouble(),
      'edgeProbability': edge.clamp(0.5, 1.8).toDouble(),
      'wideLineDanger': wide.clamp(0.5, 1.8).toDouble(),
      'stumpingMultiplier': stumping.clamp(0.5, 1.8).toDouble(),
    };
  }
}

class BowlingDeliveryProfile {
  const BowlingDeliveryProfile({
    required this.crease,
    required this.line,
    required this.length,
    this.variation = BowlingVariation.stock,
    this.fieldTrap = FieldTrap.none,
  });
  final CreaseTactics crease;
  final BowlingLine line;
  final BowlingLength length;
  final BowlingVariation variation;
  final FieldTrap fieldTrap;

  Map<String, double> resolve({required BatterStance batterStance, double batterTechnique = 60, double batterVsSpin = 60, double bowlerControl = 60}) {
    final geometry = crease.resolveAngleGeometry(batterStance: batterStance);
    var wicket = 1.0, edge = geometry['edgeProbability']!, wide = geometry['wideLineDanger']!;
    var dot = 1.0, boundary = 1.0;
    switch (line) {
      case BowlingLine.outsideOff:
        edge *= 1.15; wide *= 1.1; break;
      case BowlingLine.offStump:
        wicket *= 1.08; edge *= 1.08; break;
      case BowlingLine.middleStump:
        wicket *= 1.12; boundary *= 0.95; break;
      case BowlingLine.legStump:
        wicket *= 0.92; boundary *= 1.05; break;
      case BowlingLine.outsideLeg:
        wicket *= 0.78; wide *= 1.3; break;
    }
    switch (length) {
      case BowlingLength.yorker:
        wicket *= 1.22; boundary *= 0.8; dot *= 1.12; break;
      case BowlingLength.full:
        wicket *= 1.08; boundary *= 1.08; break;
      case BowlingLength.goodLength:
        wicket *= 1.12; edge *= 1.08; dot *= 1.08; break;
      case BowlingLength.short:
        boundary *= 1.12; edge *= 0.95; break;
      case BowlingLength.bouncer:
        wicket *= 1.05; boundary *= 1.15; edge *= 1.04; break;
    }
    switch (variation) {
      case BowlingVariation.stock: break;
      case BowlingVariation.outswinger:
        edge *= 1.22; wicket *= 1.04; break;
      case BowlingVariation.inswinger:
        wicket *= 1.15; edge *= 0.94; break;
      case BowlingVariation.cutter:
        dot *= 1.12; boundary *= 0.9; break;
      case BowlingVariation.slowerBall:
        dot *= 1.08; boundary *= 0.92; break;
      case BowlingVariation.googly:
        wicket *= crease.style == BowlingStyleCode.legSpin ? 1.2 : 1.0; edge *= 1.05; break;
      case BowlingVariation.armBall:
        wicket *= crease.style == BowlingStyleCode.offSpin ? 1.16 : 1.0; break;
      case BowlingVariation.doosra:
        wicket *= crease.style == BowlingStyleCode.offSpin ? 1.18 : 1.0; break;
    }
    if (crease.style == BowlingStyleCode.offSpin || crease.style == BowlingStyleCode.legSpin) {
      final matchup = (70 / max(25, batterVsSpin)).clamp(0.75, 1.5);
      wicket *= matchup;
      dot *= matchup;
    } else {
      final techniqueFactor = (70 / max(25, batterTechnique)).clamp(0.75, 1.5);
      wicket *= techniqueFactor;
      edge *= techniqueFactor;
    }
    final controlFactor = (70 / max(25, bowlerControl)).clamp(0.7, 1.5);
    wide *= controlFactor;
    final trap = fieldTrap.resolve();
    edge *= trap['edge']!;
    wicket *= trap['wicket']!;
    dot *= trap['dot']!;
    boundary *= trap['boundary']!;
    return {
      'lbwMultiplier': (geometry['lbwMultiplier']! * wicket).clamp(0.4, 2.2).toDouble(),
      'edgeProbability': edge.clamp(0.4, 2.2).toDouble(),
      'wideLineDanger': wide.clamp(0.4, 2.2).toDouble(),
      'stumpingMultiplier': (geometry['stumpingMultiplier']! * wicket).clamp(0.4, 2.2).toDouble(),
      'dotBallMultiplier': dot.clamp(0.5, 2.0).toDouble(),
      'boundaryMultiplier': boundary.clamp(0.5, 1.6).toDouble(),
    };
  }
}

enum FieldTrap { none, packedOffSide, legSideSqueeze, shortBallTrap, spinCloseCatchers }

extension FieldTrapResolution on FieldTrap {
  Map<String, double> resolve() => switch (this) {
    FieldTrap.none => {'edge': 1, 'wicket': 1, 'dot': 1, 'boundary': 1},
    FieldTrap.packedOffSide => {'edge': 1.2, 'wicket': 1.06, 'dot': 1.18, 'boundary': 0.88},
    FieldTrap.legSideSqueeze => {'edge': 1.04, 'wicket': 1.12, 'dot': 1.15, 'boundary': 0.9},
    FieldTrap.shortBallTrap => {'edge': 1.1, 'wicket': 1.12, 'dot': 1.02, 'boundary': 0.96},
    FieldTrap.spinCloseCatchers => {'edge': 1.18, 'wicket': 1.12, 'dot': 1.08, 'boundary': 0.9},
  };
}

/// Converts tactical multipliers into bounded delivery-engine inputs.
/// Outcome categories are still probabilistic; multipliers are not guaranteed wickets.
class BowlingAngleEngine {
  const BowlingAngleEngine();

  Map<String, double> resolveOutcomeModifiers({
    required BowlingDeliveryProfile profile,
    required BatterStance batterStance,
    double batterTechnique = 60,
    double batterVsSpin = 60,
    double bowlerControl = 60,
  }) => profile.resolve(
    batterStance: batterStance,
    batterTechnique: batterTechnique,
    batterVsSpin: batterVsSpin,
    bowlerControl: bowlerControl,
  );
}
