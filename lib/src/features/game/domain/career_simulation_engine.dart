import '../../../../models/fixture_model.dart';
import 'dart:math';

class CareerPlayer {
  const CareerPlayer({required this.id, required this.name, required this.age, required this.overall, required this.potential, required this.role, this.runs = 0, this.wickets = 0, this.highScore = 0, this.fifties = 0, this.hundreds = 0, this.ballsFaced = 0, this.runsConceded = 0, this.ballsBowled = 0, this.bestBowlingRuns = 0, this.bestBowlingWickets = 0, this.retired = false});
  final String id, name, role;
  final int age, overall, potential, runs, wickets, highScore, fifties, hundreds, ballsFaced, runsConceded, ballsBowled, bestBowlingRuns, bestBowlingWickets;
  final bool retired;
  CareerPlayer copyWith({int? age, int? runs, int? wickets, int? highScore, int? fifties, int? hundreds, int? ballsFaced, int? runsConceded, int? ballsBowled, int? bestBowlingRuns, int? bestBowlingWickets, bool? retired}) => CareerPlayer(id:id,name:name,age:age??this.age,overall:overall,potential:potential,role:role,runs:runs??this.runs,wickets:wickets??this.wickets,highScore:highScore??this.highScore,fifties:fifties??this.fifties,hundreds:hundreds??this.hundreds,ballsFaced:ballsFaced??this.ballsFaced,runsConceded:runsConceded??this.runsConceded,ballsBowled:ballsBowled??this.ballsBowled,bestBowlingRuns:bestBowlingRuns??this.bestBowlingRuns,bestBowlingWickets:bestBowlingWickets??this.bestBowlingWickets,retired:retired??this.retired);
  Map<String,Object?> toJson()=>{'id':id,'name':name,'age':age,'overall':overall,'potential':potential,'role':role,'runs':runs,'wickets':wickets,'highScore':highScore,'fifties':fifties,'hundreds':hundreds,'ballsFaced':ballsFaced,'runsConceded':runsConceded,'ballsBowled':ballsBowled,'bestBowlingRuns':bestBowlingRuns,'bestBowlingWickets':bestBowlingWickets,'retired':retired};
  factory CareerPlayer.fromJson(Map<String,Object?> j)=>CareerPlayer(id:j['id']! as String,name:j['name']! as String,age:j['age']! as int,overall:j['overall']! as int,potential:j['potential']! as int,role:j['role']! as String,runs:j['runs'] as int? ?? 0,wickets:j['wickets'] as int? ?? 0,highScore:j['highScore'] as int? ?? 0,fifties:j['fifties'] as int? ?? 0,hundreds:j['hundreds'] as int? ?? 0,ballsFaced:j['ballsFaced'] as int? ?? 0,runsConceded:j['runsConceded'] as int? ?? 0,ballsBowled:j['ballsBowled'] as int? ?? 0,bestBowlingRuns:j['bestBowlingRuns'] as int? ?? 0,bestBowlingWickets:j['bestBowlingWickets'] as int? ?? 0,retired:j['retired'] as bool? ?? false);
}

class CareerTeam {
  const CareerTeam({required this.id,required this.name,this.played=0,this.won=0,this.lost=0,this.points=0,this.runsFor=0,this.ballsFaced=0,this.runsAgainst=0,this.ballsBowled=0,this.players=const [],this.playingXIIds=const [],this.purseCr=120});
  final String id,name;
  final int played,won,lost,points,runsFor,ballsFaced,runsAgainst,ballsBowled;
  final List<CareerPlayer> players;
  final List<String> playingXIIds;
  final double purseCr;
  double get netRunRate {
    if(ballsFaced==0||ballsBowled==0)return 0;
    return runsFor/(ballsFaced/6)-runsAgainst/(ballsBowled/6);
  }
  CareerTeam copyWith({int? played,int? won,int? lost,int? points,int? runsFor,int? ballsFaced,int? runsAgainst,int? ballsBowled,List<CareerPlayer>? players,List<String>? playingXIIds,double? purseCr})=>CareerTeam(id:id,name:name,played:played??this.played,won:won??this.won,lost:lost??this.lost,points:points??this.points,runsFor:runsFor??this.runsFor,ballsFaced:ballsFaced??this.ballsFaced,runsAgainst:runsAgainst??this.runsAgainst,ballsBowled:ballsBowled??this.ballsBowled,players:players??this.players,playingXIIds:playingXIIds??this.playingXIIds,purseCr:purseCr??this.purseCr);
  Map<String,Object?> toJson()=>{'id':id,'name':name,'played':played,'won':won,'lost':lost,'points':points,'runsFor':runsFor,'ballsFaced':ballsFaced,'runsAgainst':runsAgainst,'ballsBowled':ballsBowled,'purseCr':purseCr,'players':players.map((p)=>p.toJson()).toList(),'playingXIIds':playingXIIds};
  factory CareerTeam.fromJson(Map<String,Object?> j)=>CareerTeam(id:j['id']! as String,name:j['name']! as String,played:j['played'] as int? ?? 0,won:j['won'] as int? ?? 0,lost:j['lost'] as int? ?? 0,points:j['points'] as int? ?? 0,runsFor:j['runsFor'] as int? ?? 0,ballsFaced:j['ballsFaced'] as int? ?? 0,runsAgainst:j['runsAgainst'] as int? ?? 0,ballsBowled:j['ballsBowled'] as int? ?? 0,purseCr:(j['purseCr'] as num?)?.toDouble()??120,players:(j['players'] as List<Object?>? ?? const []).map((p)=>CareerPlayer.fromJson(Map<String,Object?>.from(p! as Map))).toList(),playingXIIds:(j['playingXIIds'] as List<Object?>? ?? const []).whereType<String>().toList());
}

class CareerFixture {
  const CareerFixture({required this.id,required this.homeTeamId,required this.awayTeamId,required this.round,this.played=false,this.homeRuns,this.homeBalls,this.awayRuns,this.awayBalls,this.winnerTeamId});
  final String id,homeTeamId,awayTeamId;
  final int round;
  final bool played;
  final int? homeRuns,homeBalls,awayRuns,awayBalls;
  final String? winnerTeamId;
  CareerFixture copyWith({bool? played,int? homeRuns,int? homeBalls,int? awayRuns,int? awayBalls,String? winnerTeamId})=>CareerFixture(id:id,homeTeamId:homeTeamId,awayTeamId:awayTeamId,round:round,played:played??this.played,homeRuns:homeRuns??this.homeRuns,homeBalls:homeBalls??this.homeBalls,awayRuns:awayRuns??this.awayRuns,awayBalls:awayBalls??this.awayBalls,winnerTeamId:winnerTeamId??this.winnerTeamId);
  Map<String,Object?> toJson()=>{'id':id,'homeTeamId':homeTeamId,'awayTeamId':awayTeamId,'round':round,'played':played,'homeRuns':homeRuns,'homeBalls':homeBalls,'awayRuns':awayRuns,'awayBalls':awayBalls,'winnerTeamId':winnerTeamId};
  factory CareerFixture.fromJson(Map<String,Object?> j)=>CareerFixture(id:j['id']! as String,homeTeamId:j['homeTeamId']! as String,awayTeamId:j['awayTeamId']! as String,round:j['round']! as int,played:j['played'] as bool? ?? false,homeRuns:j['homeRuns'] as int?,homeBalls:j['homeBalls'] as int?,awayRuns:j['awayRuns'] as int?,awayBalls:j['awayBalls'] as int?,winnerTeamId:j['winnerTeamId'] as String?);
}

class SeasonData {
  const SeasonData({required this.seasonNumber,required this.teams,required this.fixtures,this.matchHistory=const [],this.month=1});
  final int seasonNumber,month;
  final List<CareerTeam> teams;
  final List<CareerFixture> fixtures;
  final List<Map<String,Object?>> matchHistory;
  Map<String,Object?> toJson()=>{'seasonNumber':seasonNumber,'month':month,'teams':teams.map((t)=>t.toJson()).toList(),'fixtures':fixtures.map((f)=>f.toJson()).toList(),'matchHistory':matchHistory};
  factory SeasonData.fromJson(Map<String,Object?> j)=>SeasonData(seasonNumber:j['seasonNumber']! as int,month:j['month'] as int? ?? 1,teams:(j['teams'] as List<Object?>).map((t)=>CareerTeam.fromJson(Map<String,Object?>.from(t! as Map))).toList(),fixtures:(j['fixtures'] as List<Object?>).map((f)=>CareerFixture.fromJson(Map<String,Object?>.from(f! as Map))).toList(),matchHistory:(j['matchHistory'] as List<Object?>? ?? const []).map((m)=>Map<String,Object?>.from(m! as Map)).toList());
}

class CareerSimulationEngine {
  const CareerSimulationEngine();

  /// Double round-robin circle method; the second leg reverses every venue.
  List<CareerFixture> generateRoundRobin(List<CareerTeam> teams,{int season=1}) {
    if(teams.length<2)return const [];
    final slots=<CareerTeam?>[...teams,if(teams.length.isOdd)null];
    final n=slots.length; final fixtures=<CareerFixture>[];
    for(var round=0;round<n-1;round++){
      for(var i=0;i<n~/2;i++){
        final a=slots[i],b=slots[n-1-i];
        if(a==null||b==null)continue;
        final home=round.isEven?a:b,away=round.isEven?b:a;
        fixtures.add(CareerFixture(id:'S$season-R${round+1}-${home.id}-${away.id}',homeTeamId:home.id,awayTeamId:away.id,round:round+1));
      }
      final fixed=slots.first; final rotating=slots.sublist(1);
      rotating.insert(0,rotating.removeLast());
      slots..clear()..add(fixed)..addAll(rotating);
    }
    final secondLeg = fixtures.map((f) => CareerFixture(
      id: 'S${season}-R${f.round + n - 1}-${f.awayTeamId}-${f.homeTeamId}',
      homeTeamId: f.awayTeamId,
      awayTeamId: f.homeTeamId,
      round: f.round + n - 1,
    ));
    return [...fixtures, ...secondLeg];
  }

  Map<String,int> simulateInnings({required int battingRating,required int bowlingRating,Random? random}) {
    final rng=random??Random(); var runs=0,wickets=0,balls=0;
    final edge=((battingRating-bowlingRating)/100).clamp(-.25,.25);
    while(balls<120&&wickets<10){
      balls++; final roll=rng.nextDouble();
      final wicket=(.055-edge*.055).clamp(.025,.085);
      if(roll<wicket){wickets++;continue;}
      final shot=rng.nextDouble();
      if(shot<.30-edge*.10){} else if(shot<.62-edge*.06){runs++;} else if(shot<.76){runs+=2;} else if(shot<.90+edge*.04){runs+=4;} else {runs+=6;}
    }
    return {'runs':runs,'wickets':wickets,'balls':balls};
  }

  SeasonData simulateNextFixture(SeasonData season,{Random? random}) {
    final fi=season.fixtures.indexWhere((f)=>!f.played);
    if(fi<0)return season;
    final f=season.fixtures[fi];
    final hi=season.teams.indexWhere((t)=>t.id==f.homeTeamId),ai=season.teams.indexWhere((t)=>t.id==f.awayTeamId);
    if(hi<0||ai<0)return season;
    final h=season.teams[hi],a=season.teams[ai];
    int rating(CareerTeam t) {
      if (t.players.isEmpty) return 65;
      final selected = t.playingXIIds.isEmpty
          ? ([...t.players]..sort((a, b) => b.overall.compareTo(a.overall))).take(11).toList()
          : t.players.where((player) => t.playingXIIds.contains(player.id)).toList();
      final lineup = selected.isEmpty ? t.players : selected;
      return lineup.fold<int>(0, (sum, player) => sum + player.overall) ~/ lineup.length;
    }
    final hs=simulateInnings(battingRating:rating(h)+3,bowlingRating:rating(a),random:random);
    final ascore=simulateInnings(battingRating:rating(a),bowlingRating:rating(h)+3,random:random);
    final hw=hs['runs']!>=ascore['runs']!; final winner=hw?h.id:a.id;
    final updated=f.copyWith(played:true,homeRuns:hs['runs'],homeBalls:hs['balls'],awayRuns:ascore['runs'],awayBalls:ascore['balls'],winnerTeamId:winner);
    final ts=[...season.teams];
    ts[hi]=h.copyWith(played:h.played+1,won:h.won+(hw?1:0),lost:h.lost+(hw?0:1),points:h.points+(hw?2:0),runsFor:h.runsFor+hs['runs']!,ballsFaced:h.ballsFaced+hs['balls']!,runsAgainst:h.runsAgainst+ascore['runs']!,ballsBowled:h.ballsBowled+ascore['balls']!);
    ts[ai]=a.copyWith(played:a.played+1,won:a.won+(hw?0:1),lost:a.lost+(hw?1:0),points:a.points+(hw?0:2),runsFor:a.runsFor+ascore['runs']!,ballsFaced:a.ballsFaced+ascore['balls']!,runsAgainst:a.runsAgainst+hs['runs']!,ballsBowled:a.ballsBowled+hs['balls']!);
    final fs=[...season.fixtures]..[fi]=updated;
    final homePlayers=[...ts[hi].players];
    if(homePlayers.isNotEmpty){final batter=homePlayers[0]; final score=hs['runs']!; homePlayers[0]=batter.copyWith(runs:batter.runs+score,highScore:score>batter.highScore?score:batter.highScore,fifties:batter.fifties+(score>=50&&score<100?1:0),hundreds:batter.hundreds+(score>=100?1:0),ballsFaced:batter.ballsFaced+hs['balls']!);}
    if(homePlayers.length>1){final bowler=homePlayers[1]; final conceded=ascore['runs']!, wk=ascore['wickets']!; final better=wk>bowler.bestBowlingWickets||(wk==bowler.bestBowlingWickets&&conceded<bowler.bestBowlingRuns); homePlayers[1]=bowler.copyWith(wickets:bowler.wickets+wk,runsConceded:bowler.runsConceded+conceded,ballsBowled:bowler.ballsBowled+ascore['balls']!,bestBowlingWickets:better?wk:bowler.bestBowlingWickets,bestBowlingRuns:better?conceded:bowler.bestBowlingRuns);}
    ts[hi]=ts[hi].copyWith(players:homePlayers);
    final awayPlayers=[...ts[ai].players];
    if(awayPlayers.isNotEmpty){final batter=awayPlayers[0]; final score=ascore['runs']!; awayPlayers[0]=batter.copyWith(runs:batter.runs+score,highScore:score>batter.highScore?score:batter.highScore,fifties:batter.fifties+(score>=50&&score<100?1:0),hundreds:batter.hundreds+(score>=100?1:0),ballsFaced:batter.ballsFaced+ascore['balls']!);}
    if(awayPlayers.length>1){final bowler=awayPlayers[1]; final conceded=hs['runs']!, wk=hs['wickets']!; final better=wk>bowler.bestBowlingWickets||(wk==bowler.bestBowlingWickets&&conceded<bowler.bestBowlingRuns); awayPlayers[1]=bowler.copyWith(wickets:bowler.wickets+wk,runsConceded:bowler.runsConceded+conceded,ballsBowled:bowler.ballsBowled+hs['balls']!,bestBowlingWickets:better?wk:bowler.bestBowlingWickets,bestBowlingRuns:better?conceded:bowler.bestBowlingRuns);}
    ts[ai]=ts[ai].copyWith(players:awayPlayers);
    final history=[...season.matchHistory,{'fixtureId':f.id,'home':h.name,'away':a.name,'homeScore':'${hs['runs']}/${hs['wickets']}','awayScore':'${ascore['runs']}/${ascore['wickets']}','homeRunsRaw':hs['runs'],'homeBallsRaw':hs['balls'],'awayRunsRaw':ascore['runs'],'awayBallsRaw':ascore['balls'],'winnerTeamId':winner}];
    return SeasonData(seasonNumber:season.seasonNumber,teams:ts,fixtures:fs,matchHistory:history,month:season.month);
  }

  SeasonData recordFixtureResult(
    SeasonData season,
    String fixtureId,
    MatchResultData result,
  ) {
    final index = season.fixtures.indexWhere((fixture) => fixture.id == fixtureId);
    if (index < 0 || season.fixtures[index].played) return season;
    final fixture = season.fixtures[index];
    final homeIndex = season.teams.indexWhere((team) => team.id == fixture.homeTeamId);
    final awayIndex = season.teams.indexWhere((team) => team.id == fixture.awayTeamId);
    if (homeIndex < 0 || awayIndex < 0) return season;
    final home = season.teams[homeIndex], away = season.teams[awayIndex];
    final homeWin = result.homeRuns > result.awayRuns;
    final awayWin = result.awayRuns > result.homeRuns;
    final updatedTeams = [...season.teams];
    updatedTeams[homeIndex] = home.copyWith(
      played: home.played + 1, won: home.won + (homeWin ? 1 : 0),
      lost: home.lost + (awayWin ? 1 : 0),
      points: home.points + (homeWin ? 2 : result.homeRuns == result.awayRuns ? 1 : 0),
      runsFor: home.runsFor + result.homeRuns, ballsFaced: home.ballsFaced + result.homeBalls,
      runsAgainst: home.runsAgainst + result.awayRuns, ballsBowled: home.ballsBowled + result.awayBalls,
    );
    updatedTeams[awayIndex] = away.copyWith(
      played: away.played + 1, won: away.won + (awayWin ? 1 : 0),
      lost: away.lost + (homeWin ? 1 : 0),
      points: away.points + (awayWin ? 2 : result.homeRuns == result.awayRuns ? 1 : 0),
      runsFor: away.runsFor + result.awayRuns, ballsFaced: away.ballsFaced + result.awayBalls,
      runsAgainst: away.runsAgainst + result.homeRuns, ballsBowled: away.ballsBowled + result.homeBalls,
    );
    final winner = homeWin ? home.id : awayWin ? away.id : null;
    final updatedFixtures = [...season.fixtures];
    updatedFixtures[index] = fixture.copyWith(
      played: true, homeRuns: result.homeRuns, homeBalls: result.homeBalls,
      awayRuns: result.awayRuns, awayBalls: result.awayBalls,
      winnerTeamId: winner,
    );
    final history = [...season.matchHistory, <String, Object?>{
      'fixtureId': fixture.id, 'home': home.name, 'away': away.name,
      'homeScore': '${result.homeRuns}/${result.homeWickets}',
      'awayScore': '${result.awayRuns}/${result.awayWickets}',
      'homeRunsRaw': result.homeRuns, 'homeBallsRaw': result.homeBalls,
      'awayRunsRaw': result.awayRuns, 'awayBallsRaw': result.awayBalls,
      'winnerTeamId': winner,
    }];
    return SeasonData(seasonNumber: season.seasonNumber, month: season.month,
      teams: updatedTeams, fixtures: updatedFixtures, matchHistory: history);
  }

  List<CareerTeam> standings(List<CareerTeam> teams)=>[...teams]..sort((a,b){final p=b.points.compareTo(a.points);return p!=0?p:b.netRunRate.compareTo(a.netRunRate);});

  SeasonData endSeason(SeasonData season,{int academyLevel=1,Random? random}) {
    final rng=random??Random(); final ranked=standings(season.teams); final teams=<CareerTeam>[];
    for(var rank=0;rank<ranked.length;rank++){
      final t=ranked[rank]; final prize=switch(rank){0=>20.0,1=>12.5,2=>8.0,3=>6.0,_=>2.0};
      final players=<CareerPlayer>[];
      for (final p in t.players) {
        final age = p.age + 1;
        var overall = p.overall;
        if (age <= 24) {
          // Young players grow toward their ceiling.
          overall = min(p.potential, overall + 1 + rng.nextInt(4));
        } else if (age >= 35) {
          // Veterans decline.
          overall = max(40, overall - 2 - rng.nextInt(5));
        }
        if (age > 38 || overall < 55) {
          continue; // Retires.
        }
        players.add(CareerPlayer(
          id: p.id,
          name: p.name,
          age: age,
          overall: overall,
          potential: p.potential,
          role: p.role,
        ));
      }
      for(var i=0;i<max(1,academyLevel);i++){
        final pot=min(95,65+academyLevel*4+rng.nextInt(11));
        players.add(CareerPlayer(id:'Y${season.seasonNumber+1}-${t.id}-$i',name:'Academy Prospect ${t.id.toUpperCase()} ${i+1}',age:17+rng.nextInt(4),overall:max(45,pot-15),potential:pot,role:const ['batter','bowler','allRounder','wicketKeeper'][rng.nextInt(4)]));
      }
      teams.add(CareerTeam(id:t.id,name:t.name,players:players,purseCr:t.purseCr+prize));
    }
    return SeasonData(seasonNumber:season.seasonNumber+1,teams:teams,fixtures:generateRoundRobin(teams,season:season.seasonNumber+1),month:1);
  }
}
