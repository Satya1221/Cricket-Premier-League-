import 'auction_state.dart';
import 'player.dart';
import 'player_contract.dart';

Map<String, dynamic> auctionStateToJson(AuctionState state) => {
      'teams': state.teams.map(_teamToJson).toList(),
      'players': state.players.map(_playerToJson).toList(),
      'currentPlayerIndex': state.currentPlayerIndex,
      'phase': state.phase.name,
      'currentBidCr': state.currentBidCr,
      'leadingTeamId': state.leadingTeamId,
      'bidHistory': state.bidHistory,
      'message': state.message,
    };

AuctionState auctionStateFromJson(Map<String, dynamic> json) {
  final phaseName = json['phase'] as String? ?? 'ready';
  return AuctionState(
    teams: (json['teams'] as List<dynamic>? ?? const [])
        .map((value) => _teamFromJson(Map<String, dynamic>.from(value as Map)))
        .toList(growable: false),
    players: (json['players'] as List<dynamic>? ?? const [])
        .map((value) => _playerFromJson(Map<String, dynamic>.from(value as Map)))
        .toList(growable: false),
    currentPlayerIndex: (json['currentPlayerIndex'] as num?)?.toInt() ?? 0,
    phase: AuctionPhase.values.firstWhere(
      (value) => value.name == phaseName,
      orElse: () => AuctionPhase.ready,
    ),
    currentBidCr: (json['currentBidCr'] as num?)?.toDouble() ?? 0,
    leadingTeamId: json['leadingTeamId'] as String?,
    bidHistory: (json['bidHistory'] as List<dynamic>? ?? const [])
        .map((value) => value.toString())
        .toList(growable: false),
    message: json['message'] as String? ?? 'Save loaded.',
  );
}

Map<String, dynamic> _teamToJson(AuctionTeam team) => {
      'id': team.id,
      'name': team.name,
      'shortName': team.shortName,
      'purseCr': team.purseCr,
      'maxSquadSize': team.maxSquadSize,
      'minSquadSize': team.minSquadSize,
      'maxOverseas': team.maxOverseas,
      'maxOverseasPlayingXi': team.maxOverseasPlayingXi,
      'squad': team.squad.map(_playerToJson).toList(),
    };

AuctionTeam _teamFromJson(Map<String, dynamic> json) => AuctionTeam(
      id: json['id'] as String,
      name: json['name'] as String,
      shortName: json['shortName'] as String? ?? json['id'] as String,
      purseCr: (json['purseCr'] as num?)?.toDouble() ?? 120,
      maxSquadSize: (json['maxSquadSize'] as num?)?.toInt() ?? 25,
      minSquadSize: (json['minSquadSize'] as num?)?.toInt() ?? 18,
      maxOverseas: (json['maxOverseas'] as num?)?.toInt() ?? 8,
      maxOverseasPlayingXi: (json['maxOverseasPlayingXi'] as num?)?.toInt() ?? 4,
      squad: (json['squad'] as List<dynamic>? ?? const [])
          .map((value) => _playerFromJson(Map<String, dynamic>.from(value as Map)))
          .toList(growable: false),
    );

Map<String, dynamic> _playerToJson(AuctionPlayer player) => {
      'id': player.id,
      'name': player.name,
      'nation': player.nation,
      'role': player.role.name,
      'overall': player.overall,
      'potential': player.potential,
      'basePriceCr': player.basePriceCr,
      'isOverseas': player.isOverseas,
      'age': player.age,
      'batting': player.batting,
      'bowling': player.bowling,
      'fielding': player.fielding,
      'form': player.form,
      'contract': player.contract == null
          ? null
          : {
              'currentSalaryCrores': player.contract!.currentSalaryCrores,
              'basePriceCrores': player.contract!.basePriceCrores,
              'yearsRemaining': player.contract!.yearsRemaining,
              'isOverseas': player.contract!.isOverseas,
              'signedSeason': player.contract!.signedSeason,
            },
    };

AuctionPlayer _playerFromJson(Map<String, dynamic> json) {
  final roleName = json['role'] as String? ?? 'batter';
  final contractJson = json['contract'];
  final Map<String, dynamic>? contractMap =
      contractJson is Map ? Map<String, dynamic>.from(contractJson) : null;
  return AuctionPlayer(
    id: json['id'] as String,
    name: json['name'] as String,
    nation: json['nation'] as String? ?? 'India',
    role: PlayerRole.values.firstWhere(
      (value) => value.name == roleName,
      orElse: () => PlayerRole.batter,
    ),
    overall: (json['overall'] as num?)?.toInt() ?? 60,
    potential: (json['potential'] as num?)?.toInt() ?? 70,
    basePriceCr: (json['basePriceCr'] as num?)?.toDouble() ?? 0.2,
    isOverseas: json['isOverseas'] as bool? ?? false,
    age: (json['age'] as num?)?.toInt() ?? 24,
    batting: (json['batting'] as num?)?.toInt() ?? 60,
    bowling: (json['bowling'] as num?)?.toInt() ?? 40,
    fielding: (json['fielding'] as num?)?.toInt() ?? 60,
    form: (json['form'] as num?)?.toInt() ?? 60,
    contract: contractMap == null
        ? null
        : PlayerContract(
            currentSalaryCrores: (contractMap['currentSalaryCrores'] as num?)?.toDouble() ?? 0,
            basePriceCrores: (contractMap['basePriceCrores'] as num?)?.toDouble() ?? 0,
            yearsRemaining: (contractMap['yearsRemaining'] as num?)?.toInt() ?? 1,
            isOverseas: contractMap['isOverseas'] as bool? ?? false,
            signedSeason: (contractMap['signedSeason'] as num?)?.toInt() ?? 1,
          ),
  );
}
