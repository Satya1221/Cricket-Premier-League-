import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cricket_premier_league/main.dart';

void main() {
  testWidgets('the new app renders its branded auction home', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: CricketPremierLeagueApp()));
    expect(find.text('CRICKET PREMIER LEAGUE'), findsOneWidget);
    expect(find.text('LIVE AUCTION'), findsOneWidget);
    expect(find.text('Build a dynasty.'), findsOneWidget);
  });
}
