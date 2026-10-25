import 'dart:async';

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
  AuctionState build() => createDemoAuction();

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
    state = _engine.closeLot(state);
    unawaited(CampaignStore.saveAuction(state));
  }
  void nextLot() => state = _engine.nextLot(state);
  void reset() => state = createDemoAuction();
}
