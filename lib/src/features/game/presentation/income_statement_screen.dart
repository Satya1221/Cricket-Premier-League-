import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/game_theme.dart';
import '../../../../services/treasury_service.dart';
import '../../../../models/transaction_model.dart';

final treasuryRefreshProvider=StateProvider<int>((ref)=>0);

class IncomeStatementScreen extends ConsumerWidget{
 const IncomeStatementScreen({super.key});
 @override Widget build(BuildContext context,WidgetRef ref){
  ref.watch(treasuryRefreshProvider);
  final treasury=const TreasuryService();
  final rows=treasury.transactions;
  final income=rows.where((e)=>e.isIncome).fold<double>(0,(s,e)=>s+e.amount);
  final expense=rows.where((e)=>!e.isIncome).fold<double>(0,(s,e)=>s+e.amount);
  return Scaffold(appBar:AppBar(title:const Text('FRANCHISE INCOME STATEMENT')),body:ListView(padding:const EdgeInsets.all(16),children:[
   Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(color:GamePalette.panel,borderRadius:BorderRadius.circular(18),border:Border.all(color:GamePalette.line)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    const Text('OPERATING TREASURY',style:TextStyle(color:GamePalette.gold,fontWeight:FontWeight.w900,letterSpacing:1.1)),
    const SizedBox(height:8),Text('₹${treasury.balanceRupees.toStringAsFixed(0)}',style:const TextStyle(fontSize:30,fontWeight:FontWeight.w900)),
    const SizedBox(height:14),Row(children:[Expanded(child:_metric('TOTAL INCOME',income,true)),const SizedBox(width:8),Expanded(child:_metric('TOTAL EXPENSES',expense,false))]),
    const SizedBox(height:8),const Text('IPL player-auction purse remains a separate league-capped budget; operating income cannot increase the salary cap.',style:TextStyle(color:Colors.white60,fontSize:11,height:1.4)),
   ])),
   const SizedBox(height:18),const Text('TRANSACTION LEDGER',style:TextStyle(color:GamePalette.gold,fontWeight:FontWeight.w900,letterSpacing:1.1)),
   if(rows.isEmpty)const Padding(padding:EdgeInsets.all(24),child:Text('No transactions yet. Home-match revenue and facility upgrades will appear here.')),
   for(final t in rows)Card(color:GamePalette.panel,child:ListTile(leading:Icon(t.isIncome?Icons.south_west_rounded:Icons.north_east_rounded,color:t.isIncome?GamePalette.emerald:GamePalette.danger),title:Text(t.description),subtitle:Text('${t.category} · ${t.date.toLocal()}'),trailing:Text('${t.isIncome?'+':'−'}₹${t.amount.toStringAsFixed(0)}',style:TextStyle(fontWeight:FontWeight.w800,color:t.isIncome?GamePalette.emerald:GamePalette.danger)))),
  ]));
 }
 static Widget _metric(String label,double value,bool positive)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(label,style:const TextStyle(color:Colors.white54,fontSize:10,fontWeight:FontWeight.w800)),const SizedBox(height:4),Text('₹${value.toStringAsFixed(0)}',style:TextStyle(fontWeight:FontWeight.w900,color:positive?GamePalette.emerald:GamePalette.danger))]);
}
