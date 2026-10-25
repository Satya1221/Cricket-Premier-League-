enum InjuryType { hamstring, sideStrain, concussion, generalFatigue }
enum InjuryRiskBand { low, elevated, high, critical }
class PlayerWorkload {
  const PlayerWorkload({required this.playerId, required this.age, required this.pace, required this.fatigue, required this.recentBowlingBalls, required this.consecutiveMatchDays, this.existingInjury = false});
  final String playerId;
  final int age, pace, fatigue, recentBowlingBalls, consecutiveMatchDays;
  final bool existingInjury;
}
class MedicalAssessment {
  const MedicalAssessment({required this.playerId, required this.risk, required this.riskBand, required this.recommendedRestDays, required this.reasons});
  final String playerId;
  final int risk, recommendedRestDays;
  final InjuryRiskBand riskBand;
  final List<String> reasons;
}
class MedicalCenterEngine {
  MedicalAssessment assess(PlayerWorkload p) {
    var risk = (p.fatigue * .35 + p.recentBowlingBalls / 6 * .25 + p.consecutiveMatchDays * 3 + (p.age > 30 ? 8 : 0) + (p.pace > 85 ? 10 : 0) + (p.existingInjury ? 20 : 0)).round().clamp(0, 100);
    final reasons = <String>[];
    if (p.fatigue >= 65) reasons.add('High accumulated fatigue');
    if (p.recentBowlingBalls >= 180 && p.pace >= 80) reasons.add('Heavy fast-bowling workload');
    if (p.consecutiveMatchDays >= 4) reasons.add('Insufficient recovery between matches');
    if (p.existingInjury) reasons.add('Existing injury requires monitoring');
    final band = risk >= 80 ? InjuryRiskBand.critical : risk >= 60 ? InjuryRiskBand.high : risk >= 35 ? InjuryRiskBand.elevated : InjuryRiskBand.low;
    return MedicalAssessment(playerId: p.playerId, risk: risk, riskBand: band, recommendedRestDays: risk >= 80 ? 7 : risk >= 60 ? 4 : risk >= 35 ? 2 : 0, reasons: List.unmodifiable(reasons));
  }
  int recoveryDays({required int baseDays, required int physioLevel}) => (baseDays * (1 - physioLevel.clamp(0, 5) * .12)).ceil().clamp(1, baseDays);
}
