import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/demo_auction.dart';
import '../domain/auction_engine.dart';
import '../domain/auction_state.dart';

final auctionControllerProvider =
    NotifierProvider<AuctionController, AuctionState>(AuctionController.new);

class AuctionController extends Notifier<AuctionState> {
  final AuctionEngine _engine = const AuctionEngine();

  @override
  AuctionState build() => createDemoAuction();

  void bidFor(String teamId) => state = _engine.placeBid(state: state, teamId: teamId);
  void closeLot() => state = _engine.closeLot(state);
  void nextLot() => state = _engine.nextLot(state);
  void reset() => state = createDemoAuction();
}
