import 'player.dart';

class PurseRules {
  const PurseRules({
    this.initialPurseCr = 120,
    this.minimumSquadSize = 18,
    this.maximumSquadSize = 25,
    this.maximumOverseas = 8,
    this.minimumReservePerMissingPlayerCr = 0.20,
  }) : assert(initialPurseCr > 0),
       assert(minimumSquadSize > 0),
       assert(maximumSquadSize >= minimumSquadSize);

  final double initialPurseCr;
  final int minimumSquadSize;
  final int maximumSquadSize;
  final int maximumOverseas;
  final double minimumReservePerMissingPlayerCr;

  double minimumSquadReserveCr(AuctionTeam team) =>
      (minimumSquadSize - team.squad.length).clamp(0, maximumSquadSize).toDouble() * minimumReservePerMissingPlayerCr;

  double get maximumBidForNewSquadMemberCr => initialPurseCr;

  bool canAffordBid(AuctionTeam team, double bidCr, {bool preserveMinimumSquadReserve = true}) {
    if (!bidCr.isFinite || bidCr <= 0 || team.purseCr < bidCr || team.remainingSlots <= 0) {
      return false;
    }
    final reserve = preserveMinimumSquadReserve ? minimumSquadReserveCr(team) : 0;
    return team.purseCr - bidCr >= reserve || team.squad.length + 1 >= minimumSquadSize;
  }

  void validateContract(AuctionTeam team, AuctionPlayer player, double bidCr, {bool preserveMinimumSquadReserve = true}) {
    if (bidCr < player.basePriceCr) {
      throw StateError('Bid cannot be below the player base price.');
    }
    if (!canAffordBid(team, bidCr, preserveMinimumSquadReserve: preserveMinimumSquadReserve)) {
      throw StateError('Bid rejected: insufficient purse or funds must be reserved to complete the minimum squad.');
    }
    if (player.isOverseas && team.overseasCount >= maximumOverseas) {
      throw StateError('Overseas player limit reached.');
    }
  }
}
