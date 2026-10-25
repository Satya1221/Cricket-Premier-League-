import 'package:flutter_test/flutter_test.dart';
import 'package:cricket_premier_league/engine/fast_sim_engine.dart';
import 'package:cricket_premier_league/services/squad_validator.dart';
import 'package:cricket_premier_league/src/features/auction/domain/player.dart';
import 'package:cricket_premier_league/src/features/game/domain/career_simulation_engine.dart';

AuctionPlayer player(String id,{PlayerRole role=PlayerRole.batter,int bowling=20,bool overseas=false})=>AuctionPlayer(
  id:id,name:'Player $id',nation:overseas?'Australia':'India',role:role,overall:75,potential:80,basePriceCr:1,bowling:bowling,isOverseas:overseas);

void main(){
  test('squad validator reports missing wicketkeeper and insufficient bowlers',(){
    final squad=List.generate(11,(i)=>player('$i',bowling:i<4?50:20));
    final result=const SquadValidator().validate(squad);
    expect(result.errors,contains('Missing Wicketkeeper'));
    expect(result.errors,contains('Not enough bowlers'));
  });

  test('valid XI requires 11 players, a keeper, five bowlers and overseas limit',(){
    final squad=List.generate(11,(i)=>player('$i',role:i==0?PlayerRole.wicketKeeper:PlayerRole.batter,bowling:i<5?55:10,overseas:i<5));
    final result=const SquadValidator().validate(squad);
    expect(result.errors,contains('Maximum 4 overseas players allowed'));
    expect(result.isValid,isFalse);
  });

  test('fast simulator returns valid T20 totals',(){
    const teamA=CareerTeam(id:'a',name:'A');
    const teamB=CareerTeam(id:'b',name:'B');
    final result=const FastSimEngine().simulate(teamA,teamB);
    expect(result.homeRuns,greaterThanOrEqualTo(55));
    expect(result.homeBalls,120);
    expect(result.awayBalls,120);
    expect(result.homeRuns, isNot(result.awayRuns));
  });
}
