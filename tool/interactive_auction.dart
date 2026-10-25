import 'dart:io';

import 'package:cricket_premier_league/src/features/auction/domain/dynamic_auction_engine.dart';

/// Terminal adapter for the shared auction models.
/// Run with: dart run tool/interactive_auction.dart
class InteractiveAuctionRoom {
  static void runAuction({
    required AuctionPlayerProfile player,
    required List<AuctionFranchise> franchises,
    required DynamicAuctionEngine engine,
    Duration cpuDelay = const Duration(milliseconds: 800),
  }) {
    stdout.writeln('\n=======================================================');
    stdout.writeln('ON THE BLOCK: ${player.name} (${player.role} | OVR: ${player.overallRating})');
    stdout.writeln('Base price: ${player.basePrice}');
    stdout.writeln('=======================================================\n');

    var currentBid = player.basePrice;
    AuctionFranchise? leader;
    final active = franchises
        .where((team) => team.isHuman
            ? team.purse >= player.basePrice
            : engine.calculateMaxBid(player, team) >= player.basePrice)
        .toList()
      ..sort((a, b) {
        if (a.isHuman == b.isHuman) return 0;
        return a.isHuman ? -1 : 1;
      });

    if (active.isEmpty) {
      stdout.writeln('UNSOLD: no franchise can meet the base price.');
      return;
    }

    final history = <AuctionBidRecord>[];
    var cursor = 0;
    var safetyCounter = 0;

    while (active.isNotEmpty && safetyCounter++ < 10000) {
      if (leader != null && active.length <= 1) break;
      if (cursor >= active.length) cursor = 0;

      final team = active[cursor];
      if (identical(team, leader)) {
        cursor++;
        continue;
      }

      final nextBid = leader == null
          ? player.basePrice
          : currentBid + engine.incrementFor(currentBid);

      if (team.purse < nextBid) {
        stdout.writeln('${team.name} cannot afford \$nextBid and drops out.');
        active.removeAt(cursor);
        continue;
      }

      if (team.isHuman) {
        stdout.writeln('\nCurrent bid: \$currentBid (${leader?.name ?? 'No bids yet'})');
        stdout.writeln('Your purse: ${team.purse}');
        stdout.write('Bid \$nextBid? (y/n): ');
        final input = stdin.readLineSync()?.trim().toLowerCase();

        if (input == 'y' || input == 'yes') {
          currentBid = nextBid;
          leader = team;
          history.add(AuctionBidRecord(
            franchiseId: team.id,
            franchiseName: team.name,
            amount: currentBid,
          ));
          stdout.writeln('YOU bid \$currentBid!');
          cursor = 0;
          continue;
        }

        stdout.writeln('You drop out.');
        active.removeAt(cursor);
        continue;
      }

      sleep(cpuDelay);
      final maxBid = engine.calculateMaxBid(player, team);
      if (nextBid <= maxBid && nextBid <= team.purse) {
        currentBid = nextBid;
        leader = team;
        history.add(AuctionBidRecord(
          franchiseId: team.id,
          franchiseName: team.name,
          amount: currentBid,
        ));
        stdout.writeln('${team.name} bids \$currentBid');
        cursor = 0;
      } else {
        stdout.writeln('${team.name} drops out.');
        active.removeAt(cursor);
      }
    }

    if (leader == null) {
      stdout.writeln('\nUNSOLD: nobody placed a bid.');
      return;
    }

    leader.purse -= currentBid;
    stdout.writeln('\nSOLD: ${player.name} to ${leader.name} for \$currentBid.');
    stdout.writeln('Remaining purses:');
    for (final team in franchises) {
      stdout.writeln('  ${team.name}: ${team.purse}');
    }
  }
}

void main() {
  final engine = DynamicAuctionEngine();
  final userTeam = AuctionFranchise(
    id: 'user',
    name: 'YOUR TEAM',
    purse: 6000,
    neededRoles: ['Batter', 'Bowler'],
    aggression: 1.0,
    isHuman: true,
  );
  final mumbai = AuctionFranchise(
    id: 'mum',
    name: 'Mumbai Mavericks',
    purse: 5000,
    neededRoles: ['All-Rounder', 'Bowler'],
    aggression: 1.4,
  );
  final chennai = AuctionFranchise(
    id: 'che',
    name: 'Chennai Super Kings',
    purse: 4000,
    neededRoles: ['Batter'],
    aggression: 1.1,
  );
  final teams = [userTeam, mumbai, chennai];
  final lots = [
    const AuctionPlayerProfile(
      id: 'p1',
      name: 'Ben Stokes',
      role: 'All-Rounder',
      overallRating: 94,
      basePrice: 200,
    ),
    const AuctionPlayerProfile(
      id: 'p2',
      name: 'Rajat Patidar',
      role: 'Batter',
      overallRating: 72,
      basePrice: 20,
    ),
  ];

  stdout.writeln('Pre-auction purses:');
  for (final team in teams) {
    stdout.writeln('${team.name}: ${team.purse}');
  }

  for (final player in lots) {
    InteractiveAuctionRoom.runAuction(
      player: player,
      franchises: teams,
      engine: engine,
    );
  }
}
