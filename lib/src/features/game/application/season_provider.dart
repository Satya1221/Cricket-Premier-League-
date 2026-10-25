import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/career_save_repository.dart';
import '../domain/career_simulation_engine.dart';

final careerSaveRepositoryProvider = Provider<CareerSaveRepository>((ref) => CareerSaveRepository());
final seasonProvider = StateNotifierProvider<SeasonNotifier, SeasonData>((ref) => SeasonNotifier(ref.read(careerSaveRepositoryProvider)));

class SeasonNotifier extends StateNotifier<SeasonData> {
  SeasonNotifier(this._saves) : super(_newSeason());
  final CareerSaveRepository _saves;
  final CareerSimulationEngine _engine = const CareerSimulationEngine();
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

  Future<void> save() => _saves.saveSeason(defaultSaveId, state);
  Future<bool> load() async {
    final saved = _saves.loadSeason(defaultSaveId);
    if (saved == null) return false;
    state = saved;
    return true;
  }

  Future<void> simulateNextMatch() async {
    state = _engine.simulateNextFixture(state);
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
    state = _engine.endSeason(state, academyLevel: academyLevel);
    await save();
  }

  List<CareerTeam> get standings => _engine.standings(state.teams);
}
