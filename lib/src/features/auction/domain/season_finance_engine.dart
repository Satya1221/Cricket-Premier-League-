import 'player.dart';
import 'player_contract.dart';

/// Result of advancing one franchise by one completed season.
///
/// Auction purse accounting is intentionally unchanged here: auction prices
/// were already charged when players were purchased. This computes next-season
/// payroll and contract expiry without charging the same amount twice.
class SeasonContractAdvance {
  const SeasonContractAdvance({
    required this.team,
    required this.releasedPlayers,
    required this.nextSeasonPayrollCr,
    required this.expiredContractCount,
  });

  final AuctionTeam team;
  final List<AuctionPlayer> releasedPlayers;
  final double nextSeasonPayrollCr;
  final int expiredContractCount;
}

/// Pure domain helper for the contract part of the season transition.
/// The game controller/repository must call this exactly once per team per
/// season and persist the returned team.
class SeasonFinanceEngine {
  const SeasonFinanceEngine();

  SeasonContractAdvance advanceTeam(AuctionTeam team) {
    final retained = <AuctionPlayer>[];
    final released = <AuctionPlayer>[];
    var payroll = 0.0;
    var expired = 0;

    for (final player in team.squad) {
      final contract = player.contract;
      if (contract == null) {
        // Legacy roster entries without a contract remain on the squad but do
        // not create a fabricated salary obligation.
        retained.add(player);
        continue;
      }

      final nextContract = contract.advanceSeason();
      if (nextContract.yearsRemaining == 0) {
        released.add(player);
        expired++;
        continue;
      }

      final nextPlayer = AuctionPlayer(
        id: player.id,
        name: player.name,
        nation: player.nation,
        role: player.role,
        overall: player.overall,
        potential: player.potential,
        basePriceCr: player.basePriceCr,
        isOverseas: player.isOverseas,
        age: player.age,
        batting: player.batting,
        bowling: player.bowling,
        fielding: player.fielding,
        form: player.form,
        contract: nextContract,
      );
      retained.add(nextPlayer);
      payroll += nextContract.currentSalaryCrores;
    }

    return SeasonContractAdvance(
      team: team.copyWith(squad: retained),
      releasedPlayers: List.unmodifiable(released),
      nextSeasonPayrollCr: payroll,
      expiredContractCount: expired,
    );
  }

  double currentSeasonPayrollCr(AuctionTeam team) => team.squad.fold<double>(
        0,
        (total, player) => total + (player.contract?.currentSalaryCrores ?? 0),
      );
}
