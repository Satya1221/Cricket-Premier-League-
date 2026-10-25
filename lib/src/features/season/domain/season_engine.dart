/// Headless tournament season state, fixtures, standings, and player leaderboards.
class SeasonFranchise {
  const SeasonFranchise({required this.id, required this.name});
  final String id;
  final String name;
}

class SeasonFixture {
  SeasonFixture({
    required this.round,
    required this.homeTeam,
    required this.awayTeam,
  });

  final int round;
  final SeasonFranchise homeTeam;
  final SeasonFranchise awayTeam;
  bool isCompleted = false;
}

class StandingsRecord {
  StandingsRecord(this.team);

  final SeasonFranchise team;
  int matchesPlayed = 0;
  int wins = 0;
  int losses = 0;
  int ties = 0;
  int noResults = 0;
  int points = 0;
  int runsScored = 0;
  int ballsFaced = 0;
  int runsConceded = 0;
  int ballsBowled = 0;

  /// NRR uses balls as the denominator and therefore handles partial overs.
  /// A zero denominator contributes zero for that innings side.
  double get netRunRate {
    final scoringRate = ballsFaced == 0 ? 0.0 : runsScored * 6 / ballsFaced;
    final concedingRate =
        ballsBowled == 0 ? 0.0 : runsConceded * 6 / ballsBowled;
    return scoringRate - concedingRate;
  }
}

class PlayerSeasonStats {
  PlayerSeasonStats(this.playerId, this.playerName);

  final String playerId;
  String playerName;
  int totalRuns = 0;
  int totalWickets = 0;
  int matches = 0;
}

enum SeasonResultType { win, tie, noResult }

class SeasonMatchResult {
  const SeasonMatchResult({
    required this.fixture,
    required this.resultType,
    required this.teamARuns,
    required this.teamABallsFaced,
    required this.teamABallsBowled,
    required this.teamBRuns,
    required this.teamBBallsFaced,
    required this.teamBBallsBowled,
    this.winnerTeamId,
    this.playerRuns = const {},
    this.playerWickets = const {},
    this.playerNames = const {},
  });

  final SeasonFixture fixture;
  final SeasonResultType resultType;
  final String? winnerTeamId;
  final int teamARuns;
  final int teamABallsFaced;
  final int teamABallsBowled;
  final int teamBRuns;
  final int teamBBallsFaced;
  final int teamBBallsBowled;
  final Map<String, int> playerRuns;
  final Map<String, int> playerWickets;
  final Map<String, String> playerNames;
}

class SeasonEngine {
  SeasonEngine(List<SeasonFranchise> teams)
      : teams = List.unmodifiable(teams) {
    if (teams.length < 2) {
      throw ArgumentError('A season requires at least two franchises.');
    }
    final ids = teams.map((team) => team.id).toSet();
    if (ids.length != teams.length) {
      throw ArgumentError('Franchise IDs must be unique.');
    }
    for (final team in teams) {
      standings[team.id] = StandingsRecord(team);
    }
  }

  final List<SeasonFranchise> teams;
  final List<SeasonFixture> schedule = [];
  final Map<String, StandingsRecord> standings = {};
  final Map<String, PlayerSeasonStats> playerStats = {};

  bool get isComplete => schedule.isNotEmpty && schedule.every((f) => f.isCompleted);

  /// Creates a single round-robin schedule. For odd team counts, each round
  /// includes one bye. Team 0 stays fixed while the remaining teams rotate.
  void generateSchedule() {
    if (schedule.isNotEmpty) {
      throw StateError('Schedule has already been generated.');
    }
    final hasBye = teams.length.isOdd;
    final slots = <SeasonFranchise?>[
      ...teams,
      if (hasBye) null,
    ];
    final teamCount = slots.length;
    final rounds = teamCount - 1;
    final matchesPerRound = teamCount ~/ 2;

    for (var round = 0; round < rounds; round++) {
      for (var match = 0; match < matchesPerRound; match++) {
        final home = slots[match];
        final away = slots[teamCount - 1 - match];
        if (home != null && away != null) {
          schedule.add(SeasonFixture(
            round: round + 1,
            homeTeam: home,
            awayTeam: away,
          ));
        }
      }
      final last = slots.removeLast();
      slots.insert(1, last);
    }
  }

  /// Records a completed match exactly once and updates both team records.
  /// Team A/B batting and bowling figures must describe the actual innings,
  /// including all legal balls faced/bowled used by the match rules.
  void processMatchResult(SeasonMatchResult result) {
    final fixture = result.fixture;
    if (!schedule.contains(fixture)) {
      throw ArgumentError('Fixture does not belong to this season schedule.');
    }
    if (fixture.isCompleted) {
      throw StateError('This fixture has already been processed.');
    }
    if (result.teamARuns < 0 ||
        result.teamBRuns < 0 ||
        result.teamABallsFaced < 0 ||
        result.teamABallsBowled < 0 ||
        result.teamBBallsFaced < 0 ||
        result.teamBBallsBowled < 0) {
      throw ArgumentError('Runs and ball counts cannot be negative.');
    }

    final a = fixture.homeTeam;
    final b = fixture.awayTeam;
    if (result.resultType == SeasonResultType.win &&
        result.winnerTeamId != a.id &&
        result.winnerTeamId != b.id) {
      throw ArgumentError('Winner must be one of the fixture teams.');
    }
    if (result.resultType != SeasonResultType.win &&
        result.winnerTeamId != null) {
      throw ArgumentError('Ties and no-results cannot have a winner.');
    }
    if (result.resultType == SeasonResultType.win &&
        result.teamARuns == result.teamBRuns) {
      throw ArgumentError('A tied score cannot be recorded as a win.');
    }

    final aRecord = standings[a.id]!;
    final bRecord = standings[b.id]!;

    // A's innings and bowling figures.
    aRecord.matchesPlayed++;
    aRecord.runsScored += result.teamARuns;
    aRecord.ballsFaced += result.teamABallsFaced;
    aRecord.runsConceded += result.teamBRuns;
    aRecord.ballsBowled += result.teamABallsBowled;

    // B's innings and bowling figures.
    bRecord.matchesPlayed++;
    bRecord.runsScored += result.teamBRuns;
    bRecord.ballsFaced += result.teamBBallsFaced;
    bRecord.runsConceded += result.teamARuns;
    bRecord.ballsBowled += result.teamBBallsBowled;

    switch (result.resultType) {
      case SeasonResultType.win:
        final winner = result.winnerTeamId == a.id ? aRecord : bRecord;
        final loser = result.winnerTeamId == a.id ? bRecord : aRecord;
        winner.wins++;
        winner.points += 2;
        loser.losses++;
        break;
      case SeasonResultType.tie:
        aRecord.ties++;
        bRecord.ties++;
        aRecord.points++;
        bRecord.points++;
        break;
      case SeasonResultType.noResult:
        aRecord.noResults++;
        bRecord.noResults++;
        aRecord.points++;
        bRecord.points++;
        break;
    }

    for (final entry in result.playerRuns.entries) {
      if (entry.value < 0) {
        throw ArgumentError('Player runs cannot be negative.');
      }
      final id = entry.key;
      final name = result.playerNames[id] ?? id;
      final stats = playerStats.putIfAbsent(id, () => PlayerSeasonStats(id, name));
      stats.playerName = name;
      stats.totalRuns += entry.value;
    }
    for (final entry in result.playerWickets.entries) {
      if (entry.value < 0) {
        throw ArgumentError('Player wickets cannot be negative.');
      }
      final id = entry.key;
      final name = result.playerNames[id] ?? id;
      final stats = playerStats.putIfAbsent(id, () => PlayerSeasonStats(id, name));
      stats.playerName = name;
      stats.totalWickets += entry.value;
    }
    fixture.isCompleted = true;
  }

  List<StandingsRecord> get sortedStandings {
    final records = standings.values.toList();
    records.sort((a, b) {
      final byPoints = b.points.compareTo(a.points);
      if (byPoints != 0) return byPoints;
      final byNrr = b.netRunRate.compareTo(a.netRunRate);
      if (byNrr != 0) return byNrr;
      final byWins = b.wins.compareTo(a.wins);
      if (byWins != 0) return byWins;
      return a.team.name.compareTo(b.team.name);
    });
    return List.unmodifiable(records);
  }

  List<PlayerSeasonStats> get orangeCapLeaderboard {
    final players = playerStats.values.toList()
      ..sort((a, b) {
        final byRuns = b.totalRuns.compareTo(a.totalRuns);
        if (byRuns != 0) return byRuns;
        return a.playerName.compareTo(b.playerName);
      });
    return List.unmodifiable(players);
  }

  List<PlayerSeasonStats> get purpleCapLeaderboard {
    final players = playerStats.values.toList()
      ..sort((a, b) {
        final byWickets = b.totalWickets.compareTo(a.totalWickets);
        if (byWickets != 0) return byWickets;
        return a.playerName.compareTo(b.playerName);
      });
    return List.unmodifiable(players);
  }
}
