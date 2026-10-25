import '../../match/domain/format_config.dart';
import '../../match/domain/auto_sim_engine.dart';
class LeagueFixture {
  const LeagueFixture({required this.id, required this.date, required this.home, required this.away, this.format = CricketFormat.t20, this.result});
  final String id; final DateTime date; final SimTeam home, away; final CricketFormat format; final MatchResultSummary? result;
  bool get completed => result != null;
  LeagueFixture copyWithResult(MatchResultSummary value) => LeagueFixture(id: id, date: date, home: home, away: away, format: format, result: value);
}
class LeagueStanding {
  const LeagueStanding({required this.teamId, required this.teamName, required this.played, required this.won, required this.tied, required this.lost, required this.points, required this.runsFor, required this.ballsFaced, required this.runsAgainst, required this.ballsBowled});
  final String teamId, teamName; final int played, won, tied, lost, points, runsFor, ballsFaced, runsAgainst, ballsBowled;
  double get nrr => ballsFaced == 0 || ballsBowled == 0 ? 0 : runsFor / (ballsFaced / 6) - runsAgainst / (ballsBowled / 6);
}
class LeagueSimulationEngine {
  LeagueSimulationEngine({AutoSimEngine? simulator}) : _simulator = simulator ?? AutoSimEngine();
  final AutoSimEngine _simulator;
  List<LeagueFixture> simulateFixturesForDay(List<LeagueFixture> fixtures, DateTime day, {String? userTeamId}) => fixtures.map((f) {
    if (f.completed || f.date.year != day.year || f.date.month != day.month || f.date.day != day.day) {
      return f;
    }
    if (userTeamId != null && (f.home.id == userTeamId || f.away.id == userTeamId)) {
      return f;
    }
    return f.copyWithResult(_simulator.simulateInstantMatch(matchId: f.id, home: f.home, away: f.away, format: f.format));
  }).toList(growable: false);
  List<LeagueStanding> buildStandings(List<LeagueFixture> fixtures, {required List<SimTeam> teams}) {
    final stats = {for (final t in teams) t.id: <String,int>{'p':0,'w':0,'t':0,'l':0,'pts':0,'rf':0,'bf':0,'ra':0,'ba':0}};
    for (final f in fixtures.where((f) => f.completed)) {
      final h=stats[f.home.id], a=stats[f.away.id], r=f.result!;
      if (h == null || a == null) {
        continue;
      }
      h['p']=h['p']!+1; a['p']=a['p']!+1; h['rf']=h['rf']!+r.homeInnings.runs; h['bf']=h['bf']!+r.homeInnings.legalBalls; h['ra']=h['ra']!+r.awayInnings.runs; h['ba']=h['ba']!+r.awayInnings.legalBalls;
      a['rf']=a['rf']!+r.awayInnings.runs; a['bf']=a['bf']!+r.awayInnings.legalBalls; a['ra']=a['ra']!+r.homeInnings.runs; a['ba']=a['ba']!+r.homeInnings.legalBalls;
      if (r.winnerId.isEmpty) { h['t']=h['t']!+1; a['t']=a['t']!+1; h['pts']=h['pts']!+1; a['pts']=a['pts']!+1; } else if (r.winnerId==f.home.id) { h['w']=h['w']!+1; a['l']=a['l']!+1; h['pts']=h['pts']!+2; } else { a['w']=a['w']!+1; h['l']=h['l']!+1; a['pts']=a['pts']!+2; }
    }
    final table=teams.map((t) { final s=stats[t.id]!; return LeagueStanding(teamId:t.id,teamName:t.name,played:s['p']!,won:s['w']!,tied:s['t']!,lost:s['l']!,points:s['pts']!,runsFor:s['rf']!,ballsFaced:s['bf']!,runsAgainst:s['ra']!,ballsBowled:s['ba']!); }).toList();
    table.sort((a,b) { final p=b.points.compareTo(a.points); return p != 0 ? p : b.nrr.compareTo(a.nrr); }); return table;
  }
}