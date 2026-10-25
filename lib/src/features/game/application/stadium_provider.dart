import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../match/domain/stadium_pitch_engine.dart';
import '../../../../services/treasury_service.dart';

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
  StadiumNotifier() : super(_initial());
  static StadiumState _initial()=>StadiumState(stadiums:defaultStadiums(),selectedStadiumId:'chepauk',franchiseFunds:const TreasuryService().franchise.stadiumFunds);
  final TreasuryService _treasury = const TreasuryService();
  void selectStadium(String id) {
    if (!state.stadiums.any((s) => s.id == id)) {
      throw ArgumentError.value(id, 'id', 'Unknown stadium.');
    }
    final selected = state.stadiums.firstWhere((s) => s.id == id);
    state = state.copyWith(selectedStadiumId: id, lastAction: 'Home ground changed to ${selected.name}.');
  }
  Future<void> expandBy(int seats) async {
    if(seats<=0)throw ArgumentError.value(seats,'seats','Must be positive.');
    final current=state.selectedStadium;
    if(current.capacity+seats>65000)throw StateError('IPL stadium capacity cannot exceed 65000 seats.');
    final ok=await _treasury.expandStadium(addedSeats:seats);
    if(!ok)throw StateError('Insufficient operating treasury: stadium expansion costs ₹60 lakh.');
    final expanded=current.copyWith(capacity:current.capacity+seats);
    state=state.copyWith(stadiums:[for(final s in state.stadiums)if(s.id==expanded.id)expanded else s],
      franchiseFunds:_treasury.franchise.stadiumFunds,lastAction:'Expanded ${expanded.name} by $seats seats for ₹60 lakh.');
  }
  Future<void> recordHomeMatch({double attendanceRate=1.0}) async {
    final stadium=state.selectedStadium;
    final capacity=(stadium.capacity*attendanceRate).round();
    final revenue=await _treasury.recordTicketRevenue(capacity:capacity,ticketPriceRupees:stadium.ticketPrice);
    state=state.copyWith(franchiseFunds:_treasury.franchise.stadiumFunds,lastMatchRevenue:revenue,lastAction:'Home match earned ₹$revenue in ticket revenue.');
  }
}
final stadiumProvider = StateNotifierProvider<StadiumNotifier, StadiumState>((ref) => StadiumNotifier());
