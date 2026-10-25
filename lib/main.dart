import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/core/game_feel.dart';
import 'src/features/auction/auction_screen.dart';
import 'src/theme/game_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  GameFeel.init();
  runApp(const ProviderScope(child: CricketPremierLeagueApp()));
}

class CricketPremierLeagueApp extends StatelessWidget {
  const CricketPremierLeagueApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Cricket Premier League',
        debugShowCheckedModeBanner: false,
        theme: GameTheme.dark,
        home: const AuctionScreen(),
      );
}
