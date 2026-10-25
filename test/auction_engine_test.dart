import 'package:flutter_test/flutter_test.dart';
import 'package:cricket_premier_league/src/features/auction/data/demo_auction.dart';
import 'package:cricket_premier_league/src/features/auction/domain/auction_engine.dart';
import 'package:cricket_premier_league/src/features/auction/domain/auction_state.dart';

void main() {
  const engine = AuctionEngine();

  group('Auction engine', () {
    test('valuation is not below base price', () {
      final player = createDemoAuction().players.first;
      expect(engine.valuationCr(player), greaterThanOrEqualTo(player.basePriceCr));
    });

    test('bid increment ladder is stable', () {
      expect(engine.incrementFor(0.5), 0.05);
      expect(engine.incrementFor(1), 0.10);
      expect(engine.incrementFor(5), 0.20);
      expect(engine.incrementFor(10), 0.25);
      expect(engine.incrementFor(20), 0.50);
    });

    test('first bid starts at base price and sale updates purse exactly once', () {
      final initial = createDemoAuction();
      final bid = engine.placeBid(state: initial, teamId: 'cpl');
      expect(bid.currentBidCr, 2);
      expect(bid.leadingTeamId, 'cpl');
      final sold = engine.closeLot(bid);
      expect(sold.phase, AuctionPhase.sold);
      expect(sold.teams.first.purseCr, 118);
      expect(sold.teams.first.squad.single.basePriceCr, 2);
    });

    test('cannot bid after a lot has closed', () {
      final sold = engine.closeLot(engine.placeBid(state: createDemoAuction(), teamId: 'cpl'));
      expect(() => engine.placeBid(state: sold, teamId: 'roy'), throwsStateError);
    });

    test('full squad is prevented from bidding', () {
      final state = createDemoAuction();
      final original = state.teams.first;
      final full = original.copyWith(squad: List.filled(25, state.players.first));
      final updated = state.copyWith(teams: [full, ...state.teams.skip(1)]);
      expect(() => engine.placeBid(state: updated, teamId: 'cpl'), throwsStateError);
    });

    test('unsold player advances to next lot', () {
      final closed = engine.closeLot(createDemoAuction());
      expect(closed.phase, AuctionPhase.unsold);
      expect(engine.nextLot(closed).currentPlayerIndex, 1);
    });

    test('rival bid depends on its style and has a reason', () {
      final state = createDemoAuction();
      final player = state.players.first;
      final team = state.teams[1];
      final decision = engine.rivalDecision(
        player: player,
        team: team,
        rival: const RivalProfile(teamId: 'roy', style: RivalStyle.aggressive),
        currentBidCr: 1,
      );
      expect(decision.reason, isNotEmpty);
      expect(decision.nextBidCr, 1.1);
    });
  });
}
