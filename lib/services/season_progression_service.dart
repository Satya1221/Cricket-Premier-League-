import 'package:hive_flutter/hive_flutter.dart';
import '../models/game_state_model.dart';

class SeasonProgressionService {
 const SeasonProgressionService();
 Future<void> advanceMonth() async {
  final box=Hive.box<GameStateModel>('gameState');
  final current=box.get('active')??const GameStateModel();
  final month=current.currentMonth==12?1:current.currentMonth+1;
  final season=current.currentSeason+(current.currentMonth==12?1:0);
  await box.put('active',current.copyWith(currentMonth:month,currentSeason:season));
 }
}
