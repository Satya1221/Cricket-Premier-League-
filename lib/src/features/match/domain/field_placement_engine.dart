import 'dart:math' as math;
enum FieldPositionRole { closeCatcher, innerRing, boundaryRider, deepCatcher, legSlip, thirdMan, fineLeg, deepSquare, cover, longOn, longOff }
class FieldFielder {
  const FieldFielder({required this.playerId, required this.x, required this.y, required this.role});
  final String playerId;
  /// Normalized oval coordinates, each in [0, 1].
  final double x, y;
  final FieldPositionRole role;
}
class FieldPlacement {
  FieldPlacement({List<FieldFielder> fielders = const []}) : fielders = List.unmodifiable(fielders);
  final List<FieldFielder> fielders;
  FieldPlacement move(String playerId, double x, double y, FieldPositionRole role) => FieldPlacement(fielders: [
    for (final f in fielders) if (f.playerId != playerId) f,
    FieldFielder(playerId: playerId, x: x.clamp(0, 1), y: y.clamp(0, 1), role: role),
  ]);
}
class FieldingImpact {
  const FieldingImpact({required this.boundaryContainment, required this.catchingSupport, required this.wicketBonus});
  final double boundaryContainment, catchingSupport, wicketBonus;
}
class FieldPlacementEngine {
  FieldingImpact evaluate({required FieldPlacement placement, required String favouriteShot, required bool batterWeakToCurrentDelivery}) {
    final shot = favouriteShot.toLowerCase();
    var containment = 0.0, catching = 0.0;
    for (final f in placement.fielders) {
      final nearBoundary = f.x < .18 || f.x > .82 || f.y < .18 || f.y > .82;
      if (nearBoundary && ((shot.contains('pull') && f.role == FieldPositionRole.deepSquare) ||
          (shot.contains('cut') && f.role == FieldPositionRole.thirdMan) ||
          (shot.contains('drive') && (f.role == FieldPositionRole.cover || f.role == FieldPositionRole.longOff)) ||
          (shot.contains('sweep') && (f.role == FieldPositionRole.fineLeg || f.role == FieldPositionRole.deepSquare)))) containment += .12;
      if (f.role == FieldPositionRole.closeCatcher || f.role == FieldPositionRole.legSlip || f.role == FieldPositionRole.deepCatcher) catching += .08;
    }
    final weak = batterWeakToCurrentDelivery ? .08 : 0.0;
    return FieldingImpact(boundaryContainment: math.min(.6, containment), catchingSupport: math.min(.4, catching), wicketBonus: math.min(.24, catching * .5 + weak));
  }
}
