import '../models/fixture_model.dart';
import 'medical_workload_service.dart';

class MatchSettlementService {
  const MatchSettlementService(this.workloadService);
  final MedicalWorkloadService workloadService;

  Map<String,PlayerWorkloadState> settle({
    required Iterable<PlayerWorkloadState> playingXI,
    required Map<String,WorkloadRole> roles,
    required Map<String,int> oversBowled,
    required Map<String,int> runsScored,
    int physioLevel=0,
  }) {
    return {
      for(final player in playingXI)
        player.playerId:workloadService.settle(
          player:player,
          role:roles[player.playerId]??WorkloadRole.other,
          oversBowled:oversBowled[player.playerId]??0,
          runsScored:runsScored[player.playerId]??0,
          physioLevel:physioLevel,
        ),
    };
  }

  FixtureModel completeFixture(FixtureModel fixture,MatchResultData result)=>fixture.copyWith(isCompleted:true,result:result);
}
