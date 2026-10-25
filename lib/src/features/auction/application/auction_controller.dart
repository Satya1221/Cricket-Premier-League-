import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../models/franchise_model.dart';
import '../../../../models/player_model.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../game/data/campaign_store.dart';
import '../data/demo_auction.dart';
import '../domain/auction_engine.dart';
import '../domain/auction_state.dart';
import '../domain/player.dart';

final auctionControllerProvider =
    NotifierProvider<AuctionController, AuctionState>(AuctionController.new);

class AuctionController extends Notifier<AuctionState> {
  final AuctionEngine _engine = const AuctionEngine();
  Timer? _biddingTimer;
  int _quietTicks = 0;

  static const List<RivalProfile> _rivals = [
    RivalProfile(teamId: 'roy', style: RivalStyle.aggressive, aggression: 0.82),
    RivalProfile(teamId: 'tit', style: RivalStyle.budgetGuardian, aggression: 0.42),
    RivalProfile(
      teamId: 'fal',
      style: RivalStyle.youthFirst,
      aggression: 0.68,
      targetRoles: {PlayerRole.batter, PlayerRole.allRounder},
    ),
  ];

  @override
  AuctionState build() {
    ref.onDispose(() => _biddingTimer?.cancel());
    final initial=createDemoAuction();
    unawaited(_syncPlayerModels(initial));
    return initial;
  }

  Future<void> _syncPlayerModels(AuctionState auction) async {
    final box=Hive.box<PlayerModel>('players');
    final all=<String,AuctionPlayer>{for(final p in auction.players)p.id:p};
    for(final team in auction.teams){for(final p in team.squad){all[p.id]=p;}}
    for(final p in all.values){
      if(box.containsKey(p.id))continue;
      await box.put(p.id,PlayerModel(id:p.id,name:p.name,age:p.age,role:switch(p.role){PlayerRole.batter=>'Batter',PlayerRole.bowler=>'Pace',PlayerRole.allRounder=>'AR',PlayerRole.wicketKeeper=>'WK'},batSkill:p.batting,bowlSkill:p.bowling,fielding:p.fielding,stamina:80,form:p.form,nation:p.nation,isOverseas:p.isOverseas));
    }
  }

  /// Starts the two-second live rival bidding loop. Two quiet ticks close the lot.
  void startLiveBidding() {
    _biddingTimer?.cancel();
    _quietTicks = 0;
    _biddingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (state.currentPlayer == null || state.phase == AuctionPhase.completed || state.phase == AuctionPhase.sold || state.phase == AuctionPhase.unsold) {
        timer.cancel(); return;
      }
      final before = state.currentBidCr;
      final previousLeader = state.leadingTeamId;
      state = _engine.runRivalRound(state: state, rivals: _rivals);
      if (state.currentBidCr > before || state.leadingTeamId != previousLeader) {
        _quietTicks = 0;
      } else {
        _quietTicks++;
      }
      if (_quietTicks >= 2) {
        timer.cancel();
        hammerDown();
      }
    });
  }

  void stopLiveBidding() { _biddingTimer?.cancel(); _biddingTimer = null; }

  void hammerDown() { stopLiveBidding(); closeLot(); }


  /// Places a bid. When the human franchise bids, the rival AI immediately
  /// evaluates and counter-bids, so the auction never stalls waiting for a
  /// manual "simulate rival round" tap.
  void bidFor(String teamId) {
    state = _engine.placeBid(state: state, teamId: teamId);
    if (teamId == 'cpl') {
      state = _engine.runRivalRound(state: state, rivals: _rivals);
    }
  }

  void runRivalRound() => state = _engine.runRivalRound(state: state, rivals: _rivals);

  /// Closing a lot changes purse and squad, so the save slot is refreshed
  /// immediately to keep the Load Game cards accurate.
  void closeLot() {
    final player = state.currentPlayer;
    final winnerId = state.leadingTeamId;
    state = _engine.closeLot(state);
    unawaited(_syncPlayerModels(state));
    if (player != null && winnerId == 'cpl' && state.phase == AuctionPhase.sold) {
      final franchiseBox = Hive.box<FranchiseModel>('franchises');
      final franchise = franchiseBox.get('cpl') ?? const FranchiseModel(id: 'cpl');
      final updated = franchise.copyWith(
        purseCrores: state.teams.firstWhere((team) => team.id == 'cpl').purseCr,
        squadIds: [...franchise.squadIds, if (!franchise.squadIds.contains(player.id)) player.id],
      );
      unawaited(franchiseBox.put('cpl', updated));
      final playersBox = Hive.box<PlayerModel>('players');
      final playerModel = PlayerModel(
        id: player.id, name: player.name, age: player.age, role: switch(player.role) {
          PlayerRole.batter => 'Batter', PlayerRole.bowler => 'Pace',
          PlayerRole.allRounder => 'AR', PlayerRole.wicketKeeper => 'WK',
        },
        batSkill: player.batting, bowlSkill: player.bowling, fielding: player.fielding,
        stamina: 80, form: player.form, nation: player.nation, isOverseas: player.isOverseas,
      );
      unawaited(playersBox.put(player.id, playerModel));
    }
    unawaited(CampaignStore.saveAuction(state));
  }
  void nextLot() => state = _engine.nextLot(state);
  void reset() => state = createDemoAuction();
}
