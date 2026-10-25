import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/press_conference_engine.dart';
class MoraleState {
  const MoraleState({this.playerMorale = const {}, this.teamChemistry = 50, this.lastHeadline = 'No press conference yet.'});
  final Map<String, int> playerMorale; final int teamChemistry; final String lastHeadline;
  MoraleState copyWith({Map<String,int>? playerMorale, int? teamChemistry, String? lastHeadline}) => MoraleState(playerMorale: playerMorale ?? this.playerMorale, teamChemistry: teamChemistry ?? this.teamChemistry, lastHeadline: lastHeadline ?? this.lastHeadline);
}
class PressConferenceNotifier extends StateNotifier<MoraleState> {
  PressConferenceNotifier() : super(const MoraleState());
  final _engine = PressConferenceEngine();
  void setInitialMorale(Map<String,int> morale) => state = state.copyWith(playerMorale: Map.unmodifiable(morale));
  PressConferenceResult respond({required MediaResponse response, required List<String> strugglingPlayerIds, required List<String> bowlingUnitIds, required String focalPlayerId}) {
    final result = _engine.resolve(response: response, strugglingPlayerIds: strugglingPlayerIds, bowlingUnitIds: bowlingUnitIds, focalPlayerId: focalPlayerId);
    final morale = Map<String,int>.from(state.playerMorale);
    for (final change in result.playerChanges) { morale[change.playerId] = applyMoraleDelta(morale[change.playerId] ?? 50, change.delta); }
    state = state.copyWith(playerMorale: Map.unmodifiable(morale), teamChemistry: (state.teamChemistry + result.teamChemistryDelta).clamp(0,100), lastHeadline: result.headline);
    return result;
  }
}
final pressConferenceProvider = StateNotifierProvider<PressConferenceNotifier,MoraleState>((ref) => PressConferenceNotifier());