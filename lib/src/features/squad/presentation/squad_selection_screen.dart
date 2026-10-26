import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/game_theme.dart';
import '../../../../state/franchise_roster_provider.dart';
import '../../auction/application/auction_controller.dart';
import '../../auction/domain/player.dart';
import '../../game/application/season_provider.dart';

class SquadSelectionScreen extends ConsumerStatefulWidget {
  const SquadSelectionScreen({super.key});
  @override
  ConsumerState<SquadSelectionScreen> createState()=>_SquadSelectionScreenState();
}
class _SquadSelectionScreenState extends ConsumerState<SquadSelectionScreen> {
  final Set<String> _selected={};
  String? _error;
  bool _synced=false;

  @override
  Widget build(BuildContext context) {
    final auction=ref.watch(auctionControllerProvider);
    final franchise=ref.watch(franchiseRosterProvider);
    final actions=ref.read(franchiseRosterProvider.notifier);
    final teamMatches=auction.teams.where((t)=>t.id=='cpl').toList();
    final squad=teamMatches.isEmpty?<AuctionPlayer>[]:teamMatches.first.squad;
    if(!_synced){
      _synced=true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if(!mounted)return;
        await actions.setActiveSquad(squad.map((p)=>p.id).toList());
        if(mounted)setState(()=>_selected.addAll(franchise.playingXI));
      });
    }
    return Scaffold(
      backgroundColor: GamePalette.ink,
      appBar: AppBar(title: const Text('SQUAD & PLAYING XI')),
      body: ListView(padding: const EdgeInsets.all(16),children:[
        Container(padding: const EdgeInsets.all(14),decoration:BoxDecoration(color:GamePalette.panel,borderRadius:BorderRadius.circular(14),border:Border.all(color:GamePalette.line)),
          child:Text('Owned players: ${squad.length} · Selected: ${_selected.length}/11\nRules: exactly 11, at least one wicketkeeper, five bowlers with bowling skill > 40, maximum four overseas players.',style:const TextStyle(color:Colors.white70,height:1.5))),
        const SizedBox(height:12),
        if(squad.isEmpty) const Text('No players owned yet. Finish auction lots before selecting your XI.',style:TextStyle(color:Colors.white60)),
        for(final player in squad)
          CheckboxListTile(
            value:_selected.contains(player.id),
            onChanged:(checked)=>setState((){
              _error=null;
              if(checked==true){if(_selected.length<11)_selected.add(player.id);else _error='Select exactly 11 players';}
              else{_selected.remove(player.id);}
            }),
            title:Text(player.name,style:const TextStyle(fontWeight:FontWeight.w800)),
            subtitle:Text('${player.roleLabel} · OVR ${player.overall} · Bowling ${player.bowling}${player.isOverseas?' · Overseas':''}',style:const TextStyle(color:Colors.white60,fontSize:12)),
            activeColor:GamePalette.gold,
            controlAffinity:ListTileControlAffinity.leading,
          ),
        if(_error!=null) Padding(padding:const EdgeInsets.symmetric(vertical:8),child:Text(_error!,style:const TextStyle(color:Colors.redAccent))),
        const SizedBox(height:12),
        FilledButton.icon(
          onPressed:()=>_saveXI(squad,actions),
          icon:const Icon(Icons.check_circle_outline),
          label:const Text('VALIDATE & SAVE PLAYING XI'),
        ),
        if(franchise.playingXI.isNotEmpty) Padding(padding:const EdgeInsets.only(top:10),child:Text('Saved XI: ${franchise.playingXI.length} players',style:const TextStyle(color:GamePalette.emerald))),
      ]),
    );
  }

  Future<void> _saveXI(List<AuctionPlayer> squad, FranchiseRosterNotifier actions) async {
    try {
      await actions.setActiveSquad(squad.map((p)=>p.id).toList());
      await actions.setPlayingXI(_selected.toList(),squad);
      await ref.read(seasonProvider.notifier).setPlayingXI('cpl', _selected.toList());
      if(!mounted)return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Playing XI validated and saved.')));
      Navigator.of(context).pop();
    } on FormatException catch(error) {
      setState(()=>_error=error.message);
    }
  }
}
