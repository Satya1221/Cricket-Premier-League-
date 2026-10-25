class MatchResultData {
  const MatchResultData({required this.homeRuns, required this.homeWickets, required this.homeBalls, required this.awayRuns, required this.awayWickets, required this.awayBalls});
  final int homeRuns, homeWickets, homeBalls, awayRuns, awayWickets, awayBalls;
  Map<String, Object?> toJson() => {'homeRuns':homeRuns,'homeWickets':homeWickets,'homeBalls':homeBalls,'awayRuns':awayRuns,'awayWickets':awayWickets,'awayBalls':awayBalls};
  factory MatchResultData.fromJson(Map<String, Object?> json) => MatchResultData(
    homeRuns:(json['homeRuns'] as num?)?.toInt()??0, homeWickets:(json['homeWickets'] as num?)?.toInt()??0, homeBalls:(json['homeBalls'] as num?)?.toInt()??120,
    awayRuns:(json['awayRuns'] as num?)?.toInt()??0, awayWickets:(json['awayWickets'] as num?)?.toInt()??0, awayBalls:(json['awayBalls'] as num?)?.toInt()??120);
}
class FixtureModel {
  const FixtureModel({required this.matchId,required this.homeTeamId,required this.awayTeamId,required this.matchWeek,this.isCompleted=false,this.result});
  final String matchId,homeTeamId,awayTeamId;
  final int matchWeek;
  final bool isCompleted;
  final MatchResultData? result;
  FixtureModel copyWith({bool? isCompleted,MatchResultData? result})=>FixtureModel(matchId:matchId,homeTeamId:homeTeamId,awayTeamId:awayTeamId,matchWeek:matchWeek,isCompleted:isCompleted??this.isCompleted,result:result??this.result);
  Map<String,Object?> toJson()=>{'matchId':matchId,'homeTeamId':homeTeamId,'awayTeamId':awayTeamId,'matchWeek':matchWeek,'isCompleted':isCompleted,'result':result?.toJson()};
  factory FixtureModel.fromJson(Map<String,Object?> j)=>FixtureModel(matchId:j['matchId']! as String,homeTeamId:j['homeTeamId']! as String,awayTeamId:j['awayTeamId']! as String,matchWeek:(j['matchWeek'] as num?)?.toInt()??1,isCompleted:j['isCompleted'] as bool???false,result:j['result'] is Map?MatchResultData.fromJson(Map<String,Object?>.from(j['result']! as Map)):null);
}
