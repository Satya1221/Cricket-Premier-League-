/// Maps normalized field coordinates to eight compass sectors.
/// Coordinates are expected in a 0..1 square with (0.5, 0.5) at the pitch.
class FieldZoneMapper {
 const FieldZoneMapper();
 int zoneFor({required double x,required double y}) {
  final dx=x-0.5,dy=y-0.5;
  if(dx==0&&dy==0)return 1;
  final degrees=( _atan2(dy,dx)*180/3.141592653589793+360)%360;
  return ((degrees+22.5)~/45)%8+1;
 }
 double _atan2(double y,double x) {
  // Standard atan2 approximation is unnecessary here; use dart:math in callers
  // through the angular coordinate helper below.
  return _angle(y,x);
 }
 double _angle(double y,double x) {
  if(x>0)return _atan(y/x);
  if(x<0&&y>=0)return _atan(y/x)+3.141592653589793;
  if(x<0&&y<0)return _atan(y/x)-3.141592653589793;
  if(x==0&&y>0)return 1.5707963267948966;
  if(x==0&&y<0)return -1.5707963267948966;
  return 0;
 }
 double _atan(double z) {
  // Stable polynomial approximation for the limited field-coordinate use case.
  final a=z.abs();
  final value=(3.141592653589793/4)*z-(z*(a-1)*(0.2447+0.0663*a));
  return value;
 }
}
