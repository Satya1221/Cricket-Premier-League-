import 'package:hive_flutter/hive_flutter.dart';
import '../models/franchise_model.dart';
import '../models/transaction_model.dart';

/// Operating treasury is denominated in INR. The IPL auction purse remains
/// a separate league-controlled salary cap and must never be topped up by revenue.
class TreasuryService {
 const TreasuryService();
 static const int stadiumExpansionCostRupees=6000000;
 static const int academyUpgradeMinRupees=2500000;
 static const int academyUpgradeMaxRupees=5000000;
 Box<FranchiseModel> get _franchises=>Hive.box<FranchiseModel>('franchises');
 Box<dynamic> get _ledger=>Hive.box<dynamic>('history_records');
 FranchiseModel get franchise=>_franchises.get('cpl')??const FranchiseModel(id:'cpl');
 double get balanceRupees=>franchise.stadiumFunds.toDouble();
 List<TransactionModel> get transactions {
  final raw=_ledger.get('treasury-ledger',defaultValue:const <dynamic>[]) as List;
  return raw.whereType<Map>().map((e)=>TransactionModel.fromJson(e.cast<String,Object?>())).toList().reversed.toList();
 }
 Future<void> _record({required String description,required double amount,required bool income,required String category,required double newBalance}) async {
  final list=(_ledger.get('treasury-ledger',defaultValue:const <dynamic>[]) as List).toList();
  list.add(TransactionModel(description:description,amount:amount,date:DateTime.now(),isIncome:income,balanceAfter:newBalance,category:category).toJson());
  await _ledger.put('treasury-ledger',list);
 }
 Future<bool> spend({required int rupees,required String description,required String category}) async {
  if(rupees<=0||rupees>franchise.stadiumFunds)return false;
  final updated=franchise.copyWith(stadiumFunds:franchise.stadiumFunds-rupees);
  await _franchises.put(updated.id,updated);
  await _record(description:description,amount:rupees.toDouble(),income:false,category:category,newBalance:updated.stadiumFunds.toDouble());
  return true;
 }
 Future<bool> expandStadium({required int newCapacity,required int addedSeats}) async {
  if(newCapacity<=0||addedSeats<=0)return false;
  final current=franchise;
  final cost=stadiumExpansionCostRupees;
  if(current.stadiumFunds<cost)return false;
  await _franchises.put(current.id,current.copyWith(stadiumFunds:current.stadiumFunds-cost,stadiumCapacity:newCapacity));
  await _record(description:'Stadium expansion (+$addedSeats seats)',amount:cost.toDouble(),income:false,category:'Stadium',newBalance:(current.stadiumFunds-cost).toDouble());
  return true;
 }
 Future<bool> upgradeAcademy({required int level,required int costRupees}) async {
  if(costRupees<academyUpgradeMinRupees||costRupees>academyUpgradeMaxRupees||costRupees>franchise.stadiumFunds)return false;
  final current=franchise;
  final updated=current.copyWith(stadiumFunds:current.stadiumFunds-costRupees,youthAcademyLevel:level>current.youthAcademyLevel?level:current.youthAcademyLevel);
  await _franchises.put(updated.id,updated);
  await _record(description:'Youth academy upgrade to level $level',amount:costRupees.toDouble(),income:false,category:'Academy',newBalance:updated.stadiumFunds.toDouble());
  return true;
 }
 Future<int> recordTicketRevenue({required int capacity,required int ticketPriceRupees}) async {
  if(capacity<=0||ticketPriceRupees<0)return 0;
  final revenue=capacity*ticketPriceRupees;
  final current=franchise;
  final updated=current.copyWith(stadiumFunds:current.stadiumFunds+revenue);
  await _franchises.put(current.id,updated);
  await _record(description:'Home match ticket revenue',amount:revenue.toDouble(),income:true,category:'Matchday',newBalance:updated.stadiumFunds.toDouble());
  return revenue;
 }
}
