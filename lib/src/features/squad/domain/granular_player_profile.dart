/// Granular cricket attributes used by scouting, player cards and delivery simulation.
///
/// This remains a plain Dart domain model until Isar is deliberately added and
/// configured in pubspec.yaml. The nested classes map cleanly to Isar @embedded
/// objects, but no generated Isar code is assumed here.
enum DeliveryKind { stock, bouncer, yorker, slowerBall, spin }

class BattingStats {
  BattingStats({
    this.bat = 50, this.pow = 50, this.tec = 50, this.tmp = 50,
    this.agg = 50, this.sty = 50, this.run = 50, this.vp = 50, this.vs = 50,
  });
  int bat, pow, tec, tmp, agg, sty, run, vp, vs;
  int ratingFor({required bool againstSpin}) => _clamp((againstSpin ? vs : vp) * .45 + tec * .25 + tmp * .15 + bat * .15);
}

class BowlingStats {
  BowlingStats({
    this.bowl = 50, this.ctrl = 50, this.dth = 50, this.pace = 50,
    this.varStat = 50, this.comp = 50,
  });
  int bowl, ctrl, dth, pace, varStat, comp;
}

class FieldingStats {
  FieldingStats({this.cat = 50, this.fit = 50, this.fld = 50});
  int cat, fit, fld;
}

class PlayerCondition {
  PlayerCondition({this.form = 50, this.mor = 50, this.fitness = 80});
  int form, mor, fitness;

  /// Bounded multiplier: poor condition hurts, strong condition helps.
  double get performanceMultiplier =>
      (.72 + (form.clamp(0, 100) / 100) * .16 +
       (mor.clamp(0, 100) / 100) * .08) *
      (.85 + fitness.clamp(0, 100) / 100 * .15);
}

class PlayerTraits {
  PlayerTraits({List<String> favouriteShots = const [], List<String> weaknesses = const []})
      : favouriteShots = List.unmodifiable(favouriteShots),
        weaknesses = List.unmodifiable(weaknesses);
  final List<String> favouriteShots;
  final List<String> weaknesses;

  bool isWeakTo(DeliveryKind kind) {
    final key = switch (kind) {
      DeliveryKind.bouncer => 'bouncer',
      DeliveryKind.yorker => 'yorker',
      DeliveryKind.slowerBall => 'slower',
      DeliveryKind.spin => 'spin',
      DeliveryKind.stock => '',
    };
    return key.isNotEmpty && weaknesses.any((w) => w.toLowerCase().contains(key));
  }
}

class GranularPlayerProfile {
  GranularPlayerProfile({
    required this.name, required this.age, this.battingHand = 'RHB',
    this.role = 'Top-order', BattingStats? batting, BowlingStats? bowling,
    FieldingStats? fielding, PlayerCondition? condition, PlayerTraits? traits,
  }) : batting = batting ?? BattingStats(),
       bowling = bowling ?? BowlingStats(),
       fielding = fielding ?? FieldingStats(),
       condition = condition ?? PlayerCondition(),
       traits = traits ?? PlayerTraits();

  final String name;
  final int age;
  final String battingHand;
  final String role;
  final BattingStats batting;
  final BowlingStats bowling;
  final FieldingStats fielding;
  final PlayerCondition condition;
  final PlayerTraits traits;
}

int _clamp(num value) => value.round().clamp(1, 100);
