import 'package:flutter_test/flutter_test.dart';
import 'package:cricket_premier_league/src/features/game/application/game_controller.dart';

void main() {
  test('game session round-trips through JSON without losing campaign state', () {
    const original = GameSessionState(
      phase: GamePhase.season,
      seasonNumber: 4,
      completedMatches: 12,
      lastAction: 'Match 12 completed.',
      campaignId: 'campaign-test',
      league: 'Indian Premier League',
      franchiseName: 'Coastal Premier Lions',
      purseCr: 37.25,
      difficulty: 'Hard',
    );

    final restored = GameSessionState.fromJson(original.toJson());

    expect(restored.phase, GamePhase.season);
    expect(restored.seasonNumber, 4);
    expect(restored.completedMatches, 12);
    expect(restored.lastAction, 'Match 12 completed.');
    expect(restored.campaignId, 'campaign-test');
    expect(restored.league, 'Indian Premier League');
    expect(restored.franchiseName, 'Coastal Premier Lions');
    expect(restored.purseCr, 37.25);
    expect(restored.difficulty, 'Hard');
  });

  test('unknown saved phase safely falls back to pre-season', () {
    final restored = GameSessionState.fromJson({
      'phase': 'futurePhase',
      'seasonNumber': 1,
    });

    expect(restored.phase, GamePhase.preSeason);
  });
}
