import '../../squad/domain/global_player.dart';
import '../../match/domain/format_config.dart';

class WorkloadEvent {
  const WorkloadEvent({
    required this.playerId,
    required this.competitionId,
    required this.format,
    required this.legalBallsBowled,
    required this.legalBallsFaced,
    required this.matchDays,
    this.recoveryDays = 0,
  })  : assert(legalBallsBowled >= 0),
        assert(legalBallsFaced >= 0),
        assert(matchDays >= 0),
        assert(recoveryDays >= 0);

  final String playerId;
  final String competitionId;
  final CricketFormat format;
  final int legalBallsBowled;
  final int legalBallsFaced;
  final int matchDays;
  final int recoveryDays;
}

class GlobalWorkloadEngine {
  const GlobalWorkloadEngine();

  /// Accumulates workload regardless of whether the match is club or country.
  /// Inputs are legal balls plus match days, allowing Tests to cost more than T20.
  double applyEvent(GlobalPlayer player, WorkloadEvent event) {
    if (event.playerId != player.id) {
      throw ArgumentError('Workload event player ID does not match player.');
    }
    final config = FormatConfig.forFormat(event.format);
    final bowlerLoad = event.legalBallsBowled / 6.0;
    final batterLoad = event.legalBallsFaced / 24.0;
    final dayLoad = event.matchDays * (event.format == CricketFormat.test ? 1.8 : 0.65);
    final recovery = event.recoveryDays * 2.5;
    final increment = ((bowlerLoad * 0.75) + (batterLoad * 0.35) + dayLoad) *
        config.fatigueMultiplier - recovery;
    player.fatigueLevel = (player.fatigueLevel + increment).clamp(0.0, 100.0);
    return player.fatigueLevel;
  }

  double recover(GlobalPlayer player, {required int restDays}) {
    if (restDays < 0) throw ArgumentError.value(restDays, 'restDays');
    player.fatigueLevel =
        (player.fatigueLevel - restDays * 3.0).clamp(0.0, 100.0);
    return player.fatigueLevel;
  }

  bool isAvailable(GlobalPlayer player, {double maximumFatigue = 85}) =>
      player.fatigueLevel < maximumFatigue;
}
