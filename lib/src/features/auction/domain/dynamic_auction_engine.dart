import 'dart:math';

/// Pure Dart auction models. All prices and purses use one consistent unit
/// (for example, thousands of dollars or lakhs of rupees).
class AuctionPlayerProfile {
  const AuctionPlayerProfile({
    required this.id,
    required this.name,
    required this.role,
    required this.overallRating,
    required this.basePrice,
  }) : assert(overallRating >= 1 && overallRating <= 100),
       assert(basePrice >= 0);

  final String id;
  final String name;
  final String role;
  final int overallRating;
  final int basePrice;
}

class AuctionFranchise {
  AuctionFranchise({
    required this.id,
    required this.name,
    required this.purse,
    required this.neededRoles,
    required this.aggression,
    this.isHuman = false,
  }) : assert(purse >= 0), assert(aggression >= 0.1 && aggression <= 2.0);

  final String id;
  final String name;
  int purse;
  final List<String> neededRoles;
  final double aggression;
  /// True for the user-controlled franchise in terminal or interactive UI flows.
  final bool isHuman;
}

enum AuctionLotStatus { sold, unsold }

class AuctionBidRecord {
  const AuctionBidRecord({
    required this.franchiseId,
    required this.franchiseName,
    required this.amount,
  });

  final String franchiseId;
  final String franchiseName;
  final int amount;
}

class DynamicAuctionResult {
  const DynamicAuctionResult({
    required this.player,
    required this.status,
    required this.finalPrice,
    required this.winner,
    required this.bidHistory,
    required this.privateMaxBids,
  });

  final AuctionPlayerProfile player;
  final AuctionLotStatus status;
  final int finalPrice;
  final AuctionFranchise? winner;
  final List<AuctionBidRecord> bidHistory;

  /// Internal simulation diagnostics. Never expose this map in player-facing UI.
  final Map<String, int> privateMaxBids;
}

class DynamicAuctionEngine {
  DynamicAuctionEngine({Random? random}) : _random = random ?? Random();

  final Random _random;

  int calculateMaxBid(AuctionPlayerProfile player, AuctionFranchise team) {
    if (team.purse < player.basePrice) return 0;
    // Human franchises are limited by their purse, not a hidden CPU valuation.
    if (team.isHuman) return team.purse;
    var ratingMultiplier = player.overallRating / 80.0;
    if (player.overallRating >= 90) ratingMultiplier *= 1.8;
    final roleMultiplier = team.neededRoles.contains(player.role) ? 1.6 : 0.6;
    final theoretical = (player.basePrice * ratingMultiplier * roleMultiplier * team.aggression).floor();
    return min(theoretical, team.purse);
  }

  int incrementFor(int currentPrice) {
    if (currentPrice < 200) return 20;
    if (currentPrice < 1000) return 50;
    return 100;
  }

  DynamicAuctionResult runAuction({
    required AuctionPlayerProfile player,
    required List<AuctionFranchise> franchises,
  }) {
    final maxBids = <String, int>{
      for (final team in franchises) team.id: calculateMaxBid(player, team),
    };
    final active = franchises
        .where((team) => maxBids[team.id]! >= player.basePrice)
        .toList()
      ..shuffle(_random);
    final history = <AuctionBidRecord>[];
    var currentBid = player.basePrice;
    AuctionFranchise? leader;
    var cursor = 0;
    var guard = 0;

    while (active.length > 1 && guard++ < 10000) {
      if (cursor >= active.length) cursor = 0;
      final team = active[cursor];
      if (identical(team, leader)) {
        cursor++;
        continue;
      }
      final increment = incrementFor(currentBid);
      final nextBid = currentBid + increment;
      final maxBid = maxBids[team.id]!;
      if (nextBid <= team.purse && nextBid <= maxBid) {
        currentBid = nextBid;
        leader = team;
        history.add(AuctionBidRecord(
          franchiseId: team.id,
          franchiseName: team.name,
          amount: currentBid,
        ));
        // Start another round from the next active franchise.
        cursor = 0;
      } else {
        active.removeAt(cursor);
      }
    }

    if (leader == null) {
      return DynamicAuctionResult(
        player: player,
        status: AuctionLotStatus.unsold,
        finalPrice: 0,
        winner: null,
        bidHistory: List.unmodifiable(history),
        privateMaxBids: Map.unmodifiable(maxBids),
      );
    }

    // A franchise must still be able to settle the final amount.
    if (leader.purse < currentBid) {
      return DynamicAuctionResult(
        player: player,
        status: AuctionLotStatus.unsold,
        finalPrice: 0,
        winner: null,
        bidHistory: List.unmodifiable(history),
        privateMaxBids: Map.unmodifiable(maxBids),
      );
    }
    leader.purse -= currentBid;
    return DynamicAuctionResult(
      player: player,
      status: AuctionLotStatus.sold,
      finalPrice: currentBid,
      winner: leader,
      bidHistory: List.unmodifiable(history),
      privateMaxBids: Map.unmodifiable(maxBids),
    );
  }
}

void main() {
  final engine = DynamicAuctionEngine();
  final franchises = [
    AuctionFranchise(id: 'mum', name: 'Mumbai Mavericks', purse: 5000,
      neededRoles: ['All-Rounder', 'Bowler'], aggression: 1.4),
    AuctionFranchise(id: 'che', name: 'Chennai Super Kings', purse: 4000,
      neededRoles: ['All-Rounder', 'Batter'], aggression: 1.1),
    AuctionFranchise(id: 'del', name: 'Delhi Dashers', purse: 8000,
      neededRoles: ['Batter', 'Wicket-Keeper'], aggression: 0.9),
  ];
  final lots = [
    const AuctionPlayerProfile(id: 'p1', name: 'Demo All-Rounder',
      role: 'All-Rounder', overallRating: 94, basePrice: 200),
    const AuctionPlayerProfile(id: 'p2', name: 'Demo Batter',
      role: 'Batter', overallRating: 72, basePrice: 20),
  ];

  for (final player in lots) {
    print('\n--- ON THE BLOCK: ${player.name} (${player.role}, OVR ${player.overallRating}) ---');
    print('Base price: ${player.basePrice}');
    final result = engine.runAuction(player: player, franchises: franchises);
    for (final bid in result.bidHistory) {
      print('${bid.franchiseName} bids ${bid.amount}');
    }
    if (result.status == AuctionLotStatus.sold) {
      print('SOLD: ${player.name} to ${result.winner!.name} for ${result.finalPrice}');
    } else {
      print('UNSOLD: no franchise bid above the base price');
    }
    for (final team in franchises) {
      print('${team.name} purse remaining: ${team.purse}');
    }
  }
}
