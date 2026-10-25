import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../models/franchise_model.dart';
import '../../../../models/player_model.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../game/data/campaign_store.dart';
import '../data/demo_auction.dart';
import '../domain/auction_engine.dart';
import '../domain/auction_state.dart';
import '../domain/player.dart';

final auctionControllerProvider =
    NotifierProvider<AuctionController, AuctionState>(AuctionController.new);

class AuctionController extends Notifier<AuctionState> {
  final AuctionEngine _engine = const AuctionEngine();
  Timer? _biddingTimer;
  int _quietTicks = 0;

  static const List<RivalProfile> _rivals = [
    RivalProfile(teamId: 'roy', style: RivalStyle.aggressive, aggression: 0.82),
    RivalProfile(teamId: 'tit', style: RivalStyle.budgetGuardian, aggression: 0.42),
    RivalProfile(
      teamId: 'fal',
      style: RivalStyle.youthFirst,
      aggression: 0.68,
      targetRoles: {PlayerRole.batter, PlayerRole.allRounder},
    ),
    RivalProfile(teamId: 'gt', style: RivalStyle.roleSpecialist, aggression: 0.72, targetRoles: {PlayerRole.bowler}),
    RivalProfile(teamId: 'rr', style: RivalStyle.youthFirst, aggression: 0.75),
    RivalProfile(teamId: 'pbks', style: RivalStyle.aggressive, aggression: 0.78),
    RivalProfile(teamId: 'srh', style: RivalStyle.aggressive, aggression: 0.80, targetRoles: {PlayerRole.batter, PlayerRole.wicketKeeper}),
    RivalProfile(teamId: 'lsg', style: RivalStyle.budgetGuardian, aggression: 0.48),
    RivalProfile(teamId: 'dc', style: RivalStyle.balanced, aggression: 0.60),
  ];

  @override
  AuctionState build() {
    ref.onDispose(() => _biddingTimer?.cancel());
    final initial = CampaignStore.loadActiveAuction() ?? createDemoAuction();
    unawaited(_syncPlayerModels(initial));
    return initial;
  }

  Future<void> _syncPlayerModels(AuctionState auction) async {
    final box=Hive.box<PlayerModel>('players');
    final all=<String,AuctionPlayer>{for(final p in auction.players)p.id:p};
    for(final team in auction.teams){for(final p in team.squad){all[p.id]=p;}}
    for(final p in all.values){
      if(box.containsKey(p.id))continue;
      await box.put(p.id,PlayerModel(id:p.id,name:p.name,age:p.age,role:switch(p.role){PlayerRole.batter=>'Batter',PlayerRole.bowler=>'Pace',PlayerRole.allRounder=>'AR',PlayerRole.wicketKeeper=>'WK'},batSkill:p.batting,bowlSkill:p.bowling,fielding:p.fielding,stamina:80,form:p.form,nation:p.nation,isOverseas:p.isOverseas));
    }
  }

  /// Starts the two-second live rival bidding loop. Two quiet ticks close the lot.
  void startLiveBidding() {
    _biddingTimer?.cancel();
    _quietTicks = 0;
    _biddingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (state.currentPlayer == null || state.phase == AuctionPhase.completed || state.phase == AuctionPhase.sold || state.phase == AuctionPhase.unsold) {
        timer.cancel(); return;
      }
      final before = state.currentBidCr;
      final previousLeader = state.leadingTeamId;
      state = _engine.runRivalRound(state: state, rivals: _rivals);
      unawaited(CampaignStore.saveAuction(state));
      if (state.currentBidCr > before || state.leadingTeamId != previousLeader) {
        _quietTicks = 0;
      } else {
        _quietTicks++;
      }
      if (_quietTicks >= 2) {
        timer.cancel();
        hammerDown();
      }
    });
  }

  void stopLiveBidding() { _biddingTimer?.cancel(); _biddingTimer = null; }

  void hammerDown() { stopLiveBidding(); closeLot(); }


  /// Places a bid. When the human franchise bids, the rival AI immediately
  /// evaluates and counter-bids, so the auction never stalls waiting for a
  /// manual "simulate rival round" tap.
  void bidFor(String teamId) {
    state = _engine.placeBid(state: state, teamId: teamId);
    if (teamId == 'cpl') {
      state = _engine.runRivalRound(state: state, rivals: _rivals);
    }
    unawaited(CampaignStore.saveAuction(state));
  }

  void runRivalRound() {
    state = _engine.runRivalRound(state: state, rivals: _rivals);
    unawaited(CampaignStore.saveAuction(state));
  }

  /// Closing a lot changes purse and squad, so the save slot is refreshed
  /// immediately to keep the Load Game cards accurate.
  void closeLot() {
    final player = state.currentPlayer;
    final winnerId = state.leadingTeamId;
    state = _engine.closeLot(state);
    unawaited(_syncPlayerModels(state));
    if (player != null && winnerId == 'cpl' && state.phase == AuctionPhase.sold) {
      final franchiseBox = Hive.box<FranchiseModel>('franchises');
      final franchise = franchiseBox.get('cpl') ?? const FranchiseModel(id: 'cpl');
      final updated = franchise.copyWith(
        purseCrores: state.teams.firstWhere((team) => team.id == 'cpl').purseCr,
        squadIds: [...franchise.squadIds, if (!franchise.squadIds.contains(player.id)) player.id],
      );
      unawaited(franchiseBox.put('cpl', updated));

    }
    unawaited(CampaignStore.saveAuction(state));
  }
  void nextLot() {
    state = _engine.nextLot(state);
    unawaited(CampaignStore.saveAuction(state));
  }


  /// Completes the remaining lots with rival strategy plus a roster-fill fallback.
  /// This makes a full season playable without requiring 180 manual lot advances.
  void simulateRemainingAuction() {
    stopLiveBidding();
    var processed = 0;
    while (state.currentPlayer != null &&
        state.phase != AuctionPhase.completed &&
        processed <= state.players.length) {
      processed++;
      if (state.phase == AuctionPhase.ready ||
          state.phase == AuctionPhase.bidding) {
        state = _engine.runRivalRound(state: state, rivals: _rivals);
        if (state.leadingTeamId == null) {
          final candidates = [...state.teams]
            ..sort((a, b) {
              final size = a.squad.length.compareTo(b.squad.length);
              if (size != 0) return size;
              return a.purseCr.compareTo(b.purseCr);
            });
          for (final team in candidates) {
            try {
              state = _engine.placeBid(state: state, teamId: team.id);
              break;
            } on StateError {
              continue;
            } on ArgumentError {
              continue;
            }
          }
        }
        state = _engine.closeLot(state);
      }
      if (state.phase == AuctionPhase.sold ||
          state.phase == AuctionPhase.unsold) {
        state = _engine.nextLot(state);
      }
    }
    _balanceMinimumSquads();
    unawaited(CampaignStore.saveAuction(state));
  }

  void _balanceMinimumSquads() {
    final teams = [...state.teams];
    for (var recipientIndex = 0; recipientIndex < teams.length; recipientIndex++) {
      while (teams[recipientIndex].squad.length < 11) {
        final recipient = teams[recipientIndex];
        var donorIndex = -1;
        AuctionPlayer? transfer;
        var transferCost = double.infinity;
        for (var candidateIndex = 0; candidateIndex < teams.length; candidateIndex++) {
          if (candidateIndex == recipientIndex || teams[candidateIndex].squad.length <= 11) continue;
          final donor = teams[candidateIndex];
          for (final player in donor.squad) {
            final cost = player.contract?.currentSalaryCrores ?? player.basePriceCr;
            if (player.isOverseas && recipient.overseasCount >= recipient.maxOverseas) continue;
            if (recipient.purseCr < cost || cost >= transferCost) continue;
            transfer = player;
            transferCost = cost;
            donorIndex = candidateIndex;
          }
        }
        final selectedPlayer = transfer;
        if (selectedPlayer == null || donorIndex < 0) break;
        final donor = teams[donorIndex];
        teams[donorIndex] = donor.copyWith(
          purseCr: donor.purseCr + transferCost,
          squad: donor.squad.where((player) => player.id != selectedPlayer.id).toList(),
        );
        teams[recipientIndex] = recipient.copyWith(
          purseCr: recipient.purseCr - transferCost,
          squad: [...recipient.squad, selectedPlayer],
        );
      }
    }
    state = state.copyWith(
      teams: teams,
      message: 'Auction complete • squads balanced for season readiness',
    );
  }

  void loadActiveCampaign() {
    stopLiveBidding();
    state = CampaignStore.loadActiveAuction() ?? createDemoAuction();
    unawaited(_syncPlayerModels(state));
    unawaited(CampaignStore.saveAuction(state));
  }

  void reset() {
    state = createDemoAuction();
    unawaited(CampaignStore.saveAuction(state));
  }
}
