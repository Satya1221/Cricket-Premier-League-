import '../domain/auction_state.dart';
import 'real_ipl_2026_player_pool.dart';

/// Builds a fresh auction from the published 2026 IPL player pool.
/// All ten franchises participate; the human-managed franchise is Mumbai Indians.
AuctionState createDemoAuction() => AuctionState(
  teams: [
    for (final franchise in currentIplFranchises)
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
  message: '2026 IPL player pool loaded • 10 franchises ready',
);
