import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cricket_premier_league/src/features/auction/auction_screen.dart';

void main() {
  testWidgets('auction screen renders the opening lot and core identity',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: AuctionScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('CRICKET PREMIER LEAGUE'), findsOneWidget);
    expect(find.text('LIVE AUCTION'), findsOneWidget);
    expect(find.text('Build a dynasty.'), findsOneWidget);
    expect(find.text('Aarav Sen'), findsOneWidget);
  });
}
