import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../state/season_schedule_repository.dart';
import '../../../../services/fixture_generator_service.dart';

import '../data/career_save_repository.dart';
import '../domain/career_simulation_engine.dart';

final careerSaveRepositoryProvider = Provider<CareerSaveRepository>((ref) => CareerSaveRepository());
final seasonProvider = StateNotifierProvider<SeasonNotifier, SeasonData>((ref) => SeasonNotifier(ref.read(careerSaveRepositoryProvider)));

class SeasonNotifier extends StateNotifier<SeasonData> {
  SeasonNotifier(this._saves) : super(_newSeason()) { _persistSchedule(); }
  final CareerSaveRepository _saves;
  final CareerSimulationEngine _engine = const CareerSimulationEngine();
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
    const teams = <CareerTeam>[
      CareerTeam(id: 'cpl', name: 'Coastal Premier Lions'),
      CareerTeam(id: 'roy', name: 'Royal Strikers'),
      CareerTeam(id: 'tit', name: 'Capital Titans'),
      CareerTeam(id: 'fal', name: 'Frontier Falcons'),
    ];
    return SeasonData(seasonNumber: 1, teams: teams, fixtures: const CareerSimulationEngine().generateRoundRobin(teams));
  }

  Future<void> save() async { await _saves.saveSeason(defaultSaveId, state); await _persistSchedule(); }
  Future<bool> load() async {
    final saved = _saves.loadSeason(defaultSaveId);
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
    while (state.fixtures.any((f) => !f.played && f.round == week)) {
      state = _engine.simulateNextFixture(state);
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
