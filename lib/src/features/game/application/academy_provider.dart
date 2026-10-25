import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/academy_engine.dart';
class AcademyState {
  const AcademyState({this.budget = 1200, this.facilities = const AcademyFacilities(), this.staff = const []});
  final int budget; final AcademyFacilities facilities; final List<CoachingStaff> staff;
  AcademyState copyWith({int? budget, AcademyFacilities? facilities, List<CoachingStaff>? staff}) => AcademyState(budget: budget ?? this.budget, facilities: facilities ?? this.facilities, staff: staff ?? this.staff);
}
class AcademyNotifier extends StateNotifier<AcademyState> {
  AcademyNotifier() : super(const AcademyState());
  void upgrade({required bool youthAcademy}) {
    final result = purchaseUpgrade(budget: state.budget, facilities: state.facilities, youthAcademy: youthAcademy);
    if (result.success) {
      state = state.copyWith(budget: result.remainingBudget, facilities: result.facilities);
    }
  }
  void hireCoach(CoachingStaff coach) {
    if (state.staff.any((s) => s.specialty == coach.specialty) || state.budget < coach.salaryPerSeason) {
      return;
    }
    state = state.copyWith(budget: state.budget - coach.salaryPerSeason, staff: [...state.staff, coach]);
  }
  int potentialCap(int baseCap) => state.facilities.adjustedPotentialCap(baseCap: baseCap, staff: state.staff);
}
final academyProvider = StateNotifierProvider<AcademyNotifier, AcademyState>((ref) => AcademyNotifier());