import 'dart:math';

/// The semantic result of one delivery, independent of Flutter or a 3D renderer.
class DeliveryEvent {
  const DeliveryEvent({
    required this.ballNumber,
    required this.outcomeText,
    required this.isWicket,
    required this.runs,
    this.isHighlight = false,
    this.highlightType = HighlightType.none,
    this.batterRuns = 0,
    this.extras = 0,
    this.isLegalDelivery = true,
  }) : assert(ballNumber > 0),
       assert(runs >= 0),
       assert(batterRuns >= 0),
       assert(extras >= 0);

  /// Absolute ball index in the innings; legal-ball over notation is separate.
  final int ballNumber;
  final String outcomeText;
  final bool isWicket;
  final int runs;
  final bool isHighlight;
  final HighlightType highlightType;
  final int batterRuns;
  final int extras;
  final bool isLegalDelivery;
}

enum HighlightType { none, wicket, boundary, milestone, pressure, lastBall }

class MatchDirector {
  MatchDirector({Random? random}) : _random = random ?? Random();

  final Random _random;

  /// Generates a deterministic, lightweight over event list when [seed] is set.
  /// [startingBall] is the number of legal balls already bowled in the innings.
  List<DeliveryEvent> preCalculateOver({
    required int startingBall,
    int? seed,
    int wickets = 0,
    int totalRuns = 0,
    int target = 0,
    int batterRuns = 0,
    int ballsRemainingInInnings = 120,
  }) {
    final rng = seed == null ? _random : Random(seed);
    final events = <DeliveryEvent>[];
    var legalBalls = 0;
    var score = totalRuns;
    var batterScore = batterRuns;

    while (legalBalls < 6 && legalBalls < ballsRemainingInInnings) {
      final roll = rng.nextInt(100);
      late final int batterRunsThisBall;
      late final int extras;
      late final bool wicket;
      late final String text;

      if (roll < 5) {
        batterRunsThisBall = 0;
        extras = 0;
        wicket = true;
        text = 'WICKET! The batter is dismissed.';
      } else if (roll < 35) {
        batterRunsThisBall = 0;
        extras = 0;
        wicket = false;
        text = 'Dot ball. Solid defense.';
      } else if (roll < 65) {
        batterRunsThisBall = 1;
        extras = 0;
        wicket = false;
        text = '1 run. Tapped into the field.';
      } else if (roll < 75) {
        batterRunsThisBall = 2;
        extras = 0;
        wicket = false;
        text = '2 runs. Excellent running.';
      } else if (roll < 90) {
        batterRunsThisBall = 4;
        extras = 0;
        wicket = false;
        text = 'FOUR! Driven to the boundary.';
      } else {
        batterRunsThisBall = 6;
        extras = 0;
        wicket = false;
        text = 'SIX! Launched over the boundary.';
      }

      legalBalls++;
      score += batterRunsThisBall + extras;
      batterScore += batterRunsThisBall;

      final absoluteBall = startingBall + legalBalls;
      final lastBallOfOver = legalBalls == 6;
      final lastBallOfInnings = legalBalls >= ballsRemainingInInnings;
      final chaseTight = target > 0 &&
          lastBallOfInnings &&
          score < target &&
          target - score <= 6;

      var highlightType = HighlightType.none;
      if (wicket) {
        highlightType = HighlightType.wicket;
      } else if (chaseTight && lastBallOfInnings) {
        highlightType = HighlightType.pressure;
      } else if (lastBallOfInnings && lastBallOfOver) {
        highlightType = HighlightType.lastBall;
      } else if ((batterRunsThisBall == 4 || batterRunsThisBall == 6) &&
          batterScore > 0 && batterScore % 50 < 7) {
        highlightType = HighlightType.milestone;
      } else if (batterRunsThisBall == 4 || batterRunsThisBall == 6) {
        highlightType = HighlightType.boundary;
      }

      final finalText = chaseTight && batterRunsThisBall == 0
          ? 'Dot ball! The chase goes down to the wire!'
          : text;
      events.add(DeliveryEvent(
        ballNumber: absoluteBall,
        outcomeText: finalText,
        isWicket: wicket,
        runs: batterRunsThisBall + extras,
        batterRuns: batterRunsThisBall,
        extras: extras,
        isLegalDelivery: true,
        isHighlight: highlightType != HighlightType.none,
        highlightType: highlightType,
      ));
    }
    return List.unmodifiable(events);
  }
}

/// Playback callbacks let Flutter update score text and ask its 3D scene to
/// animate highlights without putting rendering dependencies in the engine.
class HighlightPlayback {
  const HighlightPlayback({
    this.onDelivery,
    this.onHighlightStart,
    this.onHighlightEnd,
    this.onOverComplete,
    this.fastForwardDelay = const Duration(milliseconds: 400),
    this.highlightDelay = const Duration(milliseconds: 1500),
    this.cooldownDelay = const Duration(milliseconds: 1000),
  });

  final Future<void> Function(DeliveryEvent event)? onDelivery;
  final Future<void> Function(DeliveryEvent event)? onHighlightStart;
  final Future<void> Function(DeliveryEvent event)? onHighlightEnd;
  final Future<void> Function()? onOverComplete;
  final Duration fastForwardDelay;
  final Duration highlightDelay;
  final Duration cooldownDelay;

  Future<void> play(List<DeliveryEvent> events, {bool skipPresentation = false}) async {
    for (final event in events) {
      if (skipPresentation) {
        await onDelivery?.call(event);
        continue;
      }
      await onDelivery?.call(event);
      if (!event.isHighlight) {
        await Future<void>.delayed(fastForwardDelay);
        continue;
      }
      await onHighlightStart?.call(event);
      await Future<void>.delayed(highlightDelay);
      await onHighlightEnd?.call(event);
      await Future<void>.delayed(cooldownDelay);
    }
    await onOverComplete?.call();
  }
}
