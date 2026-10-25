import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/game_theme.dart';
import '../../auction/auction_screen.dart';
import '../../match/matchday_screen.dart';
import '../../match/presentation/field_editor_screen.dart';
import '../../squad/presentation/medical_screen.dart';
import '../../squad/presentation/squad_selection_screen.dart';
import '../../../../state/franchise_roster_provider.dart';
import 'academy_screen.dart';
import 'press_conference_dialog.dart';
import 'stadium_screen.dart';
import '../application/game_controller.dart';
import '../application/global_calendar_controller.dart';
import '../application/season_provider.dart';
import 'inbox_screen.dart';
import 'standings_screen.dart';
import 'trophy_room_screen.dart';
import 'first_match_tutorial_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(gameControllerProvider);
    final franchiseRoster = ref.watch(franchiseRosterProvider);
    final game = ref.read(gameControllerProvider.notifier);
    final calendar = ref.watch(globalCalendarProvider);
    final calendarController = ref.read(globalCalendarProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CRICKET PREMIER LEAGUE',
                style: TextStyle(
                  color: GamePalette.gold,
                  fontSize: 11,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w900,
                )),
            Text('FRANCHISE HQ',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
          ],
        ),
        actions: [
        IconButton(
          tooltip: 'Manager inbox',
          onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => const InboxScreen(),
          )),
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.mail_outline_rounded),
              if (calendar.unreadCount > 0)
                Positioned(
                  right: -7,
                  top: -6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
                    decoration: const BoxDecoration(
                      color: GamePalette.danger,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      calendar.unreadCount > 99 ? '99+' : '${calendar.unreadCount}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
            ],
          ),
        ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            FutureBuilder<dynamic>(
              future: Future<dynamic>.value(Hive.box<dynamic>('career_saves').get('ftue-complete')),
              builder: (context, snapshot) {
                if (snapshot.data == true) return const SizedBox.shrink();
                return _ActionTile(
                  icon: Icons.school_rounded,
                  title: 'FIRST-TIME TUTORIAL',
                  subtitle: 'Learn batting intent, field traps and pitch effects before managing your franchise.',
                  onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const FirstMatchTutorialScreen())),
                );
              },
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  colors: [Color(0xFF243047), Color(0xFF111827)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: GamePalette.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('YOUR FRANCHISE. YOUR LEGACY.',
                      style: TextStyle(
                        color: GamePalette.gold,
                        fontSize: 11,
                        letterSpacing: 1.3,
                        fontWeight: FontWeight.w900,
                      )),
                  const SizedBox(height: 12),
                  Text('SEASON ${session.seasonNumber}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      )),
                  const SizedBox(height: 8),
                  Text(_phaseLabel(session.phase),
                      style: const TextStyle(
                        color: GamePalette.emerald,
                        fontWeight: FontWeight.w800,
                      )),
                  const SizedBox(height: 14),
                  Text(session.lastAction,
                      style: const TextStyle(
                          color: Colors.white70, height: 1.4)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    label: 'SEASON',
                    value: '${session.seasonNumber}',
                    icon: Icons.calendar_month_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatTile(
                    label: 'MATCHES COMPLETED',
                    value: '${session.completedMatches}',
                    icon: Icons.sports_cricket_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: GamePalette.panel,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: GamePalette.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.public_rounded, color: GamePalette.gold),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'GLOBAL CALENDAR · ${calendar.month.name.toUpperCase()} ${calendar.year}',
                          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(calendar.lastTickSummary,
                      style: const TextStyle(color: Colors.white60, fontSize: 12)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: calendarController.advanceMonth,
                      icon: const Icon(Icons.fast_forward_rounded),
                      label: const Text('ADVANCE CALENDAR ONE MONTH'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text('GAME OPERATIONS',
                style: TextStyle(
                  color: GamePalette.gold,
                  fontSize: 12,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w900,
                )),
            const SizedBox(height: 10),
            _ActionTile(
              icon: Icons.gavel_rounded,
              title: 'PLAYER AUCTION',
              subtitle: 'Build your squad and manage the franchise purse.',
              onTap: () {
                game.startAuction();
                Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => const AuctionScreen(),
                ));
              },
            ),
            const SizedBox(height: 10),
            _ActionTile(
              icon: Icons.leaderboard_rounded,
              title: 'LEAGUE TABLE & SIMULATION',
              subtitle: 'View points, NRR and simulate other franchises’ fixtures.',
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => const StandingsScreen(),
              )),
            ),
            const SizedBox(height: 10),
            _ActionTile(
              icon: Icons.emoji_events_rounded,
              title: 'TROPHY ROOM & CAREER RECORDS',
              subtitle: 'All-time run scorers, wicket takers and match run-rate analytics.',
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const TrophyRoomScreen())),
            ),
            const SizedBox(height: 10),
            _ActionTile(
              icon: Icons.groups_rounded,
              title: 'SQUAD & PLAYING XI',
              subtitle: 'Select and validate 11 owned players before matchday.',
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SquadSelectionScreen())),
            ),
            const SizedBox(height: 10),
            _ActionTile(
              icon: Icons.sports_cricket_rounded,
              title: 'MATCHDAY',
              subtitle: 'Play deliveries and manage batting intent.',
              onTap: () {
                if (franchiseRoster.playingXI.length != 11) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Select and validate your Playing XI before entering Matchday.')),
                  );
                  Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (_) => const SquadSelectionScreen(),
                  ));
                  return;
                }
                if (session.phase == GamePhase.preSeason || session.phase == GamePhase.auction) {
                  game.startSeason();
                }
                Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => const MatchdayScreen(),
                ));
              },
            ),
            const SizedBox(height: 10),
            _ActionTile(
              icon: Icons.health_and_safety_rounded,
              title: 'MEDICAL CENTER',
              subtitle: 'Review workload risk, injuries and recovery.',
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const MedicalCenterScreen())),
            ),
            const SizedBox(height: 10),
            _ActionTile(
              icon: Icons.account_balance_rounded,
              title: 'ACADEMY & COACHING',
              subtitle: 'Upgrade training facilities and hire specialist coaches.',
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AcademyScreen())),
            ),
            const SizedBox(height: 10),
            _ActionTile(
              icon: Icons.sports_cricket_rounded,
              title: 'FIELD PLACEMENT',
              subtitle: 'Arrange fielders on the oval and set tactical roles.',
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const FieldEditorScreen())),
            ),
            const SizedBox(height: 10),
            _ActionTile(
              icon: Icons.stadium_rounded,
              title: 'STADIUM & PITCH',
              subtitle: 'Choose home conditions, upgrade capacity and earn ticket revenue.',
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const StadiumScreen())),
            ),
            const SizedBox(height: 10),
            _ActionTile(
              icon: Icons.mic_none_rounded,
              title: 'PRESS CONFERENCE',
              subtitle: 'Respond to the media and influence morale.',
              onTap: () => showPressConference(context),
            ),
            const SizedBox(height: 10),
            if (session.phase == GamePhase.season)
              _ActionTile(
                icon: Icons.flag_rounded,
                title: 'END SEASON',
                subtitle: 'Move the game into the off-season.',
                onTap: () => _runAction(context, game.endSeason),
              ),
            if (session.phase == GamePhase.postSeason)
              _ActionTile(
                icon: Icons.autorenew_rounded,
                title: 'START NEXT SEASON',
                subtitle: 'Advance the season counter and reset match count.',
                onTap: game.beginNextSeason,
              ),
            if (session.phase == GamePhase.season)
              _ActionTile(
                icon: Icons.check_circle_outline_rounded,
                title: 'RECORD MATCH COMPLETED',
                subtitle: 'Update the central season tracker.',
                onTap: () => _recordMatchAndSimulateWeek(context, ref, game),
              ),
            const SizedBox(height: 14),
            const Text(
              'Season state, fixture schedule and results are stored locally. AI fixtures in the active week can be simulated from the league table.',
              style: TextStyle(color: Colors.white54, height: 1.4, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _recordMatchAndSimulateWeek(
    BuildContext context,
    WidgetRef ref,
    GameController game,
  ) async {
    try {
      game.recordMatchCompleted();
      await ref.read(seasonProvider.notifier).simulateMatchWeek();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Match recorded and remaining fixtures in this week simulated.')),
        );
      }
    } on StateError catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
    }
  }

  static String _phaseLabel(GamePhase phase) => switch (phase) {
        GamePhase.preSeason => 'PRE-SEASON',
        GamePhase.auction => 'AUCTION PHASE',
        GamePhase.season => 'SEASON IN PROGRESS',
        GamePhase.postSeason => 'OFF-SEASON',
      };

  static void _runAction(BuildContext context, VoidCallback action) {
    try {
      action();
    } on StateError catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: GamePalette.panel,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: GamePalette.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: GamePalette.gold),
            const SizedBox(height: 12),
            Text(value,
                style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    color: Colors.white)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white60,
                    fontWeight: FontWeight.w800)),
          ],
        ),
      );
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: GamePalette.panel,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: GamePalette.gold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, color: GamePalette.gold),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Text(subtitle,
                          style: const TextStyle(
                              color: Colors.white60, height: 1.3)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: Colors.white54),
              ],
            ),
          ),
        ),
      );
}
