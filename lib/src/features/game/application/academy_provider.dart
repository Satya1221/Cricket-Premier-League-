import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../models/franchise_model.dart';
import '../../../../services/treasury_service.dart';

import '../domain/academy_engine.dart';

class AcademyState {
  const AcademyState({
    this.facilities = const AcademyFacilities(),
    this.staff = const [],
  });

  final AcademyFacilities facilities;
  final List<CoachingStaff> staff;

  AcademyState copyWith({
    AcademyFacilities? facilities,
    List<CoachingStaff>? staff,
  }) =>
      AcademyState(
        facilities: facilities ?? this.facilities,
        staff: staff ?? this.staff,
      );
}

class AcademyNotifier extends StateNotifier<AcademyState> {
  AcademyNotifier() : super(_initial());
  final TreasuryService _treasury=const TreasuryService();
  static AcademyState _initial(){final f=Hive.box<FranchiseModel>('franchises').get('cpl')??const FranchiseModel(id:'cpl');return AcademyState(facilities:AcademyFacilities(trainingLevel:f.trainingFacilityLevel.clamp(1,5).toInt(),youthAcademyLevel:f.youthAcademyLevel.clamp(1,5).toInt()));}

  Future<String> upgrade({required bool youthAcademy}) async {
    final currentLevel=youthAcademy?state.facilities.youthAcademyLevel:state.facilities.trainingLevel;
    if(currentLevel>=5)return 'Facility already at maximum level.';
    final nextLevel=currentLevel+1;
    final cost=youthAcademy?(nextLevel>=5?5000000:2500000+(nextLevel-2)*1000000):2500000;
    final ok=youthAcademy
      ?await _treasury.upgradeAcademy(level:nextLevel,costRupees:cost)
      :await _treasury.spend(rupees:cost,description:'Training facility upgrade to level $nextLevel',category:'Academy');
    if(!ok)return 'Insufficient operating treasury for this upgrade.';
    if(!youthAcademy){final f=_treasury.franchise;await Hive.box<FranchiseModel>('franchises').put('cpl',f.copyWith(trainingFacilityLevel:nextLevel));}
    final facilities=youthAcademy?state.facilities.upgradeAcademy():state.facilities.upgradeTraining();
    state=state.copyWith(facilities:facilities);
    return '${youthAcademy?'Youth Academy':'Training Facilities'} upgraded to Level $nextLevel for ₹$cost.';
  }

  Future<String> hireCoach(CoachingStaff coach) async {
    if(state.staff.any((s)=>s.specialty==coach.specialty))return 'A coach for this specialty is already hired.';
    const salaryRupees=2500000;
    final ok=await _treasury.spend(rupees:salaryRupees,description:'Hire ${coach.name} for one season',category:'Staff');
    if(!ok)return 'Insufficient operating treasury to hire this coach.';
    state=state.copyWith(staff:[...state.staff,coach]);
    return '${coach.name} hired for ₹$salaryRupees this season.';
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
