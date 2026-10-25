import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/game_theme.dart';
import 'domain/delivery_resolution_engine.dart';
import 'domain/format_config.dart';
import 'domain/living_pitch.dart' as pitch;

@immutable
class MatchdayState {
  const MatchdayState({
    this.runs = 42, this.wickets = 2, this.balls = 36, this.target = 178,
    this.strikerRuns = 26, this.strikerBalls = 18, this.bowlerRuns = 19,
    this.bowlerWickets = 1, this.concentration = .72, this.stamina = .84,
    this.intent = BatterIntent.rotate,
    this.recent = const ['1', '4', '0', 'W', '2', '1'],
    this.commentary = 'A sharp single keeps the scoreboard moving.',
    this.complete = false,
    this.format = CricketFormat.t20,
  });
  final int runs, wickets, balls, target, strikerRuns, strikerBalls, bowlerRuns, bowlerWickets;
  final double concentration, stamina;
  final BatterIntent intent;
  final List<String> recent;
  final String commentary;
  final bool complete;
  final CricketFormat format;
  FormatConfig get config => FormatConfig.forFormat(format);
  int get ballsLeft => max(0, config.legalBallsPerInnings - balls);
  int get runsNeeded => max(0, target - runs);
  String get overs => '${balls ~/ config.ballsPerOver}.${balls % config.ballsPerOver}';
  double get crr => balls == 0 ? 0 : runs * 6 / balls;
  MatchdayState copyWith({int? runs, int? wickets, int? balls, int? strikerRuns, int? strikerBalls,
    int? bowlerRuns, int? bowlerWickets, double? concentration, double? stamina,
    BatterIntent? intent, List<String>? recent, String? commentary, bool? complete, CricketFormat? format}) =>
    MatchdayState(runs: runs ?? this.runs, wickets: wickets ?? this.wickets,
      balls: balls ?? this.balls, target: target, strikerRuns: strikerRuns ?? this.strikerRuns,
      strikerBalls: strikerBalls ?? this.strikerBalls, bowlerRuns: bowlerRuns ?? this.bowlerRuns,
      bowlerWickets: bowlerWickets ?? this.bowlerWickets, concentration: concentration ?? this.concentration,
      stamina: stamina ?? this.stamina, intent: intent ?? this.intent, recent: recent ?? this.recent,
      commentary: commentary ?? this.commentary, complete: complete ?? this.complete, format: format ?? this.format);
}

final matchProvider = StateNotifierProvider<MatchdayController, MatchdayState>((ref) => MatchdayController());

class MatchdayController extends StateNotifier<MatchdayState> {
  MatchdayController() : super(const MatchdayState());
  final _random = Random();
  final _environment = pitch.MatchEnvironment(pitchType: pitch.PitchType.dusty, weather: pitch.Weather.sunny);
  late final _batter = ResolutionBatter(name: 'A. Mehta', baseTiming: 76, baseDefense: 71, concentration: .72);
  late final _bowler = ResolutionBowler(name: 'R. Khan', baseAccuracy: 79, baseMovement: 82, isSpinner: true, stamina: .84);

  void setIntent(BatterIntent intent) => state = state.copyWith(intent: intent);
  void setFormat(CricketFormat format) {
    _environment.pitchWear = format == CricketFormat.test ? 0.1 : 0.5;
    _environment.ballAgeOvers = 0;
    _batter.concentration = .72;
    _bowler.stamina = .84;
    state = MatchdayState(format: format, target: format == CricketFormat.test ? 350 : format == CricketFormat.odi ? 280 : format == CricketFormat.hundred ? 145 : 178, runs: 0, wickets: 0, balls: 0, strikerRuns: 0, strikerBalls: 0, bowlerRuns: 0, bowlerWickets: 0, concentration: .72, stamina: .84, recent: const [], commentary: '${format.name.toUpperCase()} match initialized.');
  }
  void playNextBall() {
    if (state.complete) return;
    final env = MatchEnvironment(
      pitchType: _environment.pitchType == pitch.PitchType.dusty ? PitchType.dusty : _environment.pitchType == pitch.PitchType.flat ? PitchType.flat : PitchType.green,
      weather: _environment.weather == pitch.Weather.overcast ? Weather.overcast : Weather.sunny);
    final result = DeliveryResolutionEngine(random: _random).resolve(
      environment: env, bowler: _bowler, batter: _batter, intent: state.intent);
    final wicket = result.outcome == DeliveryOutcomeType.wicket;
    final scored = switch (result.outcome) {
      DeliveryOutcomeType.wicket || DeliveryOutcomeType.dot => 0,
      DeliveryOutcomeType.one => 1, DeliveryOutcomeType.two => 2,
      DeliveryOutcomeType.four => 4, DeliveryOutcomeType.six => 6,
    };
    final balls = state.balls + 1;
    final runs = state.runs + scored;
    final wickets = state.wickets + (wicket ? 1 : 0);
    final recent = [...state.recent, wicket ? 'W' : scored.toString()];
    if (recent.length > 6) recent.removeAt(0);
    state = state.copyWith(runs: runs, wickets: wickets, balls: balls,
      strikerRuns: state.strikerRuns + scored, strikerBalls: state.strikerBalls + 1,
      bowlerRuns: state.bowlerRuns + scored, bowlerWickets: state.bowlerWickets + (wicket ? 1 : 0),
      concentration: _batter.concentration, stamina: _bowler.stamina, recent: recent,
      commentary: '${result.commentary} Intent: ${state.intent.name.toUpperCase()}. Batter control ${result.batterControl.toStringAsFixed(0)} vs bowler threat ${result.bowlerThreat.toStringAsFixed(0)}.',
      complete: wickets >= 10 || balls >= 120 || runs >= state.target);
    if (balls % 6 == 0) _environment.advanceOver();
  }
  void resetMatch() {
    _environment.pitchWear = 0; _environment.ballAgeOvers = 0;
    _batter.concentration = .72; _bowler.stamina = .84;
    state = MatchdayState(format: state.format, target: state.format == CricketFormat.test ? 350 : state.format == CricketFormat.odi ? 280 : state.format == CricketFormat.hundred ? 145 : 178, runs: 0, wickets: 0, balls: 0, strikerRuns: 0, strikerBalls: 0, bowlerRuns: 0, bowlerWickets: 0, concentration: .72, stamina: .84, recent: const [], commentary: '${state.format.name.toUpperCase()} match reset.');
  }
}

class MatchdayScreen extends ConsumerWidget {
  const MatchdayScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(matchProvider);
    final actions = ref.read(matchProvider.notifier);
    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      appBar: AppBar(backgroundColor: Colors.transparent, centerTitle: true,
        title: Text('${s.format.name.toUpperCase()} MATCH', style: const TextStyle(letterSpacing: 2, color: Colors.white70, fontSize: 14)),
        actions: [PopupMenuButton<CricketFormat>(tooltip: 'Match format', onSelected: actions.setFormat, itemBuilder: (_) => CricketFormat.values.map((format) => PopupMenuItem(value: format, child: Text(format.name.toUpperCase()))).toList()), IconButton(onPressed: actions.resetMatch, icon: const Icon(Icons.restart_alt), tooltip: 'Reset match')]),
      body: SafeArea(child: Column(children: [
        _Scoreboard(state: s),
        Expanded(child: ListView(padding: const EdgeInsets.symmetric(horizontal: 16), children: [
          _RecentBalls(balls: s.recent),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _PlayerCard(name: 'A. Mehta', label: 'STRIKER', stats: '${s.strikerRuns} (${s.strikerBalls})', energy: s.concentration, batter: true)),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('VS', style: TextStyle(color: Colors.white38, fontWeight: FontWeight.w900))),
            Expanded(child: _PlayerCard(name: 'R. Khan', label: 'BOWLER', stats: '${s.bowlerWickets}-${s.bowlerRuns}', energy: s.stamina, batter: false)),
          ]),
          const SizedBox(height: 16),
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(14)),
            child: Text(s.commentary, key: ValueKey(s.commentary), style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic, height: 1.4))
              .animate().fadeIn(duration: 250.ms).slideX(begin: .08, end: 0)),
          const SizedBox(height: 12),
          _Analytics(label: 'Batter concentration', value: s.concentration),
          _Analytics(label: 'Bowler stamina', value: s.stamina),
          const SizedBox(height: 16),
        ])),
        _TacticalDesk(state: s, onIntent: actions.setIntent, onPlay: actions.playNextBall),
      ])),
    );
  }
}

class _Scoreboard extends StatelessWidget {
  const _Scoreboard({required this.state});
  final MatchdayState state;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(16, 8, 16, 12), padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: const Color(0xFF1C2541), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10),
      boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 5))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('CPL TITANS', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
        Text('CRR ${state.crr.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white60)),
      ]),
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text('${state.runs}/${state.wickets}', style: const TextStyle(fontSize: 52, height: 1, fontWeight: FontWeight.w900, color: GamePalette.gold)),
        Text('OV ${state.overs}', style: const TextStyle(fontSize: 18, color: Colors.white70, fontWeight: FontWeight.w700)),
      ]),
      const Divider(color: Colors.white12, height: 22),
      Text(state.complete ? 'INNINGS COMPLETE' : 'NEED ${state.runsNeeded} OFF ${state.ballsLeft} BALLS',
        style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.w900, letterSpacing: .5)),
    ]));
}

class _RecentBalls extends StatelessWidget {
  const _RecentBalls({required this.balls});
  final List<String> balls;
  @override
  Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.end, children: [
    const Spacer(), const Text('LAST 6', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900)),
    const SizedBox(width: 8),
    for (var i = 0; i < balls.length; i++)
      Padding(padding: const EdgeInsets.only(left: 5), child: Container(width: 32, height: 32, alignment: Alignment.center,
        decoration: BoxDecoration(shape: BoxShape.circle, color: balls[i] == 'W' ? Colors.redAccent : (balls[i] == '4' || balls[i] == '6' ? Colors.green : Colors.white12)),
        child: Text(balls[i], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)))
        .animate(key: ValueKey('${i}-${balls[i]}')).scale(curve: Curves.elasticOut, duration: 350.ms)),
  ]);
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({required this.name, required this.label, required this.stats, required this.energy, required this.batter});
  final String name, label, stats;
  final double energy;
  final bool batter;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: .05), borderRadius: BorderRadius.circular(15),
      border: Border(left: BorderSide(color: batter ? Colors.blueAccent : Colors.redAccent, width: 4))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(color: batter ? Colors.lightBlueAccent : Colors.redAccent, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
      const SizedBox(height: 5),
      Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
      const SizedBox(height: 3), Text(stats, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      const SizedBox(height: 10),
      LinearProgressIndicator(value: energy.clamp(0, 1), backgroundColor: Colors.black45, color: energy > .7 ? Colors.greenAccent : Colors.orangeAccent, minHeight: 4),
    ]));
}

class _Analytics extends StatelessWidget {
  const _Analytics({required this.label, required this.value});
  final String label; final double value;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(children: [
    Expanded(child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12))),
    SizedBox(width: 100, child: LinearProgressIndicator(value: value.clamp(0, 1), minHeight: 5, backgroundColor: Colors.white12)),
    const SizedBox(width: 8), Text('${(value * 100).round()}%', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)),
  ]));
}

class _TacticalDesk extends StatelessWidget {
  const _TacticalDesk({required this.state, required this.onIntent, required this.onPlay});
  final MatchdayState state; final ValueChanged<BatterIntent> onIntent; final VoidCallback onPlay;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
    decoration: const BoxDecoration(color: Color(0xFF1C2541), borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
    child: Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('TACTICAL INTENT', style: TextStyle(color: Colors.white60, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: .8)),
        Text(state.intent.name.toUpperCase(), style: const TextStyle(color: GamePalette.gold, fontWeight: FontWeight.w900, fontSize: 11)),
      ]),
      const SizedBox(height: 10),
      SizedBox(width: double.infinity, child: SegmentedButton<BatterIntent>(
        segments: const [
          ButtonSegment(value: BatterIntent.defend, label: Text('DEFEND')),
          ButtonSegment(value: BatterIntent.rotate, label: Text('ROTATE')),
          ButtonSegment(value: BatterIntent.slog, label: Text('SLOG')),
        ],
        selected: {state.intent}, onSelectionChanged: (selection) => onIntent(selection.first),
        style: SegmentedButton.styleFrom(backgroundColor: Colors.white10, foregroundColor: Colors.white70,
          selectedForegroundColor: Colors.black, selectedBackgroundColor: GamePalette.gold))),
      const SizedBox(height: 12),
      SizedBox(width: double.infinity, height: 56, child: ElevatedButton.icon(
        onPressed: state.complete ? null : onPlay, icon: const Icon(Icons.sports_cricket),
        label: Text(state.complete ? 'INNINGS COMPLETE' : 'PLAY NEXT DELIVERY', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
        style: ElevatedButton.styleFrom(backgroundColor: GamePalette.emerald, foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))))),
    ]));
}
