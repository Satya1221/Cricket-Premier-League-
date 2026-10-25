import 'package:hive/hive.dart';

@HiveType(typeId: 41)
class PlayerModel {
  const PlayerModel({required this.id,required this.name,required this.age,required this.role,required this.batSkill,required this.bowlSkill,required this.fielding,required this.stamina,required this.form,this.isRetired=false,this.nation='India',this.isOverseas=false,this.runs=0,this.wickets=0,this.careerRuns=0,this.careerWickets=0,this.matchesPlayed=0,this.highestScore=0,this.careerBallsFaced=0});
  @HiveField(0) final String id;
  @HiveField(1) final String name;
  @HiveField(2) final int age;
  @HiveField(3) final String role;
  @HiveField(4) final int batSkill;
  @HiveField(5) final int bowlSkill;
  @HiveField(6) final int fielding;
  @HiveField(7) final int stamina;
  @HiveField(8) final int form;
  @HiveField(9) final bool isRetired;
  @HiveField(10) final String nation;
  @HiveField(11) final bool isOverseas;
  @HiveField(12) final int runs;
  @HiveField(13) final int wickets;
  @HiveField(14) final int careerRuns;
  @HiveField(15) final int careerWickets;
  @HiveField(16) final int matchesPlayed;
  @HiveField(17) final int highestScore;
  @HiveField(18) final int careerBallsFaced;
  int get overall => ((batSkill+bowlSkill+fielding+stamina+form)/5).round();
  PlayerModel copyWith({int? age,int? batSkill,int? bowlSkill,int? fielding,int? stamina,int? form,bool? isRetired,int? runs,int? wickets,int? careerRuns,int? careerWickets,int? matchesPlayed,int? highestScore,int? careerBallsFaced})=>PlayerModel(id:id,name:name,age:age??this.age,role:role,batSkill:batSkill??this.batSkill,bowlSkill:bowlSkill??this.bowlSkill,fielding:fielding??this.fielding,stamina:stamina??this.stamina,form:form??this.form,isRetired:isRetired??this.isRetired,nation:nation,isOverseas:isOverseas,runs:runs??this.runs,wickets:wickets??this.wickets,careerRuns:careerRuns??this.careerRuns,careerWickets:careerWickets??this.careerWickets,matchesPlayed:matchesPlayed??this.matchesPlayed,highestScore:highestScore??this.highestScore,careerBallsFaced:careerBallsFaced??this.careerBallsFaced);
}
class PlayerModelAdapter extends TypeAdapter<PlayerModel>{
 @override final int typeId=41;
 @override PlayerModel read(BinaryReader r){final n=r.readByte();final f=<int,dynamic>{for(var i=0;i<n;i++)r.readByte():r.read()};return PlayerModel(id:f[0] as String,name:f[1] as String,age:f[2] as int,role:f[3] as String,batSkill:f[4] as int,bowlSkill:f[5] as int,fielding:f[6] as int,stamina:f[7] as int,form:f[8] as int,isRetired:f[9] as bool? ?? false,nation:f[10] as String? ?? 'India',isOverseas:f[11] as bool? ?? false,runs:f[12] as int? ?? 0,wickets:f[13] as int? ?? 0,careerRuns:f[14] as int? ?? 0,careerWickets:f[15] as int? ?? 0,matchesPlayed:f[16] as int? ?? 0,highestScore:f[17] as int? ?? 0,careerBallsFaced:f[18] as int? ?? 0);}
 @override void write(BinaryWriter w,PlayerModel p){w..writeByte(19)..writeByte(0)..write(p.id)..writeByte(1)..write(p.name)..writeByte(2)..write(p.age)..writeByte(3)..write(p.role)..writeByte(4)..write(p.batSkill)..writeByte(5)..write(p.bowlSkill)..writeByte(6)..write(p.fielding)..writeByte(7)..write(p.stamina)..writeByte(8)..write(p.form)..writeByte(9)..write(p.isRetired)..writeByte(10)..write(p.nation)..writeByte(11)..write(p.isOverseas)..writeByte(12)..write(p.runs)..writeByte(13)..write(p.wickets)..writeByte(14)..write(p.careerRuns)..writeByte(15)..write(p.careerWickets)..writeByte(16)..write(p.matchesPlayed)..writeByte(17)..write(p.highestScore)..writeByte(18)..write(p.careerBallsFaced);}
}
