import 'player_contract.dart';

enum PlayerRole { batter, bowler, allRounder, wicketKeeper }

class AuctionPlayer {
  const AuctionPlayer({
    required this.id,
    required this.name,
    required this.nation,
    required this.role,
    required this.overall,
    required this.potential,
    required this.basePriceCr,
    this.isOverseas = false,
    this.age = 24,
    this.batting = 70,
    this.bowling = 45,
    this.fielding = 70,
    this.form = 70,
    this.contract,
  }) : assert(overall >= 1 && overall <= 100),
       assert(potential >= 1 && potential <= 100),
       assert(basePriceCr >= 0);

  final String id;
  final String name;
  final String nation;
  final PlayerRole role;
  final int overall;
  final int potential;
  final double basePriceCr;
  final bool isOverseas;
  final int age;
  final int batting;
  final int bowling;
  final int fielding;
  final int form;
  final PlayerContract? contract;

  double get annualSalaryCr => contract?.currentSalaryCrores ?? 0;
  int get contractYearsRemaining => contract?.yearsRemaining ?? 0;

  double get growthHeadroom => (potential - overall).clamp(0, 100).toDouble();

  Map<String, dynamic> toJson() => {
        'id': id, 'name': name, 'nation': nation, 'role': role.name,
        'overall': overall, 'potential': potential, 'basePriceCr': basePriceCr,
        'isOverseas': isOverseas, 'age': age, 'batting': batting,
        'bowling': bowling, 'fielding': fielding, 'form': form,
        'contract': contract == null ? null : {
          'currentSalaryCrores': contract!.currentSalaryCrores,
          'basePriceCrores': contract!.basePriceCrores,
          'yearsRemaining': contract!.yearsRemaining,
          'isOverseas': contract!.isOverseas,
          'signedSeason': contract!.signedSeason,
        },
      };

  factory AuctionPlayer.fromJson(Map<String, dynamic> json) {
    final contractJson = (json['contract'] as Map?)?.cast<String, dynamic>();
    return AuctionPlayer(
      id: json['id'] as String,
      name: json['name'] as String,
      nation: json['nation'] as String? ?? 'India',
      role: PlayerRole.values.firstWhere(
        (value) => value.name == json['role'],
        orElse: () => PlayerRole.batter,
      ),
      overall: (json['overall'] as num?)?.toInt() ?? 60,
      potential: (json['potential'] as num?)?.toInt() ?? 65,
      basePriceCr: (json['basePriceCr'] as num?)?.toDouble() ?? 0.2,
      isOverseas: json['isOverseas'] as bool? ?? false,
      age: (json['age'] as num?)?.toInt() ?? 24,
      batting: (json['batting'] as num?)?.toInt() ?? 60,
      bowling: (json['bowling'] as num?)?.toInt() ?? 45,
      fielding: (json['fielding'] as num?)?.toInt() ?? 60,
      form: (json['form'] as num?)?.toInt() ?? 60,
      contract: contractJson == null ? null : PlayerContract(
        currentSalaryCrores: (contractJson['currentSalaryCrores'] as num?)?.toDouble() ?? 0,
        basePriceCrores: (contractJson['basePriceCrores'] as num?)?.toDouble() ?? 0,
        yearsRemaining: (contractJson['yearsRemaining'] as num?)?.toInt() ?? 1,
        isOverseas: contractJson['isOverseas'] as bool? ?? false,
        signedSeason: (contractJson['signedSeason'] as num?)?.toInt() ?? 1,
      ),
    );
  }

  String get roleLabel => switch (role) {
    PlayerRole.batter => 'BATTER',
    PlayerRole.bowler => 'BOWLER',
    PlayerRole.allRounder => 'ALL-ROUNDER',
    PlayerRole.wicketKeeper => 'WICKETKEEPER',
  };
}

class AuctionTeam {
  const AuctionTeam({
    required this.id,
    required this.name,
    required this.shortName,
    required this.purseCr,
    this.squad = const [],
    this.maxSquadSize = 25,
    this.minSquadSize = 18,
    this.maxOverseas = 8,
    this.maxOverseasPlayingXi = 4,
  });

  final String id;
  final String name;
  final String shortName;
  final double purseCr;
  final List<AuctionPlayer> squad;
  final int maxSquadSize;
  final int minSquadSize;
  final int maxOverseas;
  final int maxOverseasPlayingXi;

  Map<String, dynamic> toJson() => {
        'id': id, 'name': name, 'shortName': shortName, 'purseCr': purseCr,
        'squad': squad.map((player) => player.toJson()).toList(),
        'maxSquadSize': maxSquadSize, 'minSquadSize': minSquadSize,
        'maxOverseas': maxOverseas, 'maxOverseasPlayingXi': maxOverseasPlayingXi,
      };

  factory AuctionTeam.fromJson(Map<String, dynamic> json) => AuctionTeam(
        id: json['id'] as String,
        name: json['name'] as String,
        shortName: json['shortName'] as String? ?? 'CLB',
        purseCr: (json['purseCr'] as num?)?.toDouble() ?? 120,
        squad: ((json['squad'] as List?) ?? const [])
            .whereType<Map>()
            .map((player) => AuctionPlayer.fromJson(player.cast<String, dynamic>()))
            .toList(growable: false),
        maxSquadSize: (json['maxSquadSize'] as num?)?.toInt() ?? 25,
        minSquadSize: (json['minSquadSize'] as num?)?.toInt() ?? 18,
        maxOverseas: (json['maxOverseas'] as num?)?.toInt() ?? 8,
        maxOverseasPlayingXi: (json['maxOverseasPlayingXi'] as num?)?.toInt() ?? 4,
      );

  /// Auction expenditure uses the winning hammer price, not the player's base price.
  double get spentCr => squad.fold<double>(
        0,
        (sum, player) => sum + (player.contract?.currentSalaryCrores ?? player.basePriceCr),
      );
  int get overseasCount => squad.where((p) => p.isOverseas).length;
  int get remainingSlots => maxSquadSize - squad.length;

  AuctionTeam copyWith({double? purseCr, List<AuctionPlayer>? squad}) => AuctionTeam(
    id: id, name: name, shortName: shortName,
    purseCr: purseCr ?? this.purseCr,
    squad: squad ?? this.squad,
    maxSquadSize: maxSquadSize, minSquadSize: minSquadSize,
    maxOverseas: maxOverseas, maxOverseasPlayingXi: maxOverseasPlayingXi,
  );
}
