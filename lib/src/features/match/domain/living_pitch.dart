/// Headless living-pitch environment model.
///
/// Run this file directly with:
///   dart run lib/src/features/match/domain/living_pitch.dart
///
/// Modifiers are multipliers (1.0 = baseline). This module has no Flutter
/// dependency so the math can be inspected quickly in Termux.
enum PitchType { green, flat, dusty }
enum Weather { sunny, overcast, dew }

class MatchEnvironment {
  MatchEnvironment({
    required this.pitchType,
    required this.weather,
    this.ballAgeOvers = 0,
    this.pitchWear = 0.0,
  }) : assert(ballAgeOvers >= 0), assert(pitchWear >= 0 && pitchWear <= 1);

  final PitchType pitchType;
  Weather weather;
  int ballAgeOvers;
  double pitchWear;

  /// Advances the environment by one completed over.
  void advanceOver() {
    ballAgeOvers++;
    final wearRate = pitchType == PitchType.dusty ? 0.03 : 0.015;
    pitchWear = (pitchWear + wearRate).clamp(0.0, 1.0);
  }

  Map<String, double> getDeliveryModifiers() => {
    'swing': _calculateSwing(),
    'seam': _calculateSeam(),
    'spin': _calculateSpin(),
    'bounceConsistency': _calculateBounce(),
  };

  double _calculateSwing() {
    var modifier = ballAgeOvers <= 12
        ? 1.0 + (12 - ballAgeOvers) * 0.05
        : 0.5;
    if (ballAgeOvers >= 40 && pitchWear > 0.6) {
      modifier += (ballAgeOvers - 40) * 0.03;
    }
    if (weather == Weather.overcast) modifier *= 1.3;
    if (weather == Weather.dew) modifier *= 0.4;
    return modifier;
  }

  double _calculateSeam() {
    if (pitchType == PitchType.green) return 1.4 - pitchWear * 0.5;
    return 1.0 - pitchWear * 0.2;
  }

  double _calculateSpin() {
    var modifier = 1.0;
    if (pitchType == PitchType.dusty) {
      modifier = 1.2 + pitchWear * 0.8;
    } else if (pitchType == PitchType.flat) {
      modifier = 0.8 + pitchWear * 0.4;
    }
    if (weather == Weather.dew) modifier *= 0.5;
    return modifier;
  }

  double _calculateBounce() => 1.0 - pitchWear * 0.4;
}

void main() {
  print('--- Match Starts: Dusty Pitch, Sunny ---');
  final match = MatchEnvironment(pitchType: PitchType.dusty, weather: Weather.sunny);
  for (var over = 1; over <= 50; over++) {
    match.advanceOver();
    if (over % 10 == 0) {
      final mods = match.getDeliveryModifiers();
      print('Over $over (Wear: ${(match.pitchWear * 100).toInt()}%):');
      print('  Swing Mod: ${mods['swing']!.toStringAsFixed(2)}x');
      print('  Spin Mod: ${mods['spin']!.toStringAsFixed(2)}x');
      print('  Seam Mod: ${mods['seam']!.toStringAsFixed(2)}x');
      print('  Bounce Consistency: ${mods['bounceConsistency']!.toStringAsFixed(2)}');
      print('---------------------------------');
    }
  }
}
