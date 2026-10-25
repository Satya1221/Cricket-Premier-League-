enum CoachSpecialty { batting, paceBowling, spinBowling, fielding, fitness, youthDevelopment }
class CoachingStaff {
  const CoachingStaff({required this.name, required this.specialty, required this.level, required this.salaryPerSeason});
  final String name;
  final CoachSpecialty specialty;
  final int level, salaryPerSeason;
}
class AcademyFacilities {
  const AcademyFacilities({this.trainingLevel = 1, this.youthAcademyLevel = 1});
  final int trainingLevel, youthAcademyLevel;
  int get upgradeCostTraining => trainingLevel >= 5 ? 0 : 150 * (trainingLevel + 1);
  int get upgradeCostAcademy => youthAcademyLevel >= 5 ? 0 : 125 * (youthAcademyLevel + 1);
  AcademyFacilities upgradeTraining() => trainingLevel >= 5 ? this : AcademyFacilities(trainingLevel: trainingLevel + 1, youthAcademyLevel: youthAcademyLevel);
  AcademyFacilities upgradeAcademy() => youthAcademyLevel >= 5 ? this : AcademyFacilities(trainingLevel: trainingLevel, youthAcademyLevel: youthAcademyLevel + 1);
  int potentialBonus(Iterable<CoachingStaff> staff) {
    final youthCoach = staff.where((s) => s.specialty == CoachSpecialty.youthDevelopment).fold<int>(0, (v, s) => v + s.level);
    final specialist = staff.fold<int>(0, (v, s) => v + s.level);
    return (youthAcademyLevel - 1) * 3 + (trainingLevel - 1) * 2 + (youthCoach * 2) + (specialist ~/ 4);
  }
  int adjustedPotentialCap({required int baseCap, required Iterable<CoachingStaff> staff}) => (baseCap + potentialBonus(staff)).clamp(1, 100);
}
class AcademyFinanceResult {
  const AcademyFinanceResult({required this.remainingBudget, required this.facilities, required this.success, required this.message});
  final int remainingBudget;
  final AcademyFacilities facilities;
  final bool success;
  final String message;
}
AcademyFinanceResult purchaseUpgrade({required int budget, required AcademyFacilities facilities, required bool youthAcademy}) {
  final cost = youthAcademy ? facilities.upgradeCostAcademy : facilities.upgradeCostTraining;
  if (cost == 0) return AcademyFinanceResult(remainingBudget: budget, facilities: facilities, success: false, message: 'Facility already at maximum level.');
  if (budget < cost) return AcademyFinanceResult(remainingBudget: budget, facilities: facilities, success: false, message: 'Insufficient franchise funds.');
  return AcademyFinanceResult(remainingBudget: budget - cost, facilities: youthAcademy ? facilities.upgradeAcademy() : facilities.upgradeTraining(), success: true, message: 'Upgrade purchased.');
}
