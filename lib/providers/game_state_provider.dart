import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/game_state_model.dart';

final gameStateProvider=StateNotifierProvider<GameStateNotifier,GameStateModel>((ref)=>GameStateNotifier());
class GameStateNotifier extends StateNotifier<GameStateModel>{
 GameStateNotifier():super(_load());
 static GameStateModel _load()=>Hive.box<GameStateModel>('gameState').get('active')??const GameStateModel();
 Future<void> _save()async=>Hive.box<GameStateModel>('gameState').put('active',state);
 Future<void> setPhase(String phase)async{state=state.copyWith(gamePhase:phase);await _save();}
 Future<void> advanceMonth()async{final month=state.currentMonth==12?1:state.currentMonth+1;final season=state.currentSeason+(state.currentMonth==12?1:0);state=state.copyWith(currentMonth:month,currentSeason:season);await _save();}
 Future<void> startNextSeason()async{state=GameStateModel(currentSeason:state.currentSeason+1,currentMonth:1,gamePhase:'PreSeason');await _save();}
}
