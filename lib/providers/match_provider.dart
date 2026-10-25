import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/delivery_model.dart';
import '../services/stats_aggregator.dart';
import '../src/features/game/application/stadium_provider.dart';

enum IplMatchStatus { inningsOne, inningsTwo, needsOpeningBatters, needsIncomingBatter, needsNewBowler, superOverRequired, completed }

class IplMatchState {
 const IplMatchState({this.innings=1,this.runs=0,this.wickets=0,this.legalBalls=0,this.targetScore=0,this.strikerId,this.nonStrikerId,this.bowlerId,this.battingTeamId='cpl',this.defendingTeamId='opponent',this.status=IplMatchStatus.inningsOne,this.deliveries=const [],this.winnerTeamId,this.isTie=false,this.message='Select the opening batters to begin.',this.pendingBowlerChange=false});
 final int innings,runs,wickets,legalBalls,targetScore;
 final String? strikerId,nonStrikerId,bowlerId,winnerTeamId;
 final String battingTeamId,defendingTeamId;
 final IplMatchStatus status;
 final List<DeliveryModel> deliveries;
 final bool isTie,pendingBowlerChange;
 final String message;
 String get overs=>'${legalBalls~/6}.${legalBalls%6}';
 IplMatchState copyWith({int? innings,int? runs,int? wickets,int? legalBalls,int? targetScore,String? strikerId,String? nonStrikerId,String? bowlerId,String? winnerTeamId,String? battingTeamId,String? defendingTeamId,IplMatchStatus? status,List<DeliveryModel>? deliveries,bool? isTie,String? message,bool? pendingBowlerChange,bool clearStriker=false,bool clearNonStriker=false,bool clearBowler=false,bool clearWinner=false})=>IplMatchState(innings:innings??this.innings,runs:runs??this.runs,wickets:wickets??this.wickets,legalBalls:legalBalls??this.legalBalls,targetScore:targetScore??this.targetScore,strikerId:clearStriker?null:(strikerId??this.strikerId),nonStrikerId:clearNonStriker?null:(nonStrikerId??this.nonStrikerId),bowlerId:clearBowler?null:(bowlerId??this.bowlerId),winnerTeamId:clearWinner?null:(winnerTeamId??this.winnerTeamId),battingTeamId:battingTeamId??this.battingTeamId,defendingTeamId:defendingTeamId??this.defendingTeamId,status:status??this.status,deliveries:deliveries??this.deliveries,isTie:isTie??this.isTie,message:message??this.message,pendingBowlerChange:pendingBowlerChange??this.pendingBowlerChange);
}

final matchNotifierProvider=StateNotifierProvider<MatchNotifier,IplMatchState>((ref)=>MatchNotifier(onHomeMatchEnd:()=>ref.read(stadiumProvider.notifier).recordHomeMatch()));

class MatchNotifier extends StateNotifier<IplMatchState>{
 MatchNotifier({Future<void> Function()? onHomeMatchEnd}):_onHomeMatchEnd=onHomeMatchEnd,super(const IplMatchState());
 final Future<void> Function()? _onHomeMatchEnd;
 final String _matchId='ipl-match-${DateTime.now().microsecondsSinceEpoch}';
 bool _statsSaved=false;
 void endMatch({required String winnerTeamId}) {
  if(state.status==IplMatchStatus.completed)return;
  state=state.copyWith(status:IplMatchStatus.completed,winnerTeamId:winnerTeamId,isTie:false,message:'$winnerTeamId win.');
  _saveCareerStats();
 }
 void _saveCareerStats(){if(_statsSaved)return;_statsSaved=true;unawaited(const StatsAggregator().aggregateMatch(matchId:_matchId,deliveries:state.deliveries));unawaited(_onHomeMatchEnd?.call()??Future<void>.value());}
 static const int maxLegalBalls=120;
 void setTeams({required String battingTeamId,required String defendingTeamId})=>state=state.copyWith(battingTeamId:battingTeamId,defendingTeamId:defendingTeamId);
 void selectOpeningBatters({required String strikerId,required String nonStrikerId}) {
  if(strikerId==nonStrikerId)throw ArgumentError('Two different batters are required.');
  if(state.status!=IplMatchStatus.needsOpeningBatters && state.legalBalls>0)throw StateError('Opening batters can only be selected at an innings start.');
  state=state.copyWith(strikerId:strikerId,nonStrikerId:nonStrikerId,status:state.innings==1?IplMatchStatus.inningsOne:IplMatchStatus.inningsTwo,message:'Batters ready.',clearBowler:true,pendingBowlerChange:true);
 }
 void selectNewBowler(String bowlerId){
  if(bowlerId.trim().isEmpty)throw ArgumentError('Select a bowler.');
  if(!state.pendingBowlerChange && state.bowlerId!=null)throw StateError('A new bowler is only needed at the start of an over.');
  state=state.copyWith(bowlerId:bowlerId,pendingBowlerChange:false,message:'Bowler ready.');
 }
 void swapBatters(){state=state.copyWith(strikerId:state.nonStrikerId,nonStrikerId:state.strikerId);}
 void resolveDelivery(int runs,bool isWicket,String extra,{String? dismissedPlayerId}) {
  if(runs<0)throw ArgumentError.value(runs,'runs','Runs cannot be negative.');
  if(state.status==IplMatchStatus.completed||state.status==IplMatchStatus.superOverRequired||(state.status==IplMatchStatus.needsOpeningBatters||state.status==IplMatchStatus.needsIncomingBatter))throw StateError('The innings is not ready for a delivery.');
  if(state.strikerId==null||state.nonStrikerId==null||state.bowlerId==null)throw StateError('Select two batters and a bowler before the next delivery.');
  if(state.pendingBowlerChange)throw StateError('Select a new bowler before continuing.');
  final normalized=extra.trim().toLowerCase();
  if(!const ['none','wide','noball','no ball','legbye','leg bye'].contains(normalized))throw ArgumentError.value(extra,'extra','Unsupported extra type.');
  final isWide=normalized=='wide';
  final isNoBall=normalized=='noball'||normalized=='no ball';
  final isLegBye=normalized=='legbye'||normalized=='leg bye';
  final legal=!isWide&&!isNoBall;
  final batterRuns=(isWide||isLegBye)?0:runs;
  final extraRuns=(isWide||isNoBall)?1:0;
  // On wides, runs represents completed running wides/byes in addition to the mandatory wide.
  final totalRuns=extraRuns+(isWide||isLegBye?runs:batterRuns);
  final extraName=isWide?'Wide':isNoBall?'NoBall':isLegBye?'LegBye':'None';
  final striker=state.strikerId!,nonStriker=state.nonStrikerId!;
  final ball=DeliveryModel(ballNumber:state.deliveries.length+1,runsScored:batterRuns,isWicket:isWicket,extraType:extraName,strikerId:striker,nonStrikerId:nonStriker,bowlerId:state.bowlerId!,totalRuns:totalRuns,legalDelivery:legal,dismissedPlayerId:dismissedPlayerId??(isWicket?striker:null));
  final nextBalls=state.legalBalls+(legal?1:0);
  var next=state.copyWith(runs:state.runs+totalRuns,wickets:state.wickets+(isWicket?1:0),legalBalls:nextBalls,deliveries:[...state.deliveries,ball],message:isWicket?'Wicket!': '${totalRuns} run(s).');
  // Record who was dismissed before applying end-of-delivery strike rotation.
  final dismissed=ball.dismissedPlayerId;
  if(totalRuns.isOdd)next=next.copyWith(strikerId:next.nonStrikerId,nonStrikerId:next.strikerId);
  if(isWicket){
   if(dismissed==next.strikerId)next=next.copyWith(clearStriker:true,status:IplMatchStatus.needsIncomingBatter,message:'Wicket. Select the incoming batter.');
   else if(dismissed==next.nonStrikerId)next=next.copyWith(clearNonStriker:true,status:IplMatchStatus.needsIncomingBatter,message:'Wicket. Select the incoming batter.');
  }
  state=next;
  evaluateInningsState();
  if(state.status!=IplMatchStatus.completed&&state.status!=IplMatchStatus.superOverRequired&&state.status!=IplMatchStatus.needsOpeningBatters&&state.status!=IplMatchStatus.needsIncomingBatter&&legal&&state.legalBalls>0&&state.legalBalls%6==0){endOfOver();}
 }
 void endOfOver(){
  if(state.legalBalls==0||state.legalBalls%6!=0)throw StateError('An over ends after six legal deliveries.');
  swapBatters();
  state=state.copyWith(pendingBowlerChange:true,status:state.innings==1?IplMatchStatus.inningsOne:IplMatchStatus.inningsTwo,message:'Over complete. Select a new bowler.');
 }
 void evaluateInningsState(){
  if(state.status==IplMatchStatus.completed||state.status==IplMatchStatus.superOverRequired)return;
  if(state.innings==2&&state.runs>=state.targetScore){endMatch(winnerTeamId:state.battingTeamId);return;}
  final inningsOver=state.wickets>=10||state.legalBalls>=maxLegalBalls;
  if(!inningsOver)return;
  if(state.innings==1){
   state=state.copyWith(innings:2,targetScore:state.runs+1,runs:0,wickets:0,legalBalls:0,deliveries:state.deliveries,clearStriker:true,clearNonStriker:true,clearBowler:true,status:IplMatchStatus.needsOpeningBatters,battingTeamId:state.defendingTeamId,defendingTeamId:state.battingTeamId,pendingBowlerChange:true,message:'First innings complete. Target: ${state.runs+1}. Select opening batters.');
   return;
  }
  if(state.runs==state.targetScore-1){state=state.copyWith(status:IplMatchStatus.superOverRequired,isTie:true,message:'Match tied. IPL rules require a Super Over.');return;}
  endMatch(winnerTeamId:state.defendingTeamId);
 }
 void endSuperOver({required String winnerTeamId}){if(state.status!=IplMatchStatus.superOverRequired)throw StateError('A Super Over is not pending.');endMatch(winnerTeamId:winnerTeamId);}
 void reset()=>state=const IplMatchState();
}
