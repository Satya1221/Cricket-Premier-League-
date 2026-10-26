import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'src/core/game_feel.dart';
import 'src/features/game/data/campaign_store.dart';
import 'services/storage_service.dart';
import 'src/features/game/presentation/main_menu_screen.dart';
import 'src/theme/game_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await StorageService.initialize();
  await Hive.openBox<dynamic>('career_saves');
  await Hive.openBox<dynamic>('game_state');
  await Hive.openBox<dynamic>('season_schedule');
  await Hive.openBox<dynamic>('franchise_roster');
  await Hive.openBox<dynamic>('history_records');
  await CampaignStore.initialize();
  await GameFeel.init();
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
