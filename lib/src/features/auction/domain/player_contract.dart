/// Auction contract: the hammer price is the guaranteed per-season salary.
/// Domain-only until a database schema and code generation are configured.
class PlayerContract {
  const PlayerContract({
    this.currentSalaryCrores = 0,
    this.basePriceCrores = 0,
    this.yearsRemaining = 1,
    this.isOverseas = false,
    this.signedSeason = 1,
  }) : assert(currentSalaryCrores >= 0),
       assert(basePriceCrores >= 0),
       assert(yearsRemaining >= 0),
       assert(signedSeason >= 1);

  final double currentSalaryCrores;
  final double basePriceCrores;
  final int yearsRemaining;
  final bool isOverseas;
  final int signedSeason;

  PlayerContract copyWith({double? currentSalaryCrores, double? basePriceCrores, int? yearsRemaining, bool? isOverseas, int? signedSeason}) => PlayerContract(
    currentSalaryCrores: currentSalaryCrores ?? this.currentSalaryCrores,
    basePriceCrores: basePriceCrores ?? this.basePriceCrores,
    yearsRemaining: yearsRemaining ?? this.yearsRemaining,
    isOverseas: isOverseas ?? this.isOverseas,
    signedSeason: signedSeason ?? this.signedSeason,
  );

  PlayerContract advanceSeason() => copyWith(yearsRemaining: yearsRemaining > 0 ? yearsRemaining - 1 : 0);
}
