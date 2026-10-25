import '../../match/domain/format_config.dart';

/// A player can represent their country and hold contracts across multiple leagues.
enum PlayerContractType { national, ipl, psl, hundred, otherLeague }

class PlayerContract {
  const PlayerContract({
    required this.teamId,
    required this.competitionId,
    required this.type,
    this.startYear,
    this.endYear,
  }) : assert(endYear == null || startYear == null || endYear >= startYear);

  final String teamId;
  final String competitionId;
  final PlayerContractType type;
  final int? startYear;
  final int? endYear;

  bool isActiveIn(int year) =>
      (startYear == null || year >= startYear!) &&
      (endYear == null || year <= endYear!);
}

/// Domain-only model: persistence annotations are intentionally omitted until
/// the project has a configured Isar schema and generated collection files.
class GlobalPlayer {
  GlobalPlayer({
    required this.id,
    required this.name,
    required this.nationality,
    required this.t20Rating,
    required this.odiRating,
    required this.testRating,
    this.age = 18,
    this.fatigueLevel = 0,
    List<PlayerContract> contracts = const [],
  })  : assert(id != ''),
        assert(name != ''),
        assert(nationality != ''),
        assert(t20Rating >= 1 && t20Rating <= 100),
        assert(odiRating >= 1 && odiRating <= 100),
        assert(testRating >= 1 && testRating <= 100),
        assert(age >= 15),
        assert(fatigueLevel >= 0 && fatigueLevel <= 100),
        contracts = List.unmodifiable(contracts);

  final String id;
  final String name;
  final String nationality;
  final int age;
  final int t20Rating;
  final int odiRating;
  final int testRating;
  final List<PlayerContract> contracts;
  double fatigueLevel;

  String? get nationalTeamId => _contractTeam(PlayerContractType.national);
  String? get iplFranchiseId => _contractTeam(PlayerContractType.ipl);
  String? get pslFranchiseId => _contractTeam(PlayerContractType.psl);
  String? get hundredFranchiseId => _contractTeam(PlayerContractType.hundred);

  String? _contractTeam(PlayerContractType type) {
    for (final contract in contracts.reversed) {
      if (contract.type == type) return contract.teamId;
    }
    return null;
  }

  int ratingFor(CricketFormat format) => switch (format) {
        CricketFormat.test => testRating,
        CricketFormat.odi => odiRating,
        CricketFormat.t20 || CricketFormat.hundred => t20Rating,
      };

  GlobalPlayer copyWith({
    int? age,
    int? t20Rating,
    int? odiRating,
    int? testRating,
    double? fatigueLevel,
    List<PlayerContract>? contracts,
  }) => GlobalPlayer(
        id: id,
        name: name,
        nationality: nationality,
        age: age ?? this.age,
        t20Rating: t20Rating ?? this.t20Rating,
        odiRating: odiRating ?? this.odiRating,
        testRating: testRating ?? this.testRating,
        fatigueLevel: fatigueLevel ?? this.fatigueLevel,
        contracts: contracts ?? this.contracts,
      );
}

