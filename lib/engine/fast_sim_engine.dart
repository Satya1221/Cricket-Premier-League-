import 'dart:math';
import '../models/fixture_model.dart';
import '../src/features/game/domain/career_simulation_engine.dart';

class FastSimEngine {
  const FastSimEngine();
  int battingOverall(CareerTeam team) {
    if (team.players.isEmpty) return 65;
    final players = [...team.players]..sort((a,b)=>b.overall.compareTo(a.overall));
    final top = players.take(players.length < 7 ? players.length : 7).toList();
    return top.fold<int>(0,(sum,p)=>sum+p.overall)~/top.length;
  }
  int bowlingOverall(CareerTeam team) {
    if (team.players.isEmpty) return 65;
    final eligible = team.players.where((p)=>p.role.toLowerCase().contains('bowl')||p.role.toLowerCase().contains('allrounder')||p.role.toLowerCase().contains('all-rounder')).toList()..sort((a,b)=>b.overall.compareTo(a.overall));
    final chosen=(eligible.isEmpty?[...team.players]:eligible).take(5).toList();
    return chosen.fold<int>(0,(sum,p)=>sum+p.overall)~/chosen.length;
  }
  MatchResultData simulate(CareerTeam home,CareerTeam away,{Random? random}) {
    final rng=random??Random();
    int score(CareerTeam bat,CareerTeam bowl) => max(55,150+battingOverall(bat)-bowlingOverall(bowl)+rng.nextInt(51)-25).toInt();
    final hr=score(home,away); var ar=score(away,home);
    if(hr==ar) ar+=rng.nextBool()?1:-1;
    return MatchResultData(homeRuns:hr,homeWickets:2+rng.nextInt(7),homeBalls:120,awayRuns:ar,awayWickets:2+rng.nextInt(7),awayBalls:120);
  }
}
