import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/squad_validator.dart';
import '../src/features/auction/domain/player.dart';

class FranchiseState {
  const FranchiseState({this.purseCr=120,this.stadiumFunds=12000000,this.activeSquad=const [],this.playingXI=const []});
  final double purseCr;
  final int stadiumFunds;
  final List<String> activeSquad,playingXI;
  FranchiseState copyWith({double? purseCr,int? stadiumFunds,List<String>? activeSquad,List<String>? playingXI})=>FranchiseState(purseCr:purseCr??this.purseCr,stadiumFunds:stadiumFunds??this.stadiumFunds,activeSquad:activeSquad??this.activeSquad,playingXI:playingXI??this.playingXI);
  Map<String,Object?> toJson()=>{'purseCr':purseCr,'stadiumFunds':stadiumFunds,'activeSquad':activeSquad,'playingXI':playingXI};
  factory FranchiseState.fromJson(Map<String,Object?> j)=>FranchiseState(purseCr:(j['purseCr'] as num?)?.toDouble()??120,stadiumFunds:(j['stadiumFunds'] as num?)?.toInt()??12000000,activeSquad:(j['activeSquad'] as List?)?.whereType<String>().toList()??const [],playingXI:(j['playingXI'] as List?)?.whereType<String>().toList()??const []);
}

class FranchiseRosterNotifier extends StateNotifier<FranchiseState> {
  FranchiseRosterNotifier():super(_load());
  static const _boxName='franchise_roster';
  static const _key='active-franchise';
  static FranchiseState _load(){
    final raw=Hive.box<dynamic>(_boxName).get(_key);
    if(raw is! String)return const FranchiseState();
    try { final decoded=jsonDecode(raw); return decoded is Map?FranchiseState.fromJson(Map<String,Object?>.from(decoded)):const FranchiseState(); }
    on FormatException { return const FranchiseState(); }
  }
  Future<void> _save()=>Hive.box<dynamic>(_boxName).put(_key,jsonEncode(state.toJson()));
  Future<void> setActiveSquad(List<String> ids) async { state=state.copyWith(activeSquad:List.unmodifiable(ids),playingXI:state.playingXI.where(ids.contains).toList()); await _save(); }
  Future<void> setPlayingXI(List<String> ids,List<AuctionPlayer> squad) async {
    final selected=squad.where((p)=>ids.contains(p.id)).toList();
    const validator=SquadValidator();
    validator.requireValidLineup(selected);
    if(ids.any((id)=>!state.activeSquad.contains(id))) throw FormatException('Playing XI must be selected from the active squad');
    state=state.copyWith(playingXI:List.unmodifiable(ids)); await _save();
  }
}
final franchiseRosterProvider=StateNotifierProvider<FranchiseRosterNotifier,FranchiseState>((ref)=>FranchiseRosterNotifier());
