import 'dart:math';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/player_model.dart';
import '../models/franchise_model.dart';
import '../models/game_state_model.dart';

class OffSeasonService {
 const OffSeasonService();
 Future<List<PlayerModel>> process({required FranchiseModel franchise, required int leaguePosition, int youthCoachLevel=1, int youthAcademyLevel=1, Random? random}) async {
  final rng=random??Random();
  final playersBox=Hive.box<PlayerModel>('players');
  final history=Hive.box<dynamic>('history_records');
  final all=playersBox.values.toList();
  final ranked=[...all]..sort((a,b)=>b.runs.compareTo(a.runs));
  final bowlers=[...all]..sort((a,b)=>b.wickets.compareTo(a.wickets));
  final season=Hive.box<GameStateModel>('gameState').get('active')?.currentSeason??1;
  await history.put('season-$season',{'season':season,'topRunScorers':ranked.take(10).map((p)=>{'id':p.id,'name':p.name,'runs':p.runs}).toList(),'topWicketTakers':bowlers.take(10).map((p)=>{'id':p.id,'name':p.name,'wickets':p.wickets}).toList()});
  final prize=switch(leaguePosition){1=>20000000,2=>12500000,3=>8000000,4=>6000000,_=>2000000};
  await Hive.box<FranchiseModel>('franchises').put(franchise.id,franchise.copyWith(stadiumFunds:franchise.stadiumFunds+prize));
  for(final p in all){final age=p.age+1;final growth=(1+rng.nextInt(4))*max(1,youthCoachLevel);final decay=2+rng.nextInt(5);final updated=p.copyWith(age:age,batSkill:age<25?(p.batSkill+growth).clamp(1,99).toInt():p.batSkill,bowlSkill:age<25?(p.bowlSkill+growth).clamp(1,99).toInt():p.bowlSkill,stamina:age>34?(p.stamina-decay).clamp(1,100).toInt():p.stamina,fielding:age>34?(p.fielding-decay).clamp(1,100).toInt():p.fielding,isRetired:p.isRetired||age>38||p.overall<60,runs:0,wickets:0);await playersBox.put(updated.id,updated);}
  final youth=<PlayerModel>[];final cap=youthAcademyLevel>=5?90:75+((youthAcademyLevel-1).clamp(0,4).toInt()*3);
  for(var i=0;i<20;i++){final role=const ['Batter','Pace','Spin','AR','WK'][rng.nextInt(5)];final overall=min(cap,55+rng.nextInt(cap-54));final id='Y$season-${franchise.id}-$i';youth.add(PlayerModel(id:id,name:'Academy Prospect ${i+1}',age:17+rng.nextInt(3),role:role,batSkill:overall,bowlSkill:max(1,overall-5),fielding:max(1,overall-3),stamina:75+rng.nextInt(26),form:60+rng.nextInt(21)));}
  for(final p in youth){await playersBox.put(p.id,p);}return youth;
 }
}
