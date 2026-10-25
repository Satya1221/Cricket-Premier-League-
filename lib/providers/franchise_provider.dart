import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/franchise_model.dart';

final franchiseProvider=StateNotifierProvider<FranchiseNotifier,FranchiseModel>((ref)=>FranchiseNotifier());

class FranchiseNotifier extends StateNotifier<FranchiseModel>{
 FranchiseNotifier():super(_initial());
 static FranchiseModel _initial(){
  final box=Hive.box<FranchiseModel>('franchises');
  final existing=box.get('cpl');
  if(existing!=null)return existing;
  const created=FranchiseModel(id:'cpl');
  box.put(created.id,created);
  return created;
 }
 Future<void> _commit(FranchiseModel updated)async{state=updated;await Hive.box<FranchiseModel>('franchises').put(updated.id,updated);}
 Future<bool> spendStadiumFunds(int amount)async{if(amount<=0||amount>state.stadiumFunds)return false;await _commit(state.copyWith(stadiumFunds:state.stadiumFunds-amount));return true;}
 Future<bool> spendPurse(double crores)async{if(crores<=0||crores>state.purseCrores)return false;await _commit(state.copyWith(purseCrores:double.parse((state.purseCrores-crores).toStringAsFixed(2))));return true;}
 Future<void> addPlayer(String playerId)async{if(state.squadIds.contains(playerId))return;await _commit(state.copyWith(squadIds:[...state.squadIds,playerId]));}
 Future<void> setStadiumCapacity(int capacity)async{if(capacity<state.stadiumCapacity)return;await _commit(state.copyWith(stadiumCapacity:capacity));}
}
