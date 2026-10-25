import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/medical_center_engine.dart';

class InjuryRecord {
  const InjuryRecord({required this.playerId, required this.injuryType, required this.matchesRemainingOut, required this.severityRisk, this.notes = ''});
  final String playerId, injuryType, notes;
  final int matchesRemainingOut, severityRisk;
}
class MedicalState {
  const MedicalState({this.injuries = const [], this.assessments = const [], this.physioLevel = 0});
  final List<InjuryRecord> injuries;
  final List<MedicalAssessment> assessments;
  final int physioLevel;
  MedicalState copyWith({List<InjuryRecord>? injuries, List<MedicalAssessment>? assessments, int? physioLevel}) => MedicalState(injuries: injuries ?? this.injuries, assessments: assessments ?? this.assessments, physioLevel: physioLevel ?? this.physioLevel);
}
class MedicalNotifier extends StateNotifier<MedicalState> {
  MedicalNotifier() : super(const MedicalState());
  final _engine = MedicalCenterEngine();
  void assessWorkloads(List<PlayerWorkload> workloads) {
    final assessments = workloads.map(_engine.assess).toList(growable: false);
    final injuries = [...state.injuries];
    for (final a in assessments.where((a) => a.riskBand == InjuryRiskBand.critical)) {
      if (!injuries.any((i) => i.playerId == a.playerId)) {
        injuries.add(InjuryRecord(playerId: a.playerId, injuryType: 'High workload injury risk', matchesRemainingOut: a.recommendedRestDays, severityRisk: 5, notes: a.reasons.join(' • ')));
      }
    }
    state = state.copyWith(assessments: assessments, injuries: injuries);
  }
  void addInjury(InjuryRecord record) => state = state.copyWith(injuries: [...state.injuries.where((i) => i.playerId != record.playerId), record]);
  void recoverPlayer(String playerId) => state = state.copyWith(injuries: state.injuries.where((i) => i.playerId != playerId).toList(growable: false));
  void setPhysioLevel(int level) => state = state.copyWith(physioLevel: level.clamp(0, 5));
}
final medicalCenterProvider = StateNotifierProvider<MedicalNotifier, MedicalState>((ref) => MedicalNotifier());