import 'package:hive_flutter/hive_flutter.dart';
import '../models/player_model.dart';
import '../models/franchise_model.dart';
import '../models/game_state_model.dart';

class StorageService {
 static Future<void> initialize() async {
  if(!Hive.isAdapterRegistered(41))Hive.registerAdapter(PlayerModelAdapter());
  if(!Hive.isAdapterRegistered(42))Hive.registerAdapter(FranchiseModelAdapter());
  if(!Hive.isAdapterRegistered(43))Hive.registerAdapter(GameStateModelAdapter());
  if(!Hive.isBoxOpen('gameState'))await Hive.openBox<GameStateModel>('gameState');
  if(!Hive.isBoxOpen('franchises'))await Hive.openBox<FranchiseModel>('franchises');
  if(!Hive.isBoxOpen('players'))await Hive.openBox<PlayerModel>('players');
 }
 Box<GameStateModel> get gameState=>Hive.box<GameStateModel>('gameState');
 Box<FranchiseModel> get franchises=>Hive.box<FranchiseModel>('franchises');
 Box<PlayerModel> get players=>Hive.box<PlayerModel>('players');
}
