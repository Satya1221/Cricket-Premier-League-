import 'package:hive_flutter/hive_flutter.dart';
import '../models/delivery_model.dart';
import '../models/player_model.dart';

class StatsAggregator {
 const StatsAggregator();
 Future<void> aggregateMatch({required String matchId,required List<DeliveryModel> deliveries}) async {
  final players=Hive.box<PlayerModel>('players');
  final processed=Hive.box<dynamic>('history_records');
  if(processed.containsKey('stats-$matchId'))return;
  final runs=<String,int>{},balls=<String,int>{},wickets=<String,int>{};
  for(final d in deliveries){
   runs[d.strikerId]=(runs[d.strikerId]??0)+d.runsScored;
   if(d.extraType!='Wide')balls[d.strikerId]=(balls[d.strikerId]??0)+1;
   // IPL does not credit a bowler for run-outs, retired-out, timed-out,
   // obstructing the field, or hit-the-ball-twice dismissals.
   const uncredited={'RunOut','RetiredOut','TimedOut','ObstructingTheField','HitTheBallTwice','RetiredHurt'};
   if(d.isWicket && !uncredited.contains(d.dismissalType) && d.extraType!='NoBall' && !(d.extraType=='Wide' && d.dismissalType!='Stumped')) {
    wickets[d.bowlerId]=(wickets[d.bowlerId]??0)+1;
   }
  }
  final involved=<String>{...runs.keys,...balls.keys,...wickets.keys}..remove('');
  for(final id in involved){
   final player=players.get(id);if(player==null)continue;
   final matchRuns=runs[id]??0;
   await players.put(id,player.copyWith(
    runs:player.runs+matchRuns,
    wickets:player.wickets+(wickets[id]??0),
    careerRuns:player.careerRuns+matchRuns,
    careerWickets:player.careerWickets+(wickets[id]??0),
    matchesPlayed:player.matchesPlayed+1,
    highestScore:matchRuns>player.highestScore?matchRuns:player.highestScore,
    careerBallsFaced:player.careerBallsFaced+(balls[id]??0),
   ));
  }
  await processed.put('stats-$matchId',{'matchId':matchId,'playerIds':involved.toList(),'aggregatedAt':DateTime.now().toIso8601String()});
 }
}
