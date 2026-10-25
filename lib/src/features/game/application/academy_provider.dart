import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/academy_engine.dart';

class AcademyState {
  const AcademyState({
    this.budget = 1200,
    this.facilities = const AcademyFacilities(),
    this.staff = const [],
  });

  final int budget;
  final AcademyFacilities facilities;
  final List<CoachingStaff> staff;

  AcademyState copyWith({
    int? budget,
    AcademyFacilities? facilities,
    List<CoachingStaff>? staff,
  }) =>
      AcademyState(
        budget: budget ?? this.budget,
        facilities: facilities ?? this.facilities,
        staff: staff ?? this.staff,
      );
}

class AcademyNotifier extends StateNotifier<AcademyState> {
  AcademyNotifier() : super(const AcademyState());

  String upgrade({required bool youthAcademy}) {
    final result = purchaseUpgrade(
      budget: state.budget,
      facilities: state.facilities,
      youthAcademy: youthAcademy,
    );
    if (!result.success) return result.message;

    state = state.copyWith(
      budget: result.remainingBudget,
      facilities: result.facilities,
    );
    return youthAcademy
        ? 'Youth Academy upgraded to Level ${state.facilities.youthAcademyLevel}. Potential cap increased.'
        : 'Training Facilities upgraded to Level ${state.facilities.trainingLevel}. Development bonuses increased.';
  }

  String hireCoach(CoachingStaff coach) {
    if (state.staff.any((s) => s.specialty == coach.specialty)) {
      return 'A coach for this specialty is already hired.';
    }
    if (state.budget < coach.salaryPerSeason) {
      return 'Insufficient credits to hire this coach.';
    }
    state = state.copyWith(
      budget: state.budget - coach.salaryPerSeason,
      staff: [...state.staff, coach],
    );
    return '${coach.name} hired for ${coach.salaryPerSeason} credits per season.';
  }

  int potentialCap(int baseCap) => state.facilities.adjustedPotentialCap(
        baseCap: baseCap,
        staff: state.staff,
      );
}

final academyProvider =
    StateNotifierProvider<AcademyNotifier, AcademyState>(
  (ref) => AcademyNotifier(),
);
