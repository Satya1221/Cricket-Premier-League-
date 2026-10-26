import 'package:flutter_test/flutter_test.dart';
import 'package:cricket_premier_league/src/features/game/data/campaign_store.dart';

void main() {
  test('campaign save round-trips auction, roster and calendar snapshots', () {
    final original = CampaignSave(
      id: 'career-test',
      league: 'Premier T20 League',
      franchiseName: 'Coastal Premier Lions',
      purseCr: 42.5,
      difficulty: 'Hard',
      seasonNumber: 3,
      completedMatches: 11,
      phase: 'season',
      squadCount: 19,
      auctionSnapshot: {
        'currentPlayerIndex': 12,
        'phase': 'bidding',
        'teams': <Object?>[],
      },
      rosterSnapshot: {
        'purseCr': 42.5,
        'activeSquad': <String>['mi-virat-test'],
        'playingXI': <String>['mi-virat-test'],
      },
      calendarSnapshot: {
        'year': 2028,
        'day': 12,
      },
    );

    final restored = CampaignSave.fromJson(original.toJson());
    expect(restored.id, original.id);
    expect(restored.seasonNumber, 3);
    expect(restored.completedMatches, 11);
    expect(restored.auctionSnapshot?['currentPlayerIndex'], 12);
    expect(restored.rosterSnapshot?['purseCr'], 42.5);
    expect(restored.rosterSnapshot?['playingXI'], ['mi-virat-test']);
    expect(restored.calendarSnapshot?['year'], 2028);
  });
}
