import 'package:hive/hive.dart';

@HiveType(typeId: 43)
class GameStateModel {
 const GameStateModel({this.currentSeason=1,this.currentMonth=1,this.gamePhase='PreSeason'});
 @HiveField(0) final int currentSeason;
 @HiveField(1) final int currentMonth;
 @HiveField(2) final String gamePhase;
 GameStateModel copyWith({int? currentSeason,int? currentMonth,String? gamePhase})=>GameStateModel(currentSeason:currentSeason??this.currentSeason,currentMonth:currentMonth??this.currentMonth,gamePhase:gamePhase??this.gamePhase);
}
class GameStateModelAdapter extends TypeAdapter<GameStateModel>{
 @override final int typeId=43;
 @override GameStateModel read(BinaryReader r){final n=r.readByte();final f=<int,dynamic>{for(var i=0;i<n;i++)r.readByte():r.read()};return GameStateModel(currentSeason:f[0] as int? ??1,currentMonth:f[1] as int? ??1,gamePhase:f[2] as String? ??'PreSeason');}
 @override void write(BinaryWriter w,GameStateModel s){w..writeByte(3)..writeByte(0)..write(s.currentSeason)..writeByte(1)..write(s.currentMonth)..writeByte(2)..write(s.gamePhase);}
}
