import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:cricket_premier_league/src/features/auction/data/real_ipl_2026_player_pool.dart';
import 'package:cricket_premier_league/src/features/auction/domain/player.dart';
import 'package:cricket_premier_league/src/features/game/domain/career_simulation_engine.dart';

void main() {
  test('real-player pool covers all ten fictional franchises with unique IDs', () {
    expect(leagueFranchises, hasLength(10));
    expect(realIpl2026PlayerPool.length, greaterThanOrEqualTo(180));
    expect(realIpl2026PlayerPool.map((p) => p.id).toSet(),
        hasLength(realIpl2026PlayerPool.length));
    expect(realIpl2026PlayerPool.map((p) => p.name).toSet(),
        hasLength(realIpl2026PlayerPool.length));
    expect(realIpl2026PlayerPool.any((p) => p.name == 'Virat Kohli'), isTrue);
    expect(realIpl2026PlayerPool.any((p) => p.name == 'Jasprit Bumrah'), isTrue);
    expect(realIpl2026PlayerPool.any((p) => p.name == 'Rashid Khan'), isTrue);
    expect(realIpl2026PlayerPool.every((p) =>
        p.overall >= 1 && p.overall <= 100 &&
        p.potential >= p.overall &&
        p.potential <= 100), isTrue);
    expect(realIpl2026PlayerPool.where((p) => p.role == PlayerRole.bowler),
        isNotEmpty);
  });

  test('ten-franchise career runs a full double round robin and advances season', () {
    final teams = [
      for (final franchise in currentIplFranchises)
        CareerTeam(
          id: franchise.id,
          name: franchise.name,
          players: realIpl2026PlayerPool
              .where((p) => p.id.startsWith(_prefixFor(franchise.id)))
              .map((p) => CareerPlayer(
                    id: p.id,
                    name: p.name,
                    age: p.age,
                    overall: p.overall,
                    potential: p.potential,
                    role: p.role.name,
                  ))
              .toList(),
        ),
    ];
    const engine = CareerSimulationEngine();
    final fixtures = engine.generateRoundRobin(teams);
    expect(fixtures, hasLength(90));
    var season = SeasonData(seasonNumber: 1, teams: teams, fixtures: fixtures);
    final random = Random(17);
    while (season.fixtures.any((fixture) => !fixture.played)) {
      season = engine.simulateNextFixture(season, random: random);
    }
    final next = engine.endSeason(season, academyLevel: 1, random: Random(18));
    expect(next.seasonNumber, 2);
    expect(next.fixtures, hasLength(90));
    expect(next.fixtures.every((fixture) => !fixture.played), isTrue);
    expect(next.teams, hasLength(10));
    expect(next.teams.every((team) => team.purseCr >= 120), isTrue);
  });
}

String _prefixFor(String id) => const {
      'cpl': 'mi-',
      'roy': 'rcb-',
      'tit': 'csk-',
      'fal': 'kkr-',
      'gt': 'gt-',
      'rr': 'rr-',
      'pbks': 'pbks-',
      'srh': 'srh-',
      'lsg': 'lsg-',
      'dc': 'dc-',
    }[id]!;
