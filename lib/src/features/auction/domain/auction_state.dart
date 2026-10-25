import 'player.dart';

enum AuctionPhase { ready, bidding, sold, unsold, completed }

class AuctionState {
  const AuctionState({
    required this.teams,
    required this.players,
    required this.currentPlayerIndex,
    required this.phase,
    required this.currentBidCr,
    required this.leadingTeamId,
    required this.bidHistory,
    required this.message,
  });

  final List<AuctionTeam> teams;
  final List<AuctionPlayer> players;
  final int currentPlayerIndex;
  final AuctionPhase phase;
  final double currentBidCr;
  final String? leadingTeamId;
  final List<String> bidHistory;
  final String message;

  AuctionPlayer? get currentPlayer =>
      currentPlayerIndex >= 0 && currentPlayerIndex < players.length
          ? players[currentPlayerIndex] : null;

  AuctionTeam? get leadingTeam {
    for (final team in teams) {
      if (team.id == leadingTeamId) return team;
    }
    return null;
  }

  AuctionState copyWith({
    List<AuctionTeam>? teams,
    List<AuctionPlayer>? players,
    int? currentPlayerIndex,
    AuctionPhase? phase,
    double? currentBidCr,
    String? leadingTeamId,
    bool clearLeader = false,
    List<String>? bidHistory,
    String? message,
  }) => AuctionState(
    teams: teams ?? this.teams,
    players: players ?? this.players,
    currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
    phase: phase ?? this.phase,
    currentBidCr: currentBidCr ?? this.currentBidCr,
    leadingTeamId: clearLeader ? null : (leadingTeamId ?? this.leadingTeamId),
    bidHistory: bidHistory ?? this.bidHistory,
    message: message ?? this.message,
  );
}
