import 'dart:math';

import 'living_pitch.dart' as living;

/// Stadium surfaces influence movement, batter control and scoring.
/// Modifiers are multipliers: 1.0 is the baseline.
enum StadiumPitchType { flatBattingParadise, greenTopSeamer, dryDustySpinner, wearingBalanced }

class StadiumPitch {
  StadiumPitch({
    required this.stadiumName,
    required this.city,
    required this.basePitchType,
    this.degradationRate = 0.08,
    double? bounce,
    double? swingAssistance,
    double? seamAssistance,
    double? spinAssistance,
    double? boundaryFactor,
  })  : bounce = bounce ?? _base(basePitchType).bounce,
        swingAssistance = swingAssistance ?? _base(basePitchType).swing,
        seamAssistance = seamAssistance ?? _base(basePitchType).seam,
        spinAssistance = spinAssistance ?? _base(basePitchType).spin,
        boundaryFactor = boundaryFactor ?? _base(basePitchType).boundary;

  final String stadiumName;
  final String city;
  final StadiumPitchType basePitchType;
  final double degradationRate;
  double bounce;
  double swingAssistance;
  double seamAssistance;
  double spinAssistance;
  double boundaryFactor;
  int wearStages = 0;

  static ({double bounce, double swing, double seam, double spin, double boundary}) _base(StadiumPitchType type) => switch (type) {
    StadiumPitchType.greenTopSeamer => (bounce: 1.3, swing: 1.6, seam: 1.65, spin: 0.65, boundary: 0.92),
    StadiumPitchType.dryDustySpinner => (bounce: 0.9, swing: 0.7, seam: 0.8, spin: 1.7, boundary: 0.95),
    StadiumPitchType.flatBattingParadise => (bounce: 1.1, swing: 0.8, seam: 0.85, spin: 0.8, boundary: 1.18),
    StadiumPitchType.wearingBalanced => (bounce: 1.0, swing: 1.0, seam: 1.0, spin: 1.0, boundary: 1.0),
  };

  /// Call after an innings in limited overs, or after each day in a Test.
  void degradePitch({int stages = 1}) {
    if (stages <= 0) {
      return;
    }
    wearStages += stages;
    final wear = degradationRate * stages;
    spinAssistance = (spinAssistance + wear).clamp(0.5, 2.0).toDouble();
    swingAssistance = (swingAssistance - wear * 0.35).clamp(0.5, 2.0).toDouble();
    seamAssistance = (seamAssistance - wear * 0.25).clamp(0.5, 2.0).toDouble();
    bounce = (bounce + wear * 0.12).clamp(0.5, 1.8).toDouble();
    boundaryFactor = (boundaryFactor - wear * 0.04).clamp(0.75, 1.25).toDouble();
  }

  double get irregularBounceRisk => min(0.45, wearStages * degradationRate * 0.08);

  Map<String, double> get modifiers => Map.unmodifiable({
    'bounce': bounce, 'swing': swingAssistance, 'seam': seamAssistance,
    'spin': spinAssistance, 'boundary': boundaryFactor,
    'irregularBounceRisk': irregularBounceRisk,
  });

  living.MatchEnvironment createMatchEnvironment({living.Weather weather = living.Weather.sunny}) {
    final type = switch (basePitchType) {
      StadiumPitchType.greenTopSeamer => living.PitchType.green,
      StadiumPitchType.dryDustySpinner => living.PitchType.dusty,
      StadiumPitchType.flatBattingParadise || StadiumPitchType.wearingBalanced => living.PitchType.flat,
    };
    return _StadiumMatchEnvironment(pitchType: type, weather: weather, stadium: this);
  }
}

/// Applies stadium multipliers over existing weather and ball-age modifiers.
class _StadiumMatchEnvironment extends living.MatchEnvironment {
  _StadiumMatchEnvironment({required super.pitchType, required super.weather, required this.stadium});
  final StadiumPitch stadium;

  @override
  Map<String, double> getDeliveryModifiers() {
    final base = super.getDeliveryModifiers();
    return {
      'swing': (base['swing']! * stadium.swingAssistance).clamp(0.35, 2.5).toDouble(),
      'seam': (base['seam']! * stadium.seamAssistance).clamp(0.35, 2.5).toDouble(),
      'spin': (base['spin']! * stadium.spinAssistance).clamp(0.35, 2.5).toDouble(),
      'bounceConsistency': (base['bounceConsistency']! / stadium.bounce).clamp(0.4, 1.5).toDouble(),
      'boundary': stadium.boundaryFactor,
      'irregularBounceRisk': stadium.irregularBounceRisk,
    };
  }
}

class StadiumAsset {
  const StadiumAsset({
    required this.id, required this.name, required this.city, required this.pitchType,
    this.capacity = 15000, this.ticketPrice = 800, this.homeMoraleBonus = 3, this.homeChemistryBonus = 2,
  });
  final String id, name, city;
  final StadiumPitchType pitchType;
  final int capacity, ticketPrice, homeMoraleBonus, homeChemistryBonus;
  int get ticketRevenuePerSoldOutMatch => capacity * ticketPrice;

  StadiumAsset copyWith({int? capacity, int? ticketPrice}) => StadiumAsset(
    id: id, name: name, city: city, pitchType: pitchType,
    capacity: capacity ?? this.capacity, ticketPrice: ticketPrice ?? this.ticketPrice,
    homeMoraleBonus: homeMoraleBonus, homeChemistryBonus: homeChemistryBonus,
  );
}

class StadiumEconomy {
  static const int expansionCostPerSeat = 120;
  static const int maximumCapacity = 65000;

  static StadiumAsset expand(StadiumAsset stadium, {required int seats, required int availableFunds}) {
    if (seats <= 0) {
      throw ArgumentError.value(seats, 'seats', 'Must be positive.');
    }
    if (stadium.capacity + seats > maximumCapacity) {
      throw StateError('Stadium capacity cannot exceed 65000.');
    }
    final cost = seats * expansionCostPerSeat;
    if (cost > availableFunds) {
      throw StateError('Not enough franchise funds for this expansion.');
    }
    return stadium.copyWith(capacity: stadium.capacity + seats);
  }

  static int ticketRevenue(StadiumAsset stadium, {double attendanceRate = 1.0}) {
    if (attendanceRate < 0 || attendanceRate > 1) {
      throw ArgumentError.value(attendanceRate, 'attendanceRate', 'Must be between 0 and 1.');
    }
    return (stadium.ticketRevenuePerSoldOutMatch * attendanceRate).round();
  }
}

List<StadiumAsset> defaultStadiums() => const [
  StadiumAsset(id: 'chepauk', name: 'M. A. Chidambaram Stadium', city: 'Chennai', pitchType: StadiumPitchType.dryDustySpinner, capacity: 38000, ticketPrice: 900),
  StadiumAsset(id: 'wankhede', name: 'Wankhede Stadium', city: 'Mumbai', pitchType: StadiumPitchType.flatBattingParadise, capacity: 33000, ticketPrice: 1100),
  StadiumAsset(id: 'eden', name: 'Eden Gardens', city: 'Kolkata', pitchType: StadiumPitchType.wearingBalanced, capacity: 68000, ticketPrice: 950),
  StadiumAsset(id: 'perth', name: 'Perth Stadium', city: 'Perth', pitchType: StadiumPitchType.greenTopSeamer, capacity: 60000, ticketPrice: 1200),
];
