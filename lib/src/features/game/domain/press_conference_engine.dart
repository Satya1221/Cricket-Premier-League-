enum MediaResponse { defendPlayer, backTeam, demandImprovement, acceptResponsibility }
class MoraleChange {
  const MoraleChange({required this.playerId, required this.delta, required this.reason});
  final String playerId;
  final int delta;
  final String reason;
}
class PressConferenceResult {
  const PressConferenceResult({required this.response, required this.teamChemistryDelta, required this.playerChanges, required this.headline});
  final MediaResponse response;
  final int teamChemistryDelta;
  final List<MoraleChange> playerChanges;
  final String headline;
}
class PressConferenceEngine {
  PressConferenceResult resolve({required MediaResponse response, required Iterable<String> strugglingPlayerIds, required Iterable<String> bowlingUnitIds, required String focalPlayerId}) {
    final changes = <MoraleChange>[];
    var chemistry = 0;
    switch (response) {
      case MediaResponse.defendPlayer:
        changes.add(MoraleChange(playerId: focalPlayerId, delta: 8, reason: 'Manager publicly backed the player'));
        chemistry = 2;
      case MediaResponse.backTeam:
        for (final id in bowlingUnitIds) { changes.add(MoraleChange(playerId: id, delta: 4, reason: 'Manager showed faith in the unit')); }
        chemistry = 5;
      case MediaResponse.demandImprovement:
        for (final id in strugglingPlayerIds) { changes.add(MoraleChange(playerId: id, delta: -6, reason: 'Public criticism from manager')); }
        chemistry = -3;
      case MediaResponse.acceptResponsibility:
        for (final id in strugglingPlayerIds) { changes.add(MoraleChange(playerId: id, delta: 3, reason: 'Manager took pressure off the squad')); }
        chemistry = 6;
    }
    const headlines = {
      MediaResponse.defendPlayer: 'Manager backs their opener',
      MediaResponse.backTeam: 'Manager stands by the bowling unit',
      MediaResponse.demandImprovement: 'Manager demands a response',
      MediaResponse.acceptResponsibility: 'Manager takes responsibility',
    };
    return PressConferenceResult(response: response, teamChemistryDelta: chemistry, playerChanges: List.unmodifiable(changes), headline: headlines[response]!);
  }
}
int applyMoraleDelta(int morale, int delta) => (morale + delta).clamp(0, 100);
double moralePerformanceMultiplier(int morale) {
  final m = morale.clamp(0, 100) / 100;
  return .65 + m * .35;
}
