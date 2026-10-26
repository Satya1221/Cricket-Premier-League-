/// Human-readable labels for model fields, abbreviations and enum values.
/// Keep data identifiers in the domain; only display this output in widgets.
abstract final class DisplayLabels {
  static const Map<String, String> _labels = {
    'tmp': 'Temperament',
    'dth': 'Death-overs skill',
    'comp': 'Composure',
    'vp': 'Versus pace',
    'vs': 'Versus spin',
    'rwi': 'Reputation',
    'dpt': 'Squad depth',
    'rat': 'Overall rating',
    'cf': 'Club funds',
    'bat': 'Batting',
    'bowl': 'Bowling',
    'pow': 'Power',
    'tec': 'Technique',
    'agg': 'Aggression',
    'ctrl': 'Control',
    'var': 'Variation',
    'cat': 'Catching',
    'fld': 'Ground fielding',
    'fit': 'Fitness',
    'eco': 'Economy rate',
    'sr': 'Strike rate',
    'ovr': 'Overall rating',
    'hs': 'Highest score',
    '50s': 'Half-centuries',
    '100s': 'Centuries',
    'nrr': 'Net run rate',
    'pts': 'Points',
    'wkts': 'Wickets',
    'xi': 'Playing XI',
    'ar': 'All-rounder',
    'allrounder': 'All-rounder',
    'wicketkeeper': 'Wicketkeeper',
    'preseason': 'Pre-season',
    'postseason': 'Off-season',
    'inningsone': 'First innings',
    'inningstwo': 'Second innings',
    'noball': 'No-ball',
    'legbye': 'Leg bye',
    'runout': 'Run out',
    'hitwicket': 'Hit wicket',
    'pacebowler': 'Fast bowler',
    'spinbowler': 'Spin bowler',
    'generalfatigue': 'General fatigue',
    'slowerball': 'Slower ball',
    'runrate': 'Run rate',
    'overs': 'Overs',
    'played': 'Played',
    'won': 'Won',
    'lost': 'Lost',
  };

  static const Map<String, String> _hints = {
    'tmp': 'How reliably a player holds concentration under pressure.',
    'dth': 'Skill at the death: yorkers, slower balls and composure.',
    'comp': 'Ability to make good decisions under pressure.',
    'vp': 'Performance against fast bowling.',
    'vs': 'Performance against spin bowling.',
    'rwi': 'Reputation earned from career performance and achievements.',
    'dpt': 'How much usable cover the squad has for each role.',
    'rat': 'A combined estimate of current ability from 1 to 100.',
    'cf': 'Operating money available to the club this season.',
    'eco': 'Runs conceded per over bowled.',
    'sr': 'Runs scored per 100 balls faced.',
    'nrr': 'Run-rate difference, used to separate teams on equal points.',
  };

  static String display(String value) {
    final raw = value.trim();
    if (raw.isEmpty) return raw;
    final normalized = raw.toLowerCase().replaceAll(RegExp(r'[ _-]+'), '');
    final known = _labels[normalized] ?? _labels[raw.toLowerCase()];
    if (known != null) return known;

    final spaced = raw
        .replaceAllMapped(RegExp(r'([a-z0-9])([A-Z])'), (m) => '${m[1]} ${m[2]}')
        .replaceAll(RegExp(r'[_-]+'), ' ')
        .trim();
    if (spaced.isEmpty) return spaced;
    return spaced
        .split(RegExp(r'\s+'))
        .map((word) => word.isEmpty
            ? word
            : '${word.toLowerCase()[0].toUpperCase()}${word.toLowerCase().substring(1)}')
        .join(' ');
  }

  static String? hint(String value) {
    final key = value.trim().toLowerCase().replaceAll(RegExp(r'[ _-]+'), '');
    return _hints[key];
  }
}
