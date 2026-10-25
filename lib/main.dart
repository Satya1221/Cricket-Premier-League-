import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() => runApp(const ProviderScope(child: CricketPremierLeagueApp()));

class CricketPremierLeagueApp extends StatelessWidget {
  const CricketPremierLeagueApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Cricket Premier League',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF080D12),
      colorScheme: const ColorScheme.dark(primary: Color(0xFFE7BD68), secondary: Color(0xFF49D6A1), surface: Color(0xFF111A22))),
    home: const AuctionHome(),
  );
}

class _Player {
  const _Player(this.name, this.nation, this.role, this.rating, this.potential, this.basePrice, {this.overseas = false, this.age = 24});
  final String name, nation, role;
  final int rating, potential, age;
  final double basePrice;
  final bool overseas;
}
class _Team {
  _Team(this.code, this.name);
  final String code, name;
  double purse = 120;
  final List<_Player> squad = [];
}

class AuctionHome extends StatefulWidget {
  const AuctionHome({super.key});
  @override
  State<AuctionHome> createState() => _AuctionHomeState();
}
class _AuctionHomeState extends State<AuctionHome> {
  final teams = [_Team('CPL','Coastal Premier Lions'),_Team('ROY','Royal Strikers'),_Team('TIT','Capital Titans'),_Team('FAL','Frontier Falcons')];
  final players = const [
    _Player('Aarav Sen','INDIA','BATTER',88,94,2,age:23),
    _Player('Zain Mercer','SOUTH AFRICA','ALL-ROUNDER',91,93,2,overseas:true,age:27),
    _Player('Dev Malhotra','INDIA','BOWLER',86,95,1.5,age:21),
    _Player('Kiran Das','INDIA','WICKETKEEPER',84,92,1,age:22),
  ];
  int lot = 0;
  int? leader;
  double bid = 0;
  bool closed = false;
  final history = <String>[];
  _Player? get player => lot < players.length ? players[lot] : null;
  double increment(double value) => value < 1 ? .05 : value < 5 ? .10 : value < 10 ? .20 : value < 20 ? .25 : .50;
  void toast(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  void placeBid(int index) {
    final p = player; if (p == null || closed) return;
    final t = teams[index]; final next = bid == 0 ? p.basePrice : bid + increment(bid);
    if (t.purse < next) return toast('Insufficient purse for ${t.code}.');
    if (t.squad.length >= 25) return toast('Squad limit reached.');
    if (p.overseas && t.squad.where((e) => e.overseas).length >= 8) return toast('Overseas limit reached.');
    setState(() { bid = next; leader = index; history.insert(0,'${t.code} bids ₹${next.toStringAsFixed(2)} Cr'); });
  }
  void closeLot() {
    final p = player; if (p == null || closed) return;
    setState(() {
      closed = true;
      if (leader != null) {
        final t = teams[leader!]; t.purse -= bid;
        t.squad.add(_Player(p.name,p.nation,p.role,p.rating,p.potential,bid,overseas:p.overseas,age:p.age));
        history.insert(0,'${p.name} sold to ${t.code} for ₹${bid.toStringAsFixed(2)} Cr');
      } else { history.insert(0,'${p.name} goes unsold'); }
    });
  }
  void nextLot() { if (!closed) return; setState(() { lot++; leader=null; bid=0; closed=false; history.clear(); }); }
  void reset() { setState(() { for(final t in teams){t.purse=120;t.squad.clear();} lot=0;leader=null;bid=0;closed=false;history.clear(); }); }
  @override
  Widget build(BuildContext context) {
    final p = player; final remaining = teams.fold<double>(0,(s,t)=>s+t.purse);
    return Scaffold(appBar: AppBar(title: const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('CRICKET PREMIER LEAGUE',style:TextStyle(fontSize:11,letterSpacing:1.8,color:Color(0xFFE7BD68),fontWeight:FontWeight.w900)),Text('LIVE AUCTION',style:TextStyle(fontSize:21,fontWeight:FontWeight.w900))]),actions:[IconButton(onPressed:reset,icon:const Icon(Icons.restart_alt),tooltip:'Reset demo')]),
      body: SafeArea(child: ListView(padding:const EdgeInsets.fromLTRB(16,6,16,28),children:[
        Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(borderRadius:BorderRadius.circular(22),gradient:const LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[Color(0xFF243A3B),Color(0xFF13242C),Color(0xFF111821)]),border:Border.all(color:const Color(0x55E7BD68))),child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('THE NEXT GENERATION OF FRANCHISE CRICKET',style:TextStyle(color:Color(0xFF49D6A1),fontSize:10,letterSpacing:1,fontWeight:FontWeight.w900)),SizedBox(height:12),Text('Build a dynasty.',style:TextStyle(fontSize:31,height:1,fontWeight:FontWeight.w900)),SizedBox(height:8),Text('Every bid shapes your legacy.',style:TextStyle(color:Color(0xFFB8C4CA))),SizedBox(height:14),Text('✦ LIVE BIDDING      ◈ SMART RIVALS',style:TextStyle(color:Color(0xFFE7BD68),fontSize:10,fontWeight:FontWeight.w800))]),),
        const SizedBox(height:16),Row(children:[Expanded(child:metric('FRANCHISES','4')),const SizedBox(width:8),Expanded(child:metric('PURSE LEFT','₹${remaining.toStringAsFixed(1)} Cr')),const SizedBox(width:8),Expanded(child:metric('TOTAL BUDGET','₹480 Cr'))]),const SizedBox(height:18),
        if(p==null) const Panel(child:Column(children:[Icon(Icons.emoji_events,size:54,color:Color(0xFFE7BD68)),SizedBox(height:10),Text('AUCTION COMPLETE',style:TextStyle(fontSize:22,fontWeight:FontWeight.w900)),Text('Your dynasty starts with the squad you built.',textAlign:TextAlign.center,style:TextStyle(color:Color(0xFF91A2AE))]))),
        if(p!=null) ...[
          Panel(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[const Text('PLAYER ON THE BLOCK',style:TextStyle(color:Color(0xFF91A2AE),fontSize:10,letterSpacing:1,fontWeight:FontWeight.w800)),pill(p.role)]),const SizedBox(height:18),Row(children:[Container(width:72,height:82,decoration:BoxDecoration(color:const Color(0xFF182630),borderRadius:BorderRadius.circular(14)),child:const Icon(Icons.person,size:54,color:Color(0xFFE7BD68))),const SizedBox(width:14),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(p.name,style:const TextStyle(fontSize:23,fontWeight:FontWeight.w900)),Text('${p.nation} • Age ${p.age}${p.overseas?' • OVERSEAS':''}',style:const TextStyle(color:Color(0xFF91A2AE),fontSize:11)),const SizedBox(height:10),Text('OVR ${p.rating}     POT ${p.potential}',style:const TextStyle(color:Color(0xFF49D6A1),fontWeight:FontWeight.w800))]))]),const Divider(height:28,color:Color(0xFF263640)),Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[price('BASE PRICE','₹${p.basePrice.toStringAsFixed(2)} Cr'),price('CURRENT BID',bid==0?'—':'₹${bid.toStringAsFixed(2)} Cr'),price('EST. VALUE','₹${(p.basePrice*(1+p.rating/40)).toStringAsFixed(2)} Cr')]),const SizedBox(height:12),Text(closed?(leader==null?'LOT UNSOLD':'LOT SOLD'):(bid>0?'BIDDING WAR IN PROGRESS':'SCOUTING DOSSIER READY'),style:const TextStyle(color:Color(0xFF49D6A1),fontSize:10,letterSpacing:1,fontWeight:FontWeight.w900))])),
          const SizedBox(height:14),Panel(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('FRANCHISE WAR ROOM',style:TextStyle(fontSize:13,fontWeight:FontWeight.w900,letterSpacing:.7)),const SizedBox(height:4),const Text('Select a franchise to place its next bid.',style:TextStyle(color:Color(0xFF91A2AE),fontSize:11)),const SizedBox(height:12),for(var i=0;i<teams.length;i++)Padding(padding:const EdgeInsets.only(bottom:8),child:TeamRow(team:teams[i],leading:leader==i,disabled:closed,onTap:()=>placeBid(i)))])),
          const SizedBox(height:14),Panel(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('AUCTION FEED',style:TextStyle(fontSize:13,fontWeight:FontWeight.w900,letterSpacing:.7)),const SizedBox(height:12),if(history.isEmpty)const Text('Bids and decisions will appear here.',style:TextStyle(color:Color(0xFF91A2AE),fontSize:12)),for(final entry in history.take(6))Padding(padding:const EdgeInsets.only(bottom:9),child:Text('◉  $entry',style:const TextStyle(fontSize:12)))])),
          const SizedBox(height:12),Row(children:[Expanded(child:OutlinedButton.icon(onPressed:closed?null:closeLot,icon:const Icon(Icons.gavel),label:Text(leader==null?'CLOSE AS UNSOLD':'HAMMER • CONFIRM'),style:OutlinedButton.styleFrom(foregroundColor:const Color(0xFFE7BD68),side:const BorderSide(color:Color(0xFFE7BD68)),minimumSize:const Size(48,52)))),const SizedBox(width:8),Expanded(child:ElevatedButton.icon(onPressed:closed?nextLot:null,icon:const Icon(Icons.skip_next),label:const Text('NEXT PLAYER')))]),
        ],const SizedBox(height:18),const Wrap(spacing:8,runSpacing:8,children:[Pill('◈ PLAYER INTELLIGENCE'),Pill('↗ DYNAMIC VALUE'),Pill('♙ SQUAD BUILDING'),Pill('✦ MATCH ENGINE NEXT')])])));
  }
  Widget metric(String label,String value)=>Container(padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:const Color(0xFF111A22),borderRadius:BorderRadius.circular(14),border:Border.all(color:const Color(0xFF263640))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Icon(Icons.insights,color:Color(0xFFE7BD68),size:16),const SizedBox(height:9),Text(value,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:14,fontWeight:FontWeight.w900)),const SizedBox(height:4),Text(label,style:const TextStyle(color:Color(0xFF91A2AE),fontSize:9,fontWeight:FontWeight.w800))]));
  Widget pill(String text)=>Container(padding:const EdgeInsets.symmetric(horizontal:9,vertical:6),decoration:BoxDecoration(color:const Color(0x22E7BD68),borderRadius:BorderRadius.circular(8)),child:Text(text,style:const TextStyle(color:Color(0xFFE7BD68),fontSize:9,fontWeight:FontWeight.w900)));
  Widget price(String label,String value)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(label,style:const TextStyle(color:Color(0xFF91A2AE),fontSize:9,fontWeight:FontWeight.w800)),const SizedBox(height:4),Text(value,style:const TextStyle(fontSize:11,fontWeight:FontWeight.w900))]);
}

class Panel extends StatelessWidget {
  const Panel({required this.child,super.key}); final Widget child;
  @override Widget build(BuildContext context)=>Container(width:double.infinity,padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:const Color(0xFF111A22),borderRadius:BorderRadius.circular(18),border:Border.all(color:const Color(0xFF263640))),child:child);
}
class TeamRow extends StatelessWidget {
  const TeamRow({required this.team,required this.leading,required this.disabled,required this.onTap,super.key}); final _Team team; final bool leading,disabled; final VoidCallback onTap;
  @override Widget build(BuildContext context)=>InkWell(onTap:disabled?null:onTap,borderRadius:BorderRadius.circular(13),child:Container(padding:const EdgeInsets.all(11),decoration:BoxDecoration(color:leading?const Color(0x22E7BD68):const Color(0x66182630),borderRadius:BorderRadius.circular(13),border:Border.all(color:leading?const Color(0x88E7BD68):const Color(0xFF263640))),child:Row(children:[Container(width:39,height:39,alignment:Alignment.center,decoration:BoxDecoration(color:leading?const Color(0xFFE7BD68):const Color(0xFF080D12),borderRadius:BorderRadius.circular(10)),child:Text(team.code,style:TextStyle(fontSize:10,fontWeight:FontWeight.w900,color:leading?const Color(0xFF080D12):const Color(0xFFE7BD68)))),const SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(team.name,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:12,fontWeight:FontWeight.w800)),const SizedBox(height:3),Text('Purse ₹${team.purse.toStringAsFixed(2)} Cr • Squad ${team.squad.length}',style:const TextStyle(color:Color(0xFF91A2AE),fontSize:10))])),Icon(leading?Icons.local_fire_department:Icons.add_circle_outline,color:leading?const Color(0xFFE7BD68):const Color(0xFF49D6A1))])));
}
class Pill extends StatelessWidget { const Pill(this.label,{super.key}); final String label; @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:8),decoration:BoxDecoration(color:const Color(0xFF111A22),borderRadius:BorderRadius.circular(9),border:Border.all(color:const Color(0xFF263640))),child:Text(label,style:const TextStyle(fontSize:9,letterSpacing:.4,fontWeight:FontWeight.w800,color:Color(0xFF91A2AE)))); }
