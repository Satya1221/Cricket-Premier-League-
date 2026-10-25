import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/medical_workload_service.dart';

class MedicalWorkloadNotifier extends StateNotifier<Map<String,PlayerWorkloadState>> {
  MedicalWorkloadNotifier():super(_load());
  static const _box='franchise_roster',_key='player-workloads';
  static Map<String,PlayerWorkloadState> _load(){
    final raw=Hive.box<dynamic>(_box).get(_key);
    if(raw is! String)return const {};
    try{
      final decoded=jsonDecode(raw);
      if(decoded is! List)return const {};
      return {for(final item in decoded.whereType<Map>()) 
        (item['playerId'] as String):PlayerWorkloadState(
          playerId:item['playerId'] as String,
          fatigue:(item['fatigue'] as num?)?.toInt()??0,
          injuryWeeksRemaining:(item['injuryWeeksRemaining'] as num?)?.toInt()??0,
          injuryType:item['injuryType'] as String?,
        )};
    }on FormatException{return const {};}
  }
  Future<void> _save()=>Hive.box<dynamic>(_box).put(_key,jsonEncode(state.values.map((p)=>{'playerId':p.playerId,'fatigue':p.fatigue,'injuryWeeksRemaining':p.injuryWeeksRemaining,'injuryType':p.injuryType}).toList()));
  Future<void> register(String playerId,{int fatigue=0})async{state={...state,playerId:state[playerId]??PlayerWorkloadState(playerId:playerId,fatigue:fatigue)};await _save();}
  Future<void> settleMatch({required String playerId,required WorkloadRole role,int oversBowled=0,int runsScored=0,int physioLevel=0,Random? random})async{
    final player=state[playerId]??PlayerWorkloadState(playerId:playerId);
    final service=const MedicalWorkloadService();
    final fatigued=service.settle(player:player,role:role,oversBowled:oversBowled,runsScored:runsScored,physioLevel:physioLevel);
    state={...state,playerId:service.rollPreMatchInjury(fatigued,random:random)};
    await _save();
  }
  Future<void> advanceWeek({int physioLevel=0})async{
    final service=const MedicalWorkloadService();
    state={for(final entry in state.entries)entry.key:service.advanceWeek(entry.value,physioLevel:physioLevel)};
    await _save();
  }
  Future<void> rollInjuriesBeforeMatch({Random? random})async{
    final service=const MedicalWorkloadService();
    state={for(final entry in state.entries)entry.key:service.rollPreMatchInjury(entry.value,random:random)};
    await _save();
  }
}
final medicalWorkloadProvider=StateNotifierProvider<MedicalWorkloadNotifier,Map<String,PlayerWorkloadState>>((ref)=>MedicalWorkloadNotifier());
