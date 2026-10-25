import 'dart:math';

/// Playing role assigned to procedurally generated youth prospects.
enum Role { batter, bowler, allRounder, wicketKeeper }

/// Hidden potential tier. The tier distribution is intentionally top-light.
enum PotentialTier { benchwarmer, squadPlayer, star, generational }

class YouthProspect {
  YouthProspect({
    required this.name,
    required this.age,
    required this.role,
    required this.startingOvr,
    required this.softCap,
    required this.tier,
  })  : assert(age >= 16 && age <= 19),
        assert(startingOvr >= 30 && startingOvr <= 99),
        assert(softCap >= startingOvr && softCap <= 99);

  final String name;
  final int age;
  final Role role;
  final int startingOvr;

  /// Hidden development ceiling, used by the progression engine.
  final int softCap;
  final PotentialTier tier;

  /// Initial auction value in crore, derived from ability rather than potential.
  /// Potential remains hidden so a high ceiling does not automatically inflate
  /// a prospect's starting price.
  double get basePriceCr {
    final rating = startingOvr.toDouble();
    if (rating < 45) return 0.2;
    if (rating < 50) return 0.3;
    if (rating < 55) return 0.4;
    if (rating < 60) return 0.6;
    if (rating < 65) return 0.8;
    return 1.0;
  }
}

/// Creates a fresh, balanced youth intake for future-season auctions.
///
/// Supply [Random(seed)] for reproducible drafts in tests or saved games.
class RegenFactory {
  RegenFactory({Random? random}) : _rng = random ?? Random();

  final Random _rng;

  static const List<String> _firstNames = [
    'Aarav', 'Rohan', 'Ishan', 'Aryan', 'Kabir', 'Dhruv', 'Liam', 'Noah',
    'Vivaan', 'Arjun', 'Reyansh', 'Aditya', 'Dev', 'Kian', 'Zayn', 'Ibrahim',
    'Anaya', 'Ayaan', 'Neel', 'Krish', 'Rahul', 'Sameer', 'Yash', 'Aman',
  ];

  static const List<String> _lastNames = [
    'Sharma', 'Patel', 'Singh', 'Khan', 'Kumar', 'Gupta', 'Smith', 'Ali',
    'Das', 'Borah', 'Dutta', 'Saikia', 'Verma', 'Reddy', 'Mehta', 'Joshi',
    'Ahmed', 'Nair', 'Chowdhury', 'Kapoor', 'Mishra', 'Pillai', 'Thakur',
    'Fernandes',
  ];

  /// Generates [count] prospects. A count of 30 is a sensible yearly intake.
  List<YouthProspect> generateDraftClass(int count) {
    if (count < 0) {
      throw ArgumentError.value(count, 'count', 'Must not be negative');
    }

    final prospects = <YouthProspect>[];
    final usedNames = <String>{};
    final maxUniqueNames = _firstNames.length * _lastNames.length;
    if (count > maxUniqueNames) {
      throw ArgumentError.value(
        count,
        'count',
        'Exceeds the available unique generated names ($maxUniqueNames)',
      );
    }

    while (prospects.length < count) {
      final prospect = _generateSingleRegen();
      if (usedNames.add(prospect.name)) prospects.add(prospect);
    }
    return List<YouthProspect>.unmodifiable(prospects);
  }

  YouthProspect _generateSingleRegen() {
    final name =
        '${_firstNames[_rng.nextInt(_firstNames.length)]} '
        '${_lastNames[_rng.nextInt(_lastNames.length)]}';
    final age = 16 + _rng.nextInt(4);
    final role = _generateRole();
    final tier = _determineTier();

    late final int startingOvr;
    late final int softCap;

    switch (tier) {
      case PotentialTier.benchwarmer:
        startingOvr = 40 + _rng.nextInt(10); // 40–49
        softCap = 65 + _rng.nextInt(10); // 65–74
      case PotentialTier.squadPlayer:
        startingOvr = 48 + _rng.nextInt(12); // 48–59
        softCap = 75 + _rng.nextInt(10); // 75–84
      case PotentialTier.star:
        startingOvr = 55 + _rng.nextInt(10); // 55–64
        softCap = 85 + _rng.nextInt(7); // 85–91
      case PotentialTier.generational:
        startingOvr = 62 + _rng.nextInt(10); // 62–71
        softCap = 92 + _rng.nextInt(8); // 92–99
    }

    return YouthProspect(
      name: name,
      age: age,
      role: role,
      startingOvr: startingOvr,
      softCap: softCap,
      tier: tier,
    );
  }

  Role _generateRole() {
    final roll = _rng.nextInt(100);
    if (roll < 35) return Role.batter;
    if (roll < 70) return Role.bowler;
    if (roll < 90) return Role.allRounder;
    return Role.wicketKeeper;
  }

  PotentialTier _determineTier() {
    final roll = _rng.nextInt(100);
    if (roll < 60) return PotentialTier.benchwarmer;
    if (roll < 85) return PotentialTier.squadPlayer;
    if (roll < 97) return PotentialTier.star;
    return PotentialTier.generational;
  }
}
