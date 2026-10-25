import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../match/domain/field_placement_engine.dart';
class FieldPlacementNotifier extends StateNotifier<FieldPlacement> {
  FieldPlacementNotifier() : super(FieldPlacement(fielders: const [
    FieldFielder(playerId: 'F1', x: .5, y: .25, role: FieldPositionRole.closeCatcher),
    FieldFielder(playerId: 'F2', x: .15, y: .75, role: FieldPositionRole.deepSquare),
    FieldFielder(playerId: 'F3', x: .85, y: .75, role: FieldPositionRole.thirdMan),
  ]));
  void move(String playerId, double x, double y, FieldPositionRole role) => state = state.move(playerId, x, y, role);
}
final fieldPlacementProvider = StateNotifierProvider<FieldPlacementNotifier,FieldPlacement>((ref) => FieldPlacementNotifier());