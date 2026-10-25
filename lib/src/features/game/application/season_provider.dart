import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../state/season_schedule_repository.dart';
import '../../../../models/fixture_model.dart';
import '../../../../engine/fast_sim_engine.dart';

import '../data/career_save_repository.dart';
import '../domain/career_simulation_engine.dart';
import 'game_controller.dart';
import '../../auction/data/real_ipl_2026_player_pool.dart';

final careerSaveRepositoryProvider = Provider<CareerSaveRepository>((ref) => CareerSaveRepository());
final seasonProvider = StateNotifierProvider<SeasonNotifier, SeasonData>((ref) {
  final campaignId = ref.watch(gameControllerProvider.select((session) => session.campaignId));
  final saveId = campaignId == null ? SeasonNotifier.defaultSaveId : 'career-$campaignId';
  return SeasonNotifier(ref.read(careerSaveRepositoryProvider), saveId: saveId);
});

class SeasonNotifier extends StateNotifier<SeasonData> {
  SeasonNotifier(this._saves, {required String saveId})
      : _saveId = saveId,
        super(_loadInitial(_saves, saveId)) {
    _persistSchedule();
  }

  static SeasonData _loadInitial(CareerSaveRepository saves, String saveId) =>
      saves.loadSeason(saveId) ?? _newSeason();
  final CareerSaveRepository _saves;
  final String _saveId;
  final CareerSimulationEngine _engine = const CareerSimulationEngine();
  final FastSimEngine _fastSim = const FastSimEngine();
  final SeasonScheduleRepository _schedule = SeasonScheduleRepository();

  Future<void> _persistSchedule() => _schedule.save(state.fixtures.map((f) => FixtureModel(
    matchId: f.id, homeTeamId: f.homeTeamId, awayTeamId: f.awayTeamId,
    matchWeek: f.round, isCompleted: f.played,
    result: f.homeRuns == null || f.awayRuns == null ? null : MatchResultData(
      homeRuns: f.homeRuns!, homeWickets: 0, homeBalls: f.homeBalls ?? 120,
      awayRuns: f.awayRuns!, awayWickets: 0, awayBalls: f.awayBalls ?? 120),
  )).toList());
  static const String defaultSaveId = 'career-main';

  static SeasonData _newSeason() {
    const prefixByTeam = <String, String>{
      'cpl': 'mi-', 'roy': 'rcb-', 'tit': 'csk-', 'fal': 'kkr-',
      'gt': 'gt-', 'rr': 'rr-', 'pbks': 'pbks-', 'srh': 'srh-',
      'lsg': 'lsg-', 'dc': 'dc-',
    };
    final teams = currentIplFranchises.map((franchise) {
      final prefix = prefixByTeam[franchise.id]!;
      final players = realIpl2026PlayerPool
          .where((player) => player.id.startsWith(prefix))
          .map((player) => CareerPlayer(
                id: player.id,
                name: player.name,
                age: player.age,
                overall: player.overall,
                potential: player.potential,
                role: player.role.name,
              ))
          .toList(growable: false);
      return CareerTeam(
        id: franchise.id,
        name: franchise.name,
        players: players,
        purseCr: 120,
      );
    }).toList(growable: false);
    return SeasonData(
      seasonNumber: 1,
      teams: teams,
      fixtures: const CareerSimulationEngine().generateRoundRobin(teams),
    );
  }

  Future<void> save() async { await _saves.saveSeason(_saveId, state); await _persistSchedule(); }
  Future<bool> load() async {
    final saved = _saves.loadSeason(_saveId);
    if (saved == null) return false;
    state = saved;
    await _persistSchedule();
    return true;
  }

  Future<void> simulateNextMatch() async {
    state = _engine.simulateNextFixture(state);
    await save();
  }

  /// Resolves every fixture in the next match week so AI teams progress together.
  Future<void> simulateMatchWeek() async {
    final pending = state.fixtures.where((f) => !f.played).toList();
    if (pending.isEmpty) return;
    final week = pending.first.round;
    while (true) {
      final pending = state.fixtures.where((f) => !f.played && f.round == week).toList();
      if (pending.isEmpty) break;
      final fixture = pending.first;
      final homeMatches = state.teams.where((team) => team.id == fixture.homeTeamId).toList();
      final awayMatches = state.teams.where((team) => team.id == fixture.awayTeamId).toList();
      if (homeMatches.isEmpty || awayMatches.isEmpty) {
        state = _engine.simulateNextFixture(state);
        continue;
      }
      final result = _fastSim.simulate(homeMatches.first, awayMatches.first);
      state = _engine.recordFixtureResult(state, fixture.id, result);
    }
    await save();
  }

  Future<void> simulateRemainingRound() async {
    if (state.fixtures.every((fixture) => fixture.played)) return;
    final round = state.fixtures.firstWhere((fixture) => !fixture.played).round;
    while (state.fixtures.any((fixture) => !fixture.played && fixture.round == round)) {
      state = _engine.simulateNextFixture(state);
    }
    await save();
  }

  Future<void> endSeason({int academyLevel = 1}) async {
    if (state.fixtures.any((fixture) => !fixture.played)) {
      throw StateError('Finish every fixture before ending the season.');
    }
    // Snapshot the season's leaders before the roster rolls over, so the
    // all-time records survive the transition.
    await _saves.saveHistory('season-${state.seasonNumber}', _historySnapshot());
    state = _engine.endSeason(state, academyLevel: academyLevel);
    await save();
  }

  Map<String, Object?> _historySnapshot() {
    final players = state.teams.expand((team) => team.players).toList();
    final batters = [...players]..sort((a, b) => b.runs.compareTo(a.runs));
    final bowlers = [...players]..sort((a, b) => b.wickets.compareTo(a.wickets));
    return {
      'seasonNumber': state.seasonNumber,
      'topRunScorer': batters.isEmpty
          ? null
          : <String, Object?>{'name': batters.first.name, 'runs': batters.first.runs},
      'topWicketTaker': bowlers.isEmpty
          ? null
          : <String, Object?>{'name': bowlers.first.name, 'wickets': bowlers.first.wickets},
      'standings': [
        for (final team in standings)
          <String, Object?>{'team': team.name, 'points': team.points},
      ],
    };
  }

  List<CareerTeam> get standings => _engine.standings(state.teams);
}
