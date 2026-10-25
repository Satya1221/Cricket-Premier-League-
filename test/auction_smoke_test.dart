import 'package:flutter_test/flutter_test.dart';
import 'package:cricket_premier_league/main.dart';

void main() {
  testWidgets('auction home renders core identity and demo lot', (tester) async {
    await tester.pumpWidget(const CricketPremierLeagueApp());
    expect(find.text('CRICKET PREMIER LEAGUE'), findsOneWidget);
    expect(find.text('LIVE AUCTION'), findsOneWidget);
    expect(find.text('Aarav Sen'), findsOneWidget);
    expect(find.text('FRANCHISE WAR ROOM'), findsOneWidget);
  });
}
