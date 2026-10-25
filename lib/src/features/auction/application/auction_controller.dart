import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/demo_auction.dart';
import '../domain/auction_engine.dart';
import '../domain/auction_state.dart';
import '../domain/player.dart';

final auctionControllerProvider =
    NotifierProvider<AuctionController, AuctionState>(AuctionController.new);

class AuctionController extends Notifier<AuctionState> {
  final AuctionEngine _engine = const AuctionEngine();

  @override
  AuctionState build() => createDemoAuction();

  void bidFor(String teamId) => state = _engine.placeBid(state: state, teamId: teamId);
  void runRivalRound() {
    const rivals = [
      RivalProfile(teamId: 'roy', style: RivalStyle.aggressive, aggression: 0.82),
      RivalProfile(teamId: 'tit', style: RivalStyle.budgetGuardian, aggression: 0.42),
      RivalProfile(
        teamId: 'fal',
        style: RivalStyle.youthFirst,
        aggression: 0.68,
        targetRoles: {PlayerRole.batter, PlayerRole.allRounder},
      ),
    ];
    state = _engine.runRivalRound(state: state, rivals: rivals);
  }

  void closeLot() => state = _engine.closeLot(state);
  void nextLot() => state = _engine.nextLot(state);
  void reset() => state = createDemoAuction();
}
