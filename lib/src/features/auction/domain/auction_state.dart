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

  Map<String, dynamic> toJson() => {
        'teams': teams.map((team) => team.toJson()).toList(),
        'players': players.map((player) => player.toJson()).toList(),
        'currentPlayerIndex': currentPlayerIndex,
        'phase': phase.name,
        'currentBidCr': currentBidCr,
        'leadingTeamId': leadingTeamId,
        'bidHistory': bidHistory,
        'message': message,
      };

  factory AuctionState.fromJson(Map<String, dynamic> json) => AuctionState(
        teams: ((json['teams'] as List?) ?? const [])
            .whereType<Map>()
            .map((team) => AuctionTeam.fromJson(team.cast<String, dynamic>()))
            .toList(growable: false),
        players: ((json['players'] as List?) ?? const [])
            .whereType<Map>()
            .map((player) => AuctionPlayer.fromJson(player.cast<String, dynamic>()))
            .toList(growable: false),
        currentPlayerIndex: (json['currentPlayerIndex'] as num?)?.toInt() ?? 0,
        phase: AuctionPhase.values.firstWhere(
          (value) => value.name == json['phase'],
          orElse: () => AuctionPhase.ready,
        ),
        currentBidCr: (json['currentBidCr'] as num?)?.toDouble() ?? 0,
        leadingTeamId: json['leadingTeamId'] as String?,
        bidHistory: ((json['bidHistory'] as List?) ?? const []).cast<String>(),
        message: json['message'] as String? ?? 'Campaign loaded',
      );

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
