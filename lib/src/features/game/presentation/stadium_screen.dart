import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/game_theme.dart';
import '../../match/domain/stadium_pitch_engine.dart';
import '../application/stadium_provider.dart';
import 'income_statement_screen.dart';
import '../../../../services/treasury_service.dart';

class StadiumScreen extends ConsumerWidget {
  const StadiumScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(stadiumProvider);
    final actions = ref.read(stadiumProvider.notifier);
    final stadium = state.selectedStadium;
    final treasuryBalance = const TreasuryService().balanceRupees;
    final pitch = StadiumPitch(stadiumName: stadium.name, city: stadium.city, basePitchType: stadium.pitchType);
    return Scaffold(
      appBar: AppBar(title: const Text('STADIUM & PITCH')),
      body: ListView(padding: const EdgeInsets.all(18), children: [
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF243047), Color(0xFF111827)]),
          borderRadius: BorderRadius.circular(20), border: Border.all(color: GamePalette.line)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('HOME GROUND', style: TextStyle(color: GamePalette.gold, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
            const SizedBox(height: 8),
            Text(stadium.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            Text(stadium.city, style: const TextStyle(color: Colors.white60)),
            const SizedBox(height: 14),
            Text('Pitch: ${_pitchLabel(stadium.pitchType)}', style: const TextStyle(color: GamePalette.emerald, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              _stat('CAPACITY', '${stadium.capacity} seats'),
              _stat('TICKET', '₹${stadium.ticketPrice}'),
              _stat('HOME MORALE', '+${stadium.homeMoraleBonus}'),
              _stat('CHEMISTRY', '+${stadium.homeChemistryBonus}'),
            ]),
          ]),
        ),
        const SizedBox(height: 18),
        const Text('CHOOSE A STADIUM', style: TextStyle(color: GamePalette.gold, fontWeight: FontWeight.w900, letterSpacing: 1.1)),
        const SizedBox(height: 8),
        for (final option in state.stadiums) Card(
          color: option.id == stadium.id ? const Color(0xFF26352F) : GamePalette.panel,
          child: ListTile(
            leading: Icon(_pitchIcon(option.pitchType), color: GamePalette.gold),
            title: Text(option.name, style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text('${option.city} · ${_pitchLabel(option.pitchType)} · ${option.capacity} seats'),
            trailing: option.id == stadium.id ? const Icon(Icons.check_circle, color: GamePalette.emerald) : const Icon(Icons.chevron_right),
            onTap: () => actions.selectStadium(option.id))),
        const SizedBox(height: 16),
        const Text('PITCH PROFILE', style: TextStyle(color: GamePalette.gold, fontWeight: FontWeight.w900, letterSpacing: 1.1)),
        const SizedBox(height: 8),
        _meter('Bounce', pitch.bounce, 'Carry and bounce consistency'),
        _meter('Swing assistance', pitch.swingAssistance, 'New-ball movement for seamers'),
        _meter('Seam assistance', pitch.seamAssistance, 'Movement off the surface'),
        _meter('Spin assistance', pitch.spinAssistance, 'Turn and grip for spinners'),
        _meter('Boundary factor', pitch.boundaryFactor, 'Higher values support more boundaries'),
        const SizedBox(height: 18),
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: GamePalette.panel, borderRadius: BorderRadius.circular(16), border: Border.all(color: GamePalette.line)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('OPERATING TREASURY  ₹${treasuryBalance.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w900, color: GamePalette.gold)),
            const SizedBox(height: 6),
            Text('Last home-match revenue: ₹${state.lastMatchRevenue}', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 10),
            const Text('Expand capacity by 5,000 seats for ₹60,00,000. IPL venue capacity is not capped at 65,000 seats.', style: TextStyle(color: Colors.white60, height: 1.35)),
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, child: ElevatedButton.icon(
              onPressed: stadium.capacity >= StadiumEconomy.maximumCapacity || treasuryBalance < 6000000 ? null : () async {
                try { await actions.expandBy(5000); if(context.mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Stadium expansion completed.'))); }
                on StateError catch (error) { if(context.mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message))); }
              },
              icon: const Icon(Icons.stadium_rounded), label: const Text('UPGRADE STADIUM'))),
            const SizedBox(height: 6),
            SizedBox(width:double.infinity,child:OutlinedButton.icon(onPressed:()=>Navigator.of(context).push(MaterialPageRoute<void>(builder:(_)=>const IncomeStatementScreen())),icon:const Icon(Icons.receipt_long_rounded),label:const Text('VIEW INCOME STATEMENT'))),
            const SizedBox(height: 8),
            Text(state.lastAction, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ])),
        const SizedBox(height: 12),
        const Text('Home-ground morale and chemistry bonuses are exposed by the stadium model but are not yet automatically applied to player morale.', style: TextStyle(color: Colors.white38, fontSize: 11, height: 1.4)),
      ]),
    );
  }

  static Widget _stat(String label, String value) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.w900)),
      const SizedBox(height: 3), Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12))]));
  static Widget _meter(String label, double value, String description) => Padding(padding: const EdgeInsets.symmetric(vertical: 7),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800))), Text('${value.toStringAsFixed(2)}×', style: const TextStyle(color: GamePalette.gold, fontWeight: FontWeight.w900))]),
      const SizedBox(height: 4), LinearProgressIndicator(value: (value / 2).clamp(0, 1), minHeight: 5, backgroundColor: Colors.white12, color: GamePalette.emerald),
      const SizedBox(height: 3), Text(description, style: const TextStyle(color: Colors.white54, fontSize: 11))]));
  static String _pitchLabel(StadiumPitchType type) => switch (type) {
    StadiumPitchType.flatBattingParadise => 'Flat batting paradise',
    StadiumPitchType.greenTopSeamer => 'Green-top seamer',
    StadiumPitchType.dryDustySpinner => 'Dry, dusty spinner',
    StadiumPitchType.wearingBalanced => 'Wearing balanced pitch',
  };
  static IconData _pitchIcon(StadiumPitchType type) => switch (type) {
    StadiumPitchType.flatBattingParadise => Icons.wb_sunny_rounded,
    StadiumPitchType.greenTopSeamer => Icons.grass_rounded,
    StadiumPitchType.dryDustySpinner => Icons.landscape_rounded,
    StadiumPitchType.wearingBalanced => Icons.sports_cricket_rounded,
  };
}
