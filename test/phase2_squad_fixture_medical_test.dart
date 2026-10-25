import 'package:flutter_test/flutter_test.dart';
import 'package:cricket_premier_league/models/fixture_model.dart';
import 'package:cricket_premier_league/services/fixture_generator_service.dart';
import 'package:cricket_premier_league/services/medical_workload_service.dart';

void main() {
  test('double round-robin schedules every pair twice with reversed venues', () {
    const generator = FixtureGeneratorService();
    final fixtures = generator.generate(['a', 'b', 'c', 'd'], season: 2);
    expect(fixtures, hasLength(12));
    for (final a in ['a', 'b', 'c', 'd']) {
      for (final b in ['a', 'b', 'c', 'd']) {
        if (a == b) continue;
        expect(fixtures.where((f) => f.homeTeamId == a && f.awayTeamId == b), hasLength(1));
      }
    }
    expect(fixtures.map((f) => f.matchWeek).toSet(), hasLength(6));
  });

  test('fixture result survives JSON serialization', () {
    const fixture = FixtureModel(
      matchId: 'm1', homeTeamId: 'a', awayTeamId: 'b', matchWeek: 1,
      isCompleted: true,
      result: MatchResultData(homeRuns: 180, homeWickets: 5, homeBalls: 120, awayRuns: 170, awayWickets: 8, awayBalls: 120),
    );
    final restored = FixtureModel.fromJson(fixture.toJson());
    expect(restored.isCompleted, isTrue);
    expect(restored.result?.homeRuns, 180);
    expect(restored.result?.awayRuns, 170);
  });

  test('medical workload adds role-specific fatigue and weekly recovery', () {
    const service = MedicalWorkloadService();
    const pace = PlayerWorkloadState(playerId: 'p1', fatigue: 10);
    expect(service.settle(player: pace, role: WorkloadRole.paceBowler, oversBowled: 2).fatigue, 40);
    expect(service.settle(player: pace, role: WorkloadRole.spinBowler, oversBowled: 2).fatigue, 26);
    expect(service.settle(player: pace, role: WorkloadRole.batter, runsScored: 5).fatigue, 20);
    expect(service.advanceWeek(const PlayerWorkloadState(playerId: 'p2', fatigue: 80), physioLevel: 2).fatigue, 40);
  });
}
