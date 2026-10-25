import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../match/domain/field_placement_engine.dart';

/// Ready-made fielding setups so the manager does not have to place eleven
/// fielders by hand every over.
enum FieldPreset {
  balanced('Balanced'),
  powerplay('Powerplay (attacking)'),
  spinTrap('Spin trap'),
  deathOvers('Death overs');

  const FieldPreset(this.label);

  final String label;
}

const Map<FieldPreset, List<FieldFielder>> _presets = {
  FieldPreset.balanced: [
    FieldFielder(playerId: 'WK', x: .50, y: .62, role: FieldPositionRole.closeCatcher),
    FieldFielder(playerId: 'BWL', x: .50, y: .30, role: FieldPositionRole.innerRing),
    FieldFielder(playerId: 'COV', x: .28, y: .44, role: FieldPositionRole.cover),
    FieldFielder(playerId: 'MOF', x: .42, y: .34, role: FieldPositionRole.innerRing),
    FieldFielder(playerId: 'MON', x: .58, y: .34, role: FieldPositionRole.innerRing),
    FieldFielder(playerId: 'MWK', x: .72, y: .44, role: FieldPositionRole.innerRing),
    FieldFielder(playerId: 'SQL', x: .80, y: .56, role: FieldPositionRole.innerRing),
    FieldFielder(playerId: 'FLG', x: .90, y: .66, role: FieldPositionRole.fineLeg),
    FieldFielder(playerId: 'TPM', x: .14, y: .34, role: FieldPositionRole.thirdMan),
    FieldFielder(playerId: 'DSP', x: .80, y: .80, role: FieldPositionRole.deepSquare),
    FieldFielder(playerId: 'LOF', x: .36, y: .82, role: FieldPositionRole.longOff),
  ],
  FieldPreset.powerplay: [
    FieldFielder(playerId: 'WK', x: .50, y: .60, role: FieldPositionRole.closeCatcher),
    FieldFielder(playerId: 'BWL', x: .50, y: .30, role: FieldPositionRole.innerRing),
    FieldFielder(playerId: 'SLP', x: .44, y: .56, role: FieldPositionRole.legSlip),
    FieldFielder(playerId: 'COV', x: .30, y: .46, role: FieldPositionRole.cover),
    FieldFielder(playerId: 'MOF', x: .40, y: .36, role: FieldPositionRole.innerRing),
    FieldFielder(playerId: 'MON', x: .60, y: .36, role: FieldPositionRole.innerRing),
    FieldFielder(playerId: 'MWK', x: .70, y: .46, role: FieldPositionRole.innerRing),
    FieldFielder(playerId: 'SQL', x: .80, y: .56, role: FieldPositionRole.innerRing),
    FieldFielder(playerId: 'TPM', x: .16, y: .32, role: FieldPositionRole.thirdMan),
    FieldFielder(playerId: 'FLG', x: .90, y: .68, role: FieldPositionRole.fineLeg),
    FieldFielder(playerId: 'DSP', x: .78, y: .78, role: FieldPositionRole.deepSquare),
  ],
  FieldPreset.spinTrap: [
    FieldFielder(playerId: 'WK', x: .50, y: .60, role: FieldPositionRole.closeCatcher),
    FieldFielder(playerId: 'BWL', x: .50, y: .32, role: FieldPositionRole.innerRing),
    FieldFielder(playerId: 'SLP', x: .43, y: .56, role: FieldPositionRole.legSlip),
    FieldFielder(playerId: 'CAT', x: .57, y: .56, role: FieldPositionRole.closeCatcher),
    FieldFielder(playerId: 'COV', x: .30, y: .46, role: FieldPositionRole.cover),
    FieldFielder(playerId: 'MWK', x: .70, y: .46, role: FieldPositionRole.innerRing),
    FieldFielder(playerId: 'SQL', x: .82, y: .58, role: FieldPositionRole.innerRing),
    FieldFielder(playerId: 'DSP', x: .80, y: .78, role: FieldPositionRole.deepSquare),
    FieldFielder(playerId: 'LON', x: .62, y: .82, role: FieldPositionRole.longOn),
    FieldFielder(playerId: 'LOF', x: .38, y: .82, role: FieldPositionRole.longOff),
    FieldFielder(playerId: 'FLG', x: .90, y: .66, role: FieldPositionRole.fineLeg),
  ],
  FieldPreset.deathOvers: [
    FieldFielder(playerId: 'WK', x: .50, y: .62, role: FieldPositionRole.closeCatcher),
    FieldFielder(playerId: 'BWL', x: .50, y: .34, role: FieldPositionRole.innerRing),
    FieldFielder(playerId: 'COV', x: .30, y: .60, role: FieldPositionRole.boundaryRider),
    FieldFielder(playerId: 'MOF', x: .36, y: .78, role: FieldPositionRole.boundaryRider),
    FieldFielder(playerId: 'MON', x: .64, y: .78, role: FieldPositionRole.boundaryRider),
    FieldFielder(playerId: 'MWK', x: .72, y: .60, role: FieldPositionRole.boundaryRider),
    FieldFielder(playerId: 'DSP', x: .82, y: .52, role: FieldPositionRole.deepSquare),
    FieldFielder(playerId: 'LON', x: .60, y: .86, role: FieldPositionRole.longOn),
    FieldFielder(playerId: 'LOF', x: .40, y: .86, role: FieldPositionRole.longOff),
    FieldFielder(playerId: 'FLG', x: .90, y: .66, role: FieldPositionRole.fineLeg),
    FieldFielder(playerId: 'TPM', x: .14, y: .34, role: FieldPositionRole.thirdMan),
  ],
};

class FieldPlacementNotifier extends StateNotifier<FieldPlacement> {
  FieldPlacementNotifier() : super(FieldPlacement(fielders: _presets[FieldPreset.balanced]!));

  void move(String playerId, double x, double y, FieldPositionRole role) =>
      state = state.move(playerId, x, y, role);

  void applyPreset(FieldPreset preset) => state = FieldPlacement(fielders: _presets[preset]!);
}

final fieldPlacementProvider =
    StateNotifierProvider<FieldPlacementNotifier, FieldPlacement>((ref) => FieldPlacementNotifier());
