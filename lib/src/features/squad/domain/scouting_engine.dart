import 'dart:math';

/// The manager-visible estimate of a prospect's ability and potential.
/// True player attributes should be kept in the domain model and never bound
/// directly to scouting UI widgets.
class ScoutReport {
  ScoutReport({
    this.scoutLevel = 0,
    this.minOvr = 30,
    this.maxOvr = 99,
    this.minCap = 30,
    this.maxCap = 99,
  });

  int scoutLevel;
  int minOvr;
  int maxOvr;
  int minCap;
  int maxCap;

  bool get isFullyScouted => scoutLevel >= 3;

  String get displayOvr =>
      isFullyScouted ? '$minOvr' : '$minOvr - $maxOvr';

  String get displayCap =>
      isFullyScouted ? '$minCap' : '$minCap - $maxCap';
}

/// A prospect with separate private true attributes and public scout report.
///
/// The match engine should use [trueOvr] and player development should use
/// [trueCap]. Manager-facing UI should only use [report].
class ScoutedProspect {
  ScoutedProspect({
    required this.name,
    required int trueOvr,
    required int trueCap,
    Random? random,
  })  : _trueOvr = trueOvr,
        _trueCap = trueCap,
        scoutBias = (random ?? Random()).nextInt(11) - 5,
        report = ScoutReport() {
    if (trueOvr < 30 || trueOvr > 99) {
      throw ArgumentError.value(trueOvr, 'trueOvr', 'Must be 30–99');
    }
    if (trueCap < trueOvr || trueCap > 99) {
      throw ArgumentError.value(
        trueCap,
        'trueCap',
        'Must be between trueOvr and 99',
      );
    }
    ScoutingEngine.updateReport(this, 0);
  }

  final String name;
  final int _trueOvr;
  final int _trueCap;

  /// Internal scouting uncertainty; positive bias makes the report optimistic.
  int scoutBias;
  final ScoutReport report;

  /// Domain accessors for simulation/progression only; do not show in UI.
  int get trueOvr => _trueOvr;
  int get trueCap => _trueCap;
}

class ScoutingPurchaseResult {
  const ScoutingPurchaseResult({
    required this.success,
    required this.cost,
    required this.requestedLevel,
    required this.message,
  });

  final bool success;
  final int cost;
  final int requestedLevel;
  final String message;
}

/// Scouting tiers reduce uncertainty but retain bias until an exact report.
class ScoutingEngine {
  ScoutingEngine._();

  /// Costs are in thousands of franchise currency units (e.g. 10 = 10k).
  static const Map<int, int> levelCosts = {
    1: 10,
    2: 50,
    3: 150,
  };

  static const Map<int, int> errorMargins = {
    0: 15,
    1: 8,
    2: 3,
    3: 0,
  };

  static void updateReport(ScoutedProspect player, int newLevel) {
    if (newLevel < 0 || newLevel > 3) {
      throw ArgumentError.value(newLevel, 'newLevel', 'Must be 0–3');
    }
    if (newLevel <= player.report.scoutLevel) return;

    player.report.scoutLevel = newLevel;

    if (newLevel == 3) {
      player.report
        ..minOvr = player.trueOvr
        ..maxOvr = player.trueOvr
        ..minCap = player.trueCap
        ..maxCap = player.trueCap;
      return;
    }

    final errorMargin = errorMargins[newLevel]!;
    player.report
      ..minOvr = (player.trueOvr - errorMargin + player.scoutBias)
          .clamp(30, 99)
      ..maxOvr = (player.trueOvr + errorMargin + player.scoutBias)
          .clamp(30, 99)
      ..minCap = (player.trueCap - errorMargin + player.scoutBias)
          .clamp(30, 99)
      ..maxCap = (player.trueCap + errorMargin + player.scoutBias)
          .clamp(30, 99);
  }

  /// Attempts to buy a scouting report. The balance is only deducted on
  /// success. Reports cannot be downgraded or charged for a repeated level.
  static ScoutingPurchaseResult purchaseScoutReport({
    required ScoutedProspect player,
    required int budget,
    required int requestedLevel,
  }) {
    if (requestedLevel < 1 || requestedLevel > 3) {
      throw ArgumentError.value(
        requestedLevel,
        'requestedLevel',
        'Paid scouting level must be 1–3',
      );
    }
    if (budget < 0) {
      throw ArgumentError.value(budget, 'budget', 'Must not be negative');
    }

    final currentLevel = player.report.scoutLevel;
    if (requestedLevel <= currentLevel) {
      return ScoutingPurchaseResult(
        success: true,
        cost: 0,
        requestedLevel: requestedLevel,
        message: 'This report level is already available.',
      );
    }

    final cost = levelCosts[requestedLevel]!;
    if (budget < cost) {
      return ScoutingPurchaseResult(
        success: false,
        cost: cost,
        requestedLevel: requestedLevel,
        message: 'Insufficient funds for this scouting level.',
      );
    }

    updateReport(player, requestedLevel);
    return ScoutingPurchaseResult(
      success: true,
      cost: cost,
      requestedLevel: requestedLevel,
      message: 'Level $requestedLevel scouting report purchased.',
    );
  }
}
