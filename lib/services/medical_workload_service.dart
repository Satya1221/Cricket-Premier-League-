import 'dart:math';

enum WorkloadRole { paceBowler, spinBowler, batter, other }
class PlayerWorkloadState {
  const PlayerWorkloadState({required this.playerId,this.fatigue=0,this.injuryWeeksRemaining=0,this.injuryType});
  final String playerId;
  final int fatigue,injuryWeeksRemaining;
  final String? injuryType;
  bool get unavailable=>injuryWeeksRemaining>0;
  PlayerWorkloadState copyWith({int? fatigue,int? injuryWeeksRemaining,String? injuryType,bool clearInjury=false})=>PlayerWorkloadState(playerId:playerId,fatigue:(fatigue??this.fatigue).clamp(0,100),injuryWeeksRemaining:injuryWeeksRemaining??this.injuryWeeksRemaining,injuryType:clearInjury?null:(injuryType??this.injuryType));
}
class MedicalWorkloadService {
  const MedicalWorkloadService();
  PlayerWorkloadState settle({required PlayerWorkloadState player,required WorkloadRole role,int oversBowled=0,int runsScored=0,int physioLevel=0}) {
    final added=switch(role){WorkloadRole.paceBowler=>oversBowled*15,WorkloadRole.spinBowler=>oversBowled*8,WorkloadRole.batter=>runsScored*2,WorkloadRole.other=>0};
    return player.copyWith(fatigue:player.fatigue+added);
  }
  PlayerWorkloadState advanceWeek(PlayerWorkloadState player,{int physioLevel=0}) {
    final recovery=20+physioLevel.clamp(0,5)*10;
    final weeks=max(0,player.injuryWeeksRemaining-1);
    return player.copyWith(fatigue:max(0,player.fatigue-recovery),injuryWeeksRemaining:weeks,clearInjury:weeks==0);
  }
  PlayerWorkloadState rollPreMatchInjury(PlayerWorkloadState player,{Random? random}) {
    if(player.fatigue<=75||player.unavailable)return player;
    final rng=random??Random();
    if(rng.nextDouble()>=.20)return player;
    return player.copyWith(injuryWeeksRemaining:1+rng.nextInt(3),injuryType:'Hamstring Strain');
  }
}
