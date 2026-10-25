import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../src/features/game/application/season_provider.dart';
import 'season_schedule_repository.dart';

class LeagueStanding {
  const LeagueStanding({required this.teamId,required this.played,required this.won,required this.lost,required this.tied,required this.points,required this.runsFor,required this.ballsFaced,required this.runsAgainst,required this.ballsBowled});
  final String teamId;
  final int played,won,lost,tied,points,runsFor,ballsFaced,runsAgainst,ballsBowled;
  double get nrr => ballsFaced==0||ballsBowled==0?0:runsFor*6/ballsFaced-runsAgainst*6/ballsBowled;
}
final leagueStandingsProvider=Provider<List<LeagueStanding>>((ref){
  ref.watch(seasonProvider);
  final fixtures=SeasonScheduleRepository().load();
  final teams=ref.read(seasonProvider).teams;
  final rows={for(final t in teams)t.id:[0,0,0,0,0,0,0,0,0,0]};
  for(final f in fixtures.where((f)=>f.isCompleted&&f.result!=null)){
    final r=f.result!;
    final h=rows[f.homeTeamId],a=rows[f.awayTeamId]; if(h==null||a==null)continue;
    h[0]++;a[0]++;
    h[5]+=r.homeRuns;a[5]+=r.awayRuns;
    h[6]+=r.homeBalls;a[6]+=r.awayBalls;
    h[7]+=r.awayRuns;a[7]+=r.homeRuns;
    h[8]+=r.awayBalls;a[8]+=r.homeBalls;
    if(r.homeRuns>r.awayRuns){h[1]++;a[2]++;h[4]+=2;}
    else if(r.homeRuns<r.awayRuns){a[1]++;h[2]++;a[4]+=2;}
    else{h[3]++;a[3]++;h[4]++;a[4]++;}
  }
  final result=rows.entries.map((e)=>LeagueStanding(teamId:e.key,played:e.value[0],won:e.value[1],lost:e.value[2],tied:e.value[3],points:e.value[4],runsFor:e.value[5],ballsFaced:e.value[6],runsAgainst:e.value[7],ballsBowled:e.value[8])).toList();
  result.sort((a,b){final points=b.points.compareTo(a.points);return points!=0?points:b.nrr.compareTo(a.nrr);});
  return List.unmodifiable(result);
});
