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
