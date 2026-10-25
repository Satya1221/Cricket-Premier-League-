import 'dart:math' as math;

/// Maps normalized field coordinates to eight compass sectors.
/// Coordinates are expected in a 0..1 square with (0.5, 0.5) at the pitch.
class FieldZoneMapper {
 const FieldZoneMapper();
 int zoneFor({required double x,required double y}) {
  final dx=x-0.5,dy=y-0.5;
  if(dx==0&&dy==0)return 1;
  final degrees=(math.atan2(dy,dx)*180/math.pi+360)%360;
  return ((degrees+22.5)~/45)%8+1;
 }
}
