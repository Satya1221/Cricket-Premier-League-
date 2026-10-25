enum DeliveryExtra { none, wide, noBall, legBye }

/// One ball event. runsScored is batter runs; totalRuns includes extras.
class DeliveryModel {
 const DeliveryModel({required this.ballNumber,required this.runsScored,required this.isWicket,required this.extraType,required this.strikerId,required this.nonStrikerId,required this.bowlerId,required this.totalRuns,required this.legalDelivery,this.dismissedPlayerId});
 final int ballNumber;
 final int runsScored;
 final bool isWicket;
 final String extraType;
 final String strikerId;
 final String nonStrikerId;
 final String bowlerId;
 final int totalRuns;
 final bool legalDelivery;
 final String? dismissedPlayerId;
 Map<String,Object?> toJson()=>{'ballNumber':ballNumber,'runsScored':runsScored,'isWicket':isWicket,'extraType':extraType,'strikerId':strikerId,'nonStrikerId':nonStrikerId,'bowlerId':bowlerId,'totalRuns':totalRuns,'legalDelivery':legalDelivery,'dismissedPlayerId':dismissedPlayerId};
 factory DeliveryModel.fromJson(Map<String,Object?> j)=>DeliveryModel(ballNumber:j['ballNumber'] as int? ?? 0,runsScored:j['runsScored'] as int? ?? 0,isWicket:j['isWicket'] as bool? ?? false,extraType:j['extraType'] as String? ?? 'None',strikerId:j['strikerId'] as String? ?? '',nonStrikerId:j['nonStrikerId'] as String? ?? '',bowlerId:j['bowlerId'] as String? ?? '',totalRuns:j['totalRuns'] as int? ?? 0,legalDelivery:j['legalDelivery'] as bool? ?? true,dismissedPlayerId:j['dismissedPlayerId'] as String?);
}
