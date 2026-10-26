import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cricket_premier_league/src/features/auction/auction_screen.dart';
import 'package:cricket_premier_league/src/features/auction/application/auction_controller.dart';
import 'package:cricket_premier_league/src/features/auction/data/initial_auction.dart';
import 'package:cricket_premier_league/src/features/auction/domain/auction_state.dart';

class _TestAuctionController extends AuctionController {
  @override
  AuctionState build() => createInitialAuction();
}

void main() {
  testWidgets('auction screen renders the opening lot and core identity',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          auctionControllerProvider.overrideWith(_TestAuctionController.new),
        ],
        child: const MaterialApp(home: AuctionScreen()),
      ),
    );

    expect(find.text('CRICKET PREMIER LEAGUE'), findsOneWidget);
    expect(find.text('LIVE AUCTION'), findsOneWidget);
    expect(find.text('Build a dynasty.'), findsOneWidget);
    expect(find.text('Rohit Sharma'), findsOneWidget);
  });
}
