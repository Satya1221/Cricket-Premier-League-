import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/game_theme.dart';
import '../../../providers/match_provider.dart';
import '../../../state/franchise_roster_provider.dart';
import '../../auction/application/auction_controller.dart';

class IplMatchControllerScreen extends ConsumerStatefulWidget{
 const IplMatchControllerScreen({super.key});
 @override ConsumerState<IplMatchControllerScreen> createState()=>_IplMatchControllerScreenState();
}
class _IplMatchControllerScreenState extends ConsumerState<IplMatchControllerScreen>{
 String? _striker,_nonStriker,_bowler,_incoming;
 String _extra='None',_superOverWinner='cpl';
 final List<String> _extras=const ['None','Wide','NoBall','LegBye'];
 @override Widget build(BuildContext context){
  final match=ref.watch(matchNotifierProvider);
  final actions=ref.read(matchNotifierProvider.notifier);
  final roster=ref.watch(franchiseRosterProvider);
  final auction=ref.watch(auctionControllerProvider);
  final battingTeam=auction.teams.where((t)=>t.id==match.battingTeamId).toList();
  final bowlingTeam=auction.teams.where((t)=>t.id==match.defendingTeamId).toList();
  final battingIds=match.battingTeamId=='cpl'?roster.playingXI:(battingTeam.isEmpty?const <String>[]:battingTeam.first.squad.take(11).map((p)=>p.id).toList());
  final bowlingIds=match.defendingTeamId=='cpl'?roster.playingXI:(bowlingTeam.isEmpty?const <String>[]:bowlingTeam.first.squad.map((p)=>p.id).toList());
  final names={for(final t in auction.teams)for(final p in t.squad)p.id:p.name};
  String label(String id)=>names[id]??id;
  final ready=battingIds.length>=11&&bowlingIds.isNotEmpty;
  final available=battingIds.where((id)=>id!=match.strikerId&&id!=match.nonStrikerId).toList();
  return Scaffold(
   appBar:AppBar(title:const Text('IPL BALL-BY-BALL')),
   body:ListView(padding:const EdgeInsets.all(16),children:[
    Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:GamePalette.panel,borderRadius:BorderRadius.circular(18),border:Border.all(color:GamePalette.line)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
     Text('INNINGS ${match.innings} · ${match.status.name.replaceAll(RegExp(r'([A-Z])'),r' $1').toUpperCase()}',style:const TextStyle(color:GamePalette.gold,fontWeight:FontWeight.w900,letterSpacing:1)),
     const SizedBox(height:8),Text('${match.runs}/${match.wickets}',style:const TextStyle(fontSize:38,fontWeight:FontWeight.w900)),
     Text('Overs ${match.overs} / 20  ·  ${match.legalBalls} legal balls',style:const TextStyle(color:Colors.white70)),
     if(match.innings==2)Text('Target ${match.targetScore} · Need ${(match.targetScore-match.runs).clamp(0,999)} runs',style:const TextStyle(color:GamePalette.emerald,fontWeight:FontWeight.w800)),
     const SizedBox(height:8),Text(match.message,style:const TextStyle(color:Colors.white70)),
     if(match.status==IplMatchStatus.completed)Text('RESULT: ${match.winnerTeamId} win',style:const TextStyle(color:GamePalette.emerald,fontWeight:FontWeight.w900)),
    ])),
    const SizedBox(height:14),
    if(!ready)const Card(child:Padding(padding:EdgeInsets.all(16),child:Text('Select and save a valid IPL Playing XI of 11 players first. The match controller uses that saved XI.'))),
    if(ready&&match.status!=IplMatchStatus.completed&&match.status!=IplMatchStatus.superOverRequired)...[
     if(match.status==IplMatchStatus.needsOpeningBatters||match.strikerId==null&&match.nonStrikerId==null)...[
      _playerPicker('Opening striker',battingIds,names,_striker,(v)=>setState(()=>_striker=v)),
      _playerPicker('Opening non-striker',battingIds.where((id)=>id!=_striker).toList(),names,_nonStriker,(v)=>setState(()=>_nonStriker=v)),
      FilledButton(onPressed:_striker!=null&&_nonStriker!=null&&_striker!=_nonStriker?(){
       try{actions.selectOpeningBatters(strikerId:_striker!,nonStrikerId:_nonStriker!);setState(()=>_incoming=null);}catch(e){_error(e.toString());}
      }:null,child:const Text('CONFIRM BATTERS')),
     ],
     if(match.status==IplMatchStatus.needsIncomingBatter)...[
      _playerPicker('Incoming batter',available,names,_incoming,(v)=>setState(()=>_incoming=v)),
      FilledButton(onPressed:_incoming==null?null:(){try{actions.selectIncomingBatter(_incoming!);setState(()=>_incoming=null);}catch(e){_error(e.toString());}},child:const Text('SEND INCOMING BATTER')),
     ],
     if(match.pendingBowlerChange)...[
      _playerPicker('Select bowler (max 4 overs)',bowlingIds.where((id)=>id!=match.bowlerId).toList(),names,_bowler,(v)=>setState(()=>_bowler=v)),
      FilledButton(onPressed:_bowler==null?null:(){try{actions.selectNewBowler(_bowler!);setState(()=>_bowler=null);}catch(e){_error(e.toString());}},child:const Text('CONFIRM BOWLER')),
     ],
     if(match.strikerId!=null&&match.nonStrikerId!=null&&match.bowlerId!=null&&!match.pendingBowlerChange&&match.status!=IplMatchStatus.needsIncomingBatter)...[
      Text('Batting: ${label(match.strikerId!)}*  /  ${label(match.nonStrikerId!)}',style:const TextStyle(fontWeight:FontWeight.w800)),
      Text('Bowling: ${label(match.bowlerId!)}',style:const TextStyle(color:Colors.white70)),
      const SizedBox(height:8),
      DropdownButtonFormField<String>(value:_extra,decoration:const InputDecoration(labelText:'Extra type'),items:_extras.map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(),onChanged:(v)=>setState(()=>_extra=v??'None')),
      const SizedBox(height:10),const Text('RECORD DELIVERY',style:TextStyle(color:GamePalette.gold,fontWeight:FontWeight.w900)),
      Wrap(spacing:8,runSpacing:8,children:[
       for(final n in [0,1,2,3,4,6])OutlinedButton(onPressed:()=>_deliver(actions,n,false),child:Text('$n run${n==1?'':'s'}')),
       FilledButton(onPressed:(_extra=='Wide'||_extra=='NoBall')?null:()=>_deliver(actions,0,true),child:const Text('WICKET')),
      ]),
      const SizedBox(height:8),const Text('IPL T20: 20 overs per innings, 6 legal balls per over, maximum 4 overs per bowler. Wides/no-balls do not count as legal balls.',style:TextStyle(color:Colors.white54,fontSize:11,height:1.4)),
     ],
    ],
    if(match.status==IplMatchStatus.superOverRequired)...[
     const Text('Scores are tied. IPL rules require a Super Over.',style:TextStyle(color:GamePalette.gold,fontWeight:FontWeight.w900)),
     DropdownButtonFormField<String>(value:_superOverWinner,decoration:const InputDecoration(labelText:'Super Over winner'),items:[DropdownMenuItem(value:match.battingTeamId,child:Text(match.battingTeamId)),DropdownMenuItem(value:match.defendingTeamId,child:Text(match.defendingTeamId))].toList(),onChanged:(v)=>setState(()=>_superOverWinner=v??match.battingTeamId)),
     FilledButton(onPressed:()=>actions.endSuperOver(winnerTeamId:_superOverWinner),child:const Text('RECORD SUPER OVER RESULT')),
    ],
    const SizedBox(height:18),const Text('BALL-BY-BALL LOG',style:TextStyle(color:GamePalette.gold,fontWeight:FontWeight.w900,letterSpacing:1)),
    for(final d in match.deliveries.reversed.take(18))ListTile(dense:true,leading:Text('${d.innings}·${d.ballNumber}',style:const TextStyle(color:Colors.white54)),title:Text('${label(d.strikerId)} · ${d.isWicket?'WICKET':d.totalRuns==0?'Dot':'+${d.totalRuns} runs'}'),subtitle:Text('Bowler: ${label(d.bowlerId)} · ${d.extraType}')),
   ]),
  );
 }
 Widget _playerPicker(String title,List<String> ids,Map<String,String> names,String? value,ValueChanged<String?> onChanged)=>Padding(padding:const EdgeInsets.only(bottom:10),child:DropdownButtonFormField<String>(value:ids.contains(value)?value:null,decoration:InputDecoration(labelText:title),items:ids.map((id)=>DropdownMenuItem(value:id,child:Text(names[id]??id,overflow:TextOverflow.ellipsis))).toList(),onChanged:ids.isEmpty?null:onChanged));
 void _deliver(MatchNotifier actions,int runs,bool wicket){try{actions.resolveDelivery(runs,wicket,_extra);setState(()=>_extra='None');}catch(e){_error(e.toString());}}
 void _error(String message)=>ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(message)));
}
