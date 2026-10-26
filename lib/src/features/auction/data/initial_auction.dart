import '../domain/auction_state.dart';
import '../domain/player.dart';
import 'real_ipl_2026_player_pool.dart';

/// Builds a fresh auction from the published player-data pool.
/// All ten franchises participate; the human-managed franchise is Mumbai Indians.
AuctionState createInitialAuction() => AuctionState(
  teams: [
    for (final franchise in leagueFranchises)
      AuctionTeam(
        id: franchise.id,
        name: franchise.name,
        shortName: franchise.shortName,
        purseCr: 120,
      ),
  ],
  players: realIpl2026PlayerPool,
  currentPlayerIndex: 0,
  phase: AuctionPhase.ready,
  currentBidCr: 0,
  leadingTeamId: null,
  bidHistory: const [],
  message: 'Player pool loaded • 10 original franchises ready',
);
