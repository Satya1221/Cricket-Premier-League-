enum CricketFormat { test, odi, t20, hundred }

class FormatConfig {
  const FormatConfig._({
    required this.format,
    required this.maxOversPerInnings,
    required this.maxOversPerBowler,
    required this.ballsPerOver,
    required this.maxInningsPerTeam,
    required this.fatigueMultiplier,
    required this.baselineWicketChance,
  });

  factory FormatConfig.forFormat(CricketFormat format) => switch (format) {
        CricketFormat.t20 => const FormatConfig._(
            format: CricketFormat.t20,
            maxOversPerInnings: 20,
            maxOversPerBowler: 4,
            ballsPerOver: 6,
            maxInningsPerTeam: 1,
            fatigueMultiplier: 1,
            baselineWicketChance: 8,
          ),
        CricketFormat.odi => const FormatConfig._(
            format: CricketFormat.odi,
            maxOversPerInnings: 50,
            maxOversPerBowler: 10,
            ballsPerOver: 6,
            maxInningsPerTeam: 1,
            fatigueMultiplier: 0.8,
            baselineWicketChance: 8.5,
          ),
        CricketFormat.hundred => const FormatConfig._(
            format: CricketFormat.hundred,
            maxOversPerInnings: 20,
            maxOversPerBowler: 4,
            ballsPerOver: 5,
            maxInningsPerTeam: 1,
            fatigueMultiplier: 1.1,
            baselineWicketChance: 8,
          ),
        CricketFormat.test => const FormatConfig._(
            format: CricketFormat.test,
            maxOversPerInnings: 450,
            maxOversPerBowler: 99,
            ballsPerOver: 6,
            maxInningsPerTeam: 2,
            fatigueMultiplier: 0.3,
            baselineWicketChance: 12,
          ),
      };

  final CricketFormat format;
  /// For The Hundred this means 100 legal balls, represented as 20 five-ball sets.
  /// For Tests this is a configurable simulation cap, not a real innings limit.
  final int maxOversPerInnings;
  final int maxOversPerBowler;
  final int ballsPerOver;
  final int maxInningsPerTeam;
  final double fatigueMultiplier;
  final double baselineWicketChance;

  int get legalBallsPerInnings => maxOversPerInnings * ballsPerOver;

  bool get isMultiDay => format == CricketFormat.test;
}
