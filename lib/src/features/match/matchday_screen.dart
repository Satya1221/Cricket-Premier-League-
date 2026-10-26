import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/game_theme.dart';
import 'domain/delivery_resolution_engine.dart';
import 'domain/bowling_angle_engine.dart';
import 'domain/format_config.dart';
import 'domain/living_pitch.dart' as pitch;
import 'domain/stadium_pitch_engine.dart';
import '../game/application/stadium_provider.dart';
import 'ipl_match_controller_screen.dart';

@immutable
class MatchdayState {
  const MatchdayState({
    this.runs = 42, this.wickets = 2, this.balls = 36, this.target = 178,
    this.strikerRuns = 26, this.strikerBalls = 18, this.bowlerRuns = 19,
    this.bowlerWickets = 1, this.concentration = .72, this.stamina = .84,
    this.intent = BatterIntent.rotate,
    this.creasePosition = CreasePosition.roundTheWicket,
    this.bowlingArm = BowlingArm.rightArm,
    this.bowlingStyle = BowlingStyleCode.offSpin,
    this.batterStance = BatterStance.leftHanded,
    this.bowlingLine = BowlingLine.offStump,
    this.bowlingLength = BowlingLength.goodLength,
    this.bowlingVariation = BowlingVariation.outswinger,
    this.fieldTrap = FieldTrap.packedOffSide,
    this.recent = const ['1', '4', '0', 'W', '2', '1'],
    this.commentary = 'A sharp single keeps the scoreboard moving.',
    this.complete = false,
    this.format = CricketFormat.t20,
  });
  final int runs, wickets, balls, target, strikerRuns, strikerBalls, bowlerRuns, bowlerWickets;
  final double concentration, stamina;
  final BatterIntent intent;
  final CreasePosition creasePosition;
  final BowlingArm bowlingArm;
  final BowlingStyleCode bowlingStyle;
  final BatterStance batterStance;
  final BowlingLine bowlingLine;
  final BowlingLength bowlingLength;
  final BowlingVariation bowlingVariation;
  final FieldTrap fieldTrap;
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
    BatterIntent? intent, CreasePosition? creasePosition, BowlingArm? bowlingArm,
    BowlingStyleCode? bowlingStyle, BatterStance? batterStance, BowlingLine? bowlingLine,
    BowlingLength? bowlingLength, BowlingVariation? bowlingVariation, FieldTrap? fieldTrap,
    List<String>? recent, String? commentary, bool? complete, CricketFormat? format}) =>
    MatchdayState(runs: runs ?? this.runs, wickets: wickets ?? this.wickets,
      balls: balls ?? this.balls, target: target, strikerRuns: strikerRuns ?? this.strikerRuns,
      strikerBalls: strikerBalls ?? this.strikerBalls, bowlerRuns: bowlerRuns ?? this.bowlerRuns,
      bowlerWickets: bowlerWickets ?? this.bowlerWickets, concentration: concentration ?? this.concentration,
      stamina: stamina ?? this.stamina, intent: intent ?? this.intent,
      creasePosition: creasePosition ?? this.creasePosition, bowlingArm: bowlingArm ?? this.bowlingArm,
      bowlingStyle: bowlingStyle ?? this.bowlingStyle, batterStance: batterStance ?? this.batterStance,
      bowlingLine: bowlingLine ?? this.bowlingLine, bowlingLength: bowlingLength ?? this.bowlingLength,
      bowlingVariation: bowlingVariation ?? this.bowlingVariation, fieldTrap: fieldTrap ?? this.fieldTrap,
      recent: recent ?? this.recent,
      commentary: commentary ?? this.commentary, complete: complete ?? this.complete, format: format ?? this.format);
}

final matchProvider = StateNotifierProvider<MatchdayController, MatchdayState>((ref) {
  final stadium = ref.watch(stadiumProvider.select((state) => state.selectedStadium));
  return MatchdayController(stadium: stadium);
});

class MatchdayController extends StateNotifier<MatchdayState> {
  MatchdayController({required StadiumAsset stadium})
      : _stadiumPitch = StadiumPitch(stadiumName: stadium.name, city: stadium.city, basePitchType: stadium.pitchType),
        super(const MatchdayState()) {
    _environment = _stadiumPitch.createMatchEnvironment();
  }
  final _random = Random();
  final StadiumPitch _stadiumPitch;
  late final pitch.MatchEnvironment _environment;
  late final _batter = ResolutionBatter(name: 'A. Mehta', baseTiming: 76, baseDefense: 71, concentration: .72);
  late final _bowler = ResolutionBowler(name: 'R. Khan', baseAccuracy: 79, baseMovement: 82, isSpinner: true, stamina: .84);

  void setIntent(BatterIntent intent) => state = state.copyWith(intent: intent);
  void setCreasePosition(CreasePosition value) => state = state.copyWith(creasePosition: value);
  void setBowlingArm(BowlingArm value) => state = state.copyWith(bowlingArm: value);
  void setBowlingStyle(BowlingStyleCode value) => state = state.copyWith(bowlingStyle: value);
  void setBatterStance(BatterStance value) => state = state.copyWith(batterStance: value);
  void setBowlingLine(BowlingLine value) => state = state.copyWith(bowlingLine: value);
  void setBowlingLength(BowlingLength value) => state = state.copyWith(bowlingLength: value);
  void setBowlingVariation(BowlingVariation value) => state = state.copyWith(bowlingVariation: value);
  void setFieldTrap(FieldTrap value) => state = state.copyWith(fieldTrap: value);
  void setFormat(CricketFormat format) {
    _environment.pitchWear = format == CricketFormat.test ? 0.1 : 0.5;
    _environment.ballAgeOvers = 0;
    _batter.concentration = .72;
    _bowler.stamina = .84;
    state = MatchdayState(format: format, target: format == CricketFormat.test ? 350 : format == CricketFormat.odi ? 280 : format == CricketFormat.hundred ? 145 : 178, runs: 0, wickets: 0, balls: 0, strikerRuns: 0, strikerBalls: 0, bowlerRuns: 0, bowlerWickets: 0, concentration: .72, stamina: .84, recent: const [], commentary: '${format.name.toUpperCase()} match initialized.');
  }
  void playNextBall() {
    if (state.complete) return;
    final env = _environment;
    final bowlingProfile = BowlingDeliveryProfile(
      crease: CreaseTactics(
        position: state.creasePosition,
        arm: state.bowlingArm,
        style: state.bowlingStyle,
      ),
      line: state.bowlingLine,
      length: state.bowlingLength,
      variation: state.bowlingVariation,
      fieldTrap: state.fieldTrap,
    );
    final angleModifiers = const BowlingAngleEngine().resolveOutcomeModifiers(
      profile: bowlingProfile,
      batterStance: state.batterStance,
      batterTechnique: 60,
      batterVsSpin: 60,
      bowlerControl: 79,
    );
    final result = DeliveryResolutionEngine(random: _random).resolve(
      environment: env,
      bowler: _bowler,
      batter: _batter,
      intent: state.intent,
      tacticalModifiers: angleModifiers,
    );
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
      commentary: '${result.commentary} ${state.creasePosition.name}, ${state.bowlingArm.name} ${state.bowlingStyle.name}, ${state.bowlingLine.name} ${state.bowlingLength.name}, ${state.bowlingVariation.name}, ${state.fieldTrap.name}. Intent: ${state.intent.name.toUpperCase()}. Batter control ${result.batterControl.toStringAsFixed(0)} vs bowler threat ${result.bowlerThreat.toStringAsFixed(0)}.',
      complete: wickets >= 10 || balls >= state.config.legalBallsPerInnings || runs >= state.target);
    if (balls % state.config.ballsPerOver == 0) _environment.advanceOver();
    if (state.complete) _stadiumPitch.degradePitch();
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
      backgroundColor: GamePalette.ink,
      appBar: AppBar(backgroundColor: Colors.transparent, centerTitle: true,
        title: Text('${s.format.name.toUpperCase()} MATCH', style: const TextStyle(letterSpacing: 2, color: Colors.white70, fontSize: 14)),
        actions: [IconButton(tooltip:'IPL innings & scorecard controller',onPressed:()=>Navigator.of(context).push(MaterialPageRoute<void>(builder:(_)=>const IplMatchControllerScreen())),icon:const Icon(Icons.scoreboard_rounded)), PopupMenuButton<CricketFormat>(tooltip: 'Match format', onSelected: actions.setFormat, itemBuilder: (_) => CricketFormat.values.map((format) => PopupMenuItem(value: format, child: Text(format.name.toUpperCase()))).toList()), IconButton(onPressed: actions.resetMatch, icon: const Icon(Icons.restart_alt), tooltip: 'Reset match')]),
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
        _TacticalDesk(
          state: s, onIntent: actions.setIntent, onPlay: actions.playNextBall,
          onCrease: actions.setCreasePosition, onArm: actions.setBowlingArm,
          onStyle: actions.setBowlingStyle, onStance: actions.setBatterStance,
          onLine: actions.setBowlingLine, onLength: actions.setBowlingLength,
          onVariation: actions.setBowlingVariation, onTrap: actions.setFieldTrap,
        ),
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
    decoration: BoxDecoration(color: GamePalette.panel, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10),
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
        .animate(key: ValueKey('$i-${balls[i]}')).scale(curve: Curves.elasticOut, duration: 350.ms)),
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
  const _TacticalDesk({
    required this.state, required this.onIntent, required this.onPlay,
    required this.onCrease, required this.onArm, required this.onStyle,
    required this.onStance, required this.onLine, required this.onLength,
    required this.onVariation, required this.onTrap,
  });
  final MatchdayState state;
  final ValueChanged<BatterIntent> onIntent;
  final VoidCallback onPlay;
  final ValueChanged<CreasePosition> onCrease;
  final ValueChanged<BowlingArm> onArm;
  final ValueChanged<BowlingStyleCode> onStyle;
  final ValueChanged<BatterStance> onStance;
  final ValueChanged<BowlingLine> onLine;
  final ValueChanged<BowlingLength> onLength;
  final ValueChanged<BowlingVariation> onVariation;
  final ValueChanged<FieldTrap> onTrap;

  Widget _choice<T extends Enum>(String label, T value, List<T> values, ValueChanged<T> changed) =>
    DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      dropdownColor: GamePalette.panel,
      style: const TextStyle(color: Colors.white, fontSize: 12),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60, fontSize: 11),
        filled: true, fillColor: Colors.white.withValues(alpha: .04),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white12)),
      ),
      items: values.map((v) => DropdownMenuItem<T>(value: v, child: Text(v.name.replaceAllMapped(RegExp(r'[A-Z]'), (m) => ' ${m[0]}').trim().toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis))).toList(),
      onChanged: (v) { if (v != null) changed(v); },
    );
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
    decoration: const BoxDecoration(color: GamePalette.panel, borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
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
      const SizedBox(height: 14),
      const Align(alignment: Alignment.centerLeft, child: Text('BOWLING PLAN', style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: .8))),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: _choice('Crease', state.creasePosition, CreasePosition.values, onCrease)),
        const SizedBox(width: 8),
        Expanded(child: _choice('Bowling arm', state.bowlingArm, BowlingArm.values, onArm)),
      ]),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: _choice('Style', state.bowlingStyle, BowlingStyleCode.values, onStyle)),
        const SizedBox(width: 8),
        Expanded(child: _choice('Batter stance', state.batterStance, BatterStance.values, onStance)),
      ]),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: _choice('Line', state.bowlingLine, BowlingLine.values, onLine)),
        const SizedBox(width: 8),
        Expanded(child: _choice('Length', state.bowlingLength, BowlingLength.values, onLength)),
      ]),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: _choice('Variation', state.bowlingVariation, BowlingVariation.values, onVariation)),
        const SizedBox(width: 8),
        Expanded(child: _choice('Field trap', state.fieldTrap, FieldTrap.values, onTrap)),
      ]),
      const SizedBox(height: 12),
      SizedBox(width: double.infinity, height: 56, child: ElevatedButton.icon(
        onPressed: state.complete ? null : onPlay, icon: const Icon(Icons.sports_cricket),
        label: Text(state.complete ? 'INNINGS COMPLETE' : 'PLAY NEXT DELIVERY', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
        style: ElevatedButton.styleFrom(backgroundColor: GamePalette.emerald, foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))))),
    ]));
}
