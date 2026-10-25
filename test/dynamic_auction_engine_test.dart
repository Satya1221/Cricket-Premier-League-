import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:cricket_premier_league/src/features/auction/domain/dynamic_auction_engine.dart';

void main() {
  test('role need and elite rating affect private max bid', () {
    final engine = DynamicAuctionEngine(random: Random(1));
    const player = AuctionPlayerProfile(
      id: 'wk1', name: 'Keeper', role: 'Wicket-Keeper', overallRating: 94, basePrice: 200,
    );
    final needy = AuctionFranchise(
      id: 'a', name: 'Needy', purse: 5000, neededRoles: ['Wicket-Keeper'], aggression: 1.2,
    );
    final covered = AuctionFranchise(
      id: 'b', name: 'Covered', purse: 5000, neededRoles: ['Bowler'], aggression: 1.2,
    );
    expect(engine.calculateMaxBid(player, needy), greaterThan(engine.calculateMaxBid(player, covered)));
  });

  test('team cannot spend more than purse and winner is charged once', () {
    final engine = DynamicAuctionEngine(random: Random(3));
    final a = AuctionFranchise(id: 'a', name: 'A', purse: 260, neededRoles: ['Batter'], aggression: 1.5);
    final b = AuctionFranchise(id: 'b', name: 'B', purse: 280, neededRoles: ['Batter'], aggression: 1.5);
    final before = a.purse + b.purse;
    final result = engine.runAuction(
      player: const AuctionPlayerProfile(id: 'p', name: 'Batter', role: 'Batter', overallRating: 90, basePrice: 100),
      franchises: [a, b],
    );
    expect(result.status, AuctionLotStatus.sold);
    expect(result.finalPrice, lessThanOrEqualTo(280));
    expect(a.purse + b.purse, before - result.finalPrice);
  });

  test('lot is unsold when no franchise can meet base price', () {
    final engine = DynamicAuctionEngine(random: Random(1));
    final team = AuctionFranchise(id: 'a', name: 'A', purse: 10, neededRoles: [], aggression: 0.8);
    final result = engine.runAuction(
      player: const AuctionPlayerProfile(id: 'p', name: 'Player', role: 'Bowler', overallRating: 80, basePrice: 50),
      franchises: [team],
    );
    expect(result.status, AuctionLotStatus.unsold);
    expect(team.purse, 10);
  });

  test('bid increments scale with current price', () {
    final engine = DynamicAuctionEngine(random: Random(1));
    expect(engine.incrementFor(199), 20);
    expect(engine.incrementFor(200), 50);
    expect(engine.incrementFor(999), 50);
    expect(engine.incrementFor(1000), 100);
  });
}
