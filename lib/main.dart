import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'src/core/game_feel.dart';
import 'src/features/game/presentation/main_menu_screen.dart';
import 'src/theme/game_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<dynamic>('career_saves');
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
        home: const MainMenuScreen(),
      );
}
