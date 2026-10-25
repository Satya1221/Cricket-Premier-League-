import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../match/domain/stadium_pitch_engine.dart';

class StadiumState {
  const StadiumState({required this.stadiums, required this.selectedStadiumId, this.franchiseFunds = 12000000, this.lastMatchRevenue = 0, this.lastAction = 'Select a home ground to shape your match strategy.'});
  final List<StadiumAsset> stadiums;
  final String selectedStadiumId;
  final int franchiseFunds, lastMatchRevenue;
  final String lastAction;
  StadiumAsset get selectedStadium => stadiums.firstWhere((s) => s.id == selectedStadiumId);
  StadiumState copyWith({List<StadiumAsset>? stadiums, String? selectedStadiumId, int? franchiseFunds, int? lastMatchRevenue, String? lastAction}) => StadiumState(
    stadiums: stadiums ?? this.stadiums, selectedStadiumId: selectedStadiumId ?? this.selectedStadiumId,
    franchiseFunds: franchiseFunds ?? this.franchiseFunds, lastMatchRevenue: lastMatchRevenue ?? this.lastMatchRevenue,
    lastAction: lastAction ?? this.lastAction);
}

class StadiumNotifier extends StateNotifier<StadiumState> {
  StadiumNotifier() : super(StadiumState(stadiums: defaultStadiums(), selectedStadiumId: 'chepauk'));
  void selectStadium(String id) {
    if (!state.stadiums.any((s) => s.id == id)) {
      throw ArgumentError.value(id, 'id', 'Unknown stadium.');
    }
    final selected = state.stadiums.firstWhere((s) => s.id == id);
    state = state.copyWith(selectedStadiumId: id, lastAction: 'Home ground changed to ${selected.name}.');
  }
  void expandBy(int seats) {
    final expanded = StadiumEconomy.expand(state.selectedStadium, seats: seats, availableFunds: state.franchiseFunds);
    final cost = seats * StadiumEconomy.expansionCostPerSeat;
    state = state.copyWith(stadiums: [for (final s in state.stadiums) if (s.id == expanded.id) expanded else s],
      franchiseFunds: state.franchiseFunds - cost, lastAction: 'Expanded ${expanded.name} by $seats seats for ₹$cost.');
  }
  void recordHomeMatch({double attendanceRate = 0.85}) {
    final revenue = StadiumEconomy.ticketRevenue(state.selectedStadium, attendanceRate: attendanceRate);
    state = state.copyWith(franchiseFunds: state.franchiseFunds + revenue, lastMatchRevenue: revenue, lastAction: 'Home match earned ₹$revenue in ticket revenue.');
  }
}
final stadiumProvider = StateNotifierProvider<StadiumNotifier, StadiumState>((ref) => StadiumNotifier());
