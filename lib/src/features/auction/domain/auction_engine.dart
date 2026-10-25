import 'dart:math' as math;

import 'auction_state.dart';
import 'player.dart';

enum RivalStyle { balanced, aggressive, budgetGuardian, youthFirst, roleSpecialist }

class RivalProfile {
  const RivalProfile({
    required this.teamId,
    required this.style,
    this.aggression = 0.55,
    this.managerPressure = 0,
    this.targetRoles = const {},
  });

  final String teamId;
  final RivalStyle style;
  final double aggression;
  final double managerPressure;
  final Set<PlayerRole> targetRoles;
}

class BidDecision {
  const BidDecision({
    required this.shouldBid,
    required this.nextBidCr,
    required this.reason,
  });

  final bool shouldBid;
  final double nextBidCr;
  final String reason;
}

class AuctionEngine {
  const AuctionEngine();

  double valuationCr(AuctionPlayer player) {
    final skill = player.overall / 100;
    final potential = player.potential / 100;
    final youthBonus = (30 - player.age).clamp(0, 12) / 100;
    final formFactor = 0.88 + (player.form.clamp(0, 100) / 100) * 0.24;
    final rolePremium = player.role == PlayerRole.allRounder ? 1.12 : 1.0;
    final calculated = (player.basePriceCr +
            player.basePriceCr * 2.2 * skill +
            player.basePriceCr * potential * youthBonus * 2.5) *
        formFactor *
        rolePremium;
    return math.max(player.basePriceCr, calculated);
  }

  double incrementFor(double bid) {
    if (bid < 1) return 0.05;
    if (bid < 5) return 0.10;
    if (bid < 10) return 0.20;
    if (bid < 20) return 0.25;
    return 0.50;
  }

  BidDecision rivalDecision({
    required AuctionPlayer player,
    required AuctionTeam team,
    required RivalProfile rival,
    required double currentBidCr,
  }) {
    final roleFit = rival.targetRoles.contains(player.role) ? 1.18 : 1.0;
    final styleFactor = switch (rival.style) {
      RivalStyle.balanced => 1.0,
      RivalStyle.aggressive => 1.20,
      RivalStyle.budgetGuardian => 0.78,
      RivalStyle.youthFirst => player.age <= 24 ? 1.20 : 0.82,
      RivalStyle.roleSpecialist => roleFit,
    };
    // Aggression affects willingness to stay in a bidding war; pressure can
    // temporarily push a manager beyond its normal valuation ceiling.
    final aggressionFactor = 0.82 + rival.aggression.clamp(0.0, 1.0) * 0.36;
    final pressureFactor = 1 + rival.managerPressure.clamp(-0.2, 0.2);
    final reserve = valuationCr(player) * styleFactor * aggressionFactor * pressureFactor;
    final nextBid = currentBidCr == 0
        ? player.basePriceCr
        : currentBidCr + incrementFor(currentBidCr);
    final feasible = team.purseCr >= nextBid &&
        team.remainingSlots > 0 &&
        (!player.isOverseas || team.overseasCount < team.maxOverseas);
    final shouldBid = feasible && nextBid <= reserve;
    return BidDecision(
      shouldBid: shouldBid,
      nextBidCr: nextBid,
      reason: !feasible
          ? 'Squad or purse constraint'
          : shouldBid
              ? 'Within valuation and strategy limits'
              : 'Price exceeded strategy valuation',
    );
  }

  AuctionState placeBid({
    required AuctionState state,
    required String teamId,
  }) {
    final player = state.currentPlayer;
    if (player == null || state.phase == AuctionPhase.completed) {
      throw StateError('There is no active player lot.');
    }
    if (state.phase == AuctionPhase.sold || state.phase == AuctionPhase.unsold) {
      throw StateError('This lot is already closed.');
    }
    final index = state.teams.indexWhere((team) => team.id == teamId);
    if (index < 0) throw ArgumentError.value(teamId, 'teamId', 'Unknown team');
    final team = state.teams[index];
    if (state.leadingTeamId == teamId) {
      throw StateError('Your franchise is already the highest bidder. Wait for a rival counter-bid.');
    }
    final nextBid = state.currentBidCr == 0
        ? player.basePriceCr
        : state.currentBidCr + incrementFor(state.currentBidCr);
    if (team.purseCr < nextBid) throw StateError('Insufficient purse.');
    if (team.remainingSlots <= 0) throw StateError('Squad is full.');
    if (player.isOverseas && team.overseasCount >= team.maxOverseas) {
      throw StateError('Overseas player limit reached.');
    }
    final history = [
      ...state.bidHistory,
      '${team.shortName} bids ₹${nextBid.toStringAsFixed(2)} Cr',
    ];
    return state.copyWith(
      phase: AuctionPhase.bidding,
      currentBidCr: nextBid,
      leadingTeamId: teamId,
      bidHistory: history,
      message: '${team.shortName} leads at ₹${nextBid.toStringAsFixed(2)} Cr',
    );
  }

  AuctionState runRivalRound({
    required AuctionState state,
    required List<RivalProfile> rivals,
  }) {
    final player = state.currentPlayer;
    if (player == null ||
        (state.phase != AuctionPhase.ready && state.phase != AuctionPhase.bidding)) {
      return state;
    }

    var nextState = state;
    for (final rival in rivals) {
      if (rival.teamId == nextState.leadingTeamId) continue;
      final teamIndex = nextState.teams.indexWhere((team) => team.id == rival.teamId);
      final activePlayer = nextState.currentPlayer;
      if (teamIndex < 0 || activePlayer == null) continue;

      final decision = rivalDecision(
        player: activePlayer,
        team: nextState.teams[teamIndex],
        rival: rival,
        currentBidCr: nextState.currentBidCr,
      );
      if (!decision.shouldBid) {
        nextState = nextState.copyWith(
          bidHistory: [
            ...nextState.bidHistory,
            '${nextState.teams[teamIndex].shortName} passes • ${decision.reason}',
          ],
        );
        continue;
      }

      nextState = placeBid(state: nextState, teamId: rival.teamId);
    }

    if (nextState.bidHistory.length == state.bidHistory.length) {
      return nextState.copyWith(message: 'Rivals hold • current bid stands');
    }
    return nextState.copyWith(message: nextState.bidHistory.last);
  }

  AuctionState closeLot(AuctionState state) {
    final player = state.currentPlayer;
    if (player == null) return state.copyWith(phase: AuctionPhase.completed);
    if (state.phase == AuctionPhase.sold || state.phase == AuctionPhase.unsold) {
      throw StateError('This lot is already closed.');
    }
    if (state.leadingTeamId == null) {
      return state.copyWith(
        phase: AuctionPhase.unsold,
        message: '${player.name} goes unsold',
      );
    }
    final winnerIndex = state.teams.indexWhere((team) => team.id == state.leadingTeamId);
    if (winnerIndex < 0) throw StateError('Leading team no longer exists.');
    final winner = state.teams[winnerIndex];
    if (winner.purseCr < state.currentBidCr) {
      throw StateError('Winner purse changed; cannot finalize lot.');
    }
    final purchased = AuctionPlayer(
      id: player.id,
      name: player.name,
      nation: player.nation,
      role: player.role,
      overall: player.overall,
      potential: player.potential,
      basePriceCr: state.currentBidCr,
      isOverseas: player.isOverseas,
      age: player.age,
      batting: player.batting,
      bowling: player.bowling,
      fielding: player.fielding,
      form: player.form,
    );
    final teams = [...state.teams];
    teams[winnerIndex] = winner.copyWith(
      purseCr: winner.purseCr - state.currentBidCr,
      squad: [...winner.squad, purchased],
    );
    return state.copyWith(
      teams: teams,
      phase: AuctionPhase.sold,
      message:
          '${player.name} sold to ${winner.shortName} for ₹${state.currentBidCr.toStringAsFixed(2)} Cr',
    );
  }

  AuctionState nextLot(AuctionState state) {
    if (state.phase != AuctionPhase.sold && state.phase != AuctionPhase.unsold) {
      throw StateError('Close the current lot before moving to the next player.');
    }
    final nextIndex = state.currentPlayerIndex + 1;
    if (nextIndex >= state.players.length) {
      return state.copyWith(
        currentPlayerIndex: nextIndex,
        phase: AuctionPhase.completed,
        clearLeader: true,
        currentBidCr: 0,
        message: 'Auction complete',
      );
    }
    return state.copyWith(
      currentPlayerIndex: nextIndex,
      phase: AuctionPhase.ready,
      clearLeader: true,
      currentBidCr: 0,
      bidHistory: const [],
      message: 'Next lot ready',
    );
  }
}
