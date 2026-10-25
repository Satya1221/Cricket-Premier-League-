import 'package:hive/hive.dart';

@HiveType(typeId: 42)
class FranchiseModel {
 const FranchiseModel({required this.id,this.purseCrores=120,this.stadiumFunds=12000000,this.squadIds=const [],this.stadiumCapacity=30000,this.youthCoachLevel=1,this.youthAcademyLevel=1,this.trainingFacilityLevel=1});
 @HiveField(0) final String id;
 @HiveField(1) final double purseCrores;
 @HiveField(2) final int stadiumFunds;
 @HiveField(4) final List<String> squadIds;
 @HiveField(5) final int stadiumCapacity;
 @HiveField(6) final int youthCoachLevel;
 @HiveField(7) final int youthAcademyLevel;
 @HiveField(8) final int trainingFacilityLevel;
 FranchiseModel copyWith({double? purseCrores,int? stadiumFunds,List<String>? squadIds,int? stadiumCapacity,int? youthCoachLevel,int? youthAcademyLevel,int? trainingFacilityLevel})=>FranchiseModel(id:id,purseCrores:purseCrores??this.purseCrores,stadiumFunds:stadiumFunds??this.stadiumFunds,squadIds:squadIds??this.squadIds,stadiumCapacity:stadiumCapacity??this.stadiumCapacity,youthCoachLevel:youthCoachLevel??this.youthCoachLevel,youthAcademyLevel:youthAcademyLevel??this.youthAcademyLevel,trainingFacilityLevel:trainingFacilityLevel??this.trainingFacilityLevel);
}
class FranchiseModelAdapter extends TypeAdapter<FranchiseModel>{
 @override final int typeId=42;
 @override FranchiseModel read(BinaryReader r){final n=r.readByte();final f=<int,dynamic>{for(var i=0;i<n;i++)r.readByte():r.read()};return FranchiseModel(id:f[0] as String,purseCrores:(f[1] as num?)?.toDouble()??120,stadiumFunds:f[2] as int? ??12000000,squadIds:(f[4] as List?)?.cast<String>()??const [],stadiumCapacity:f[5] as int? ??30000,youthCoachLevel:f[6] as int? ??1,youthAcademyLevel:f[7] as int? ??1,trainingFacilityLevel:f[8] as int? ??1);}
 @override void write(BinaryWriter w,FranchiseModel p){w..writeByte(8)..writeByte(0)..write(p.id)..writeByte(1)..write(p.purseCrores)..writeByte(2)..write(p.stadiumFunds)..writeByte(4)..write(p.squadIds)..writeByte(5)..write(p.stadiumCapacity)..writeByte(6)..write(p.youthCoachLevel)..writeByte(7)..write(p.youthAcademyLevel)..writeByte(8)..write(p.trainingFacilityLevel);}
}
