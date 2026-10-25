import 'dart:math';
import 'format_config.dart';
import 'living_pitch.dart';
import 'delivery_resolution_engine.dart';
import '../../squad/domain/granular_player_profile.dart';

class SimPlayer {
  const SimPlayer({required this.id, required this.name, this.batting = 60, this.power = 60, this.technique = 60, this.bowling = 60, this.pace = 60, this.spin = false});
  final String id, name;
  final int batting, power, technique, bowling, pace;
  final bool spin;
}
class SimTeam {
  const SimTeam({required this.id, required this.name, required this.players});
  final String id, name;
  final List<SimPlayer> players;
}
class SimInningsResult {
  const SimInningsResult({required this.teamId, required this.runs, required this.wickets, required this.legalBalls, required this.batterRuns, required this.bowlerWickets});
  final String teamId;
  final int runs, wickets, legalBalls;
  final Map<String, int> batterRuns, bowlerWickets;
  String get scoreText => '$runs/$wickets (${legalBalls ~/ 6}.${legalBalls % 6} overs)';
}
class MatchResultSummary {
  const MatchResultSummary({required this.matchId, required this.homeTeamId, required this.awayTeamId, required this.homeInnings, required this.awayInnings, required this.winnerId, required this.resultText, required this.format});
  final String matchId, homeTeamId, awayTeamId, winnerId, resultText;
  final SimInningsResult homeInnings, awayInnings;
  final CricketFormat format;
  bool get isTie => winnerId.isEmpty;
}
class AutoSimEngine {
  AutoSimEngine({Random? random}) : _random = random ?? Random();
  final Random _random;
  MatchResultSummary simulateInstantMatch({required String matchId, required SimTeam home, required SimTeam away, required CricketFormat format}) {
    if (home.players.length < 2 || away.players.length < 2) {
      throw ArgumentError('Each team needs at least two players.');
    }
    final first = _simulateInnings(team: home, bowlingTeam: away, format: format, target: null);
    final second = _simulateInnings(team: away, bowlingTeam: home, format: format, target: first.runs + 1);
    final winner = first.runs == second.runs ? '' : first.runs > second.runs ? home.id : away.id;
    final result = winner.isEmpty ? 'Match tied' : winner == home.id ? '${home.name} won by ${first.runs - second.runs} runs' : '${away.name} won by ${10 - second.wickets} wickets';
    return MatchResultSummary(matchId: matchId, homeTeamId: home.id, awayTeamId: away.id, homeInnings: first, awayInnings: second, winnerId: winner, resultText: result, format: format);
  }
  SimInningsResult _simulateInnings({required SimTeam team, required SimTeam bowlingTeam, required CricketFormat format, required int? target}) {
    final config = FormatConfig.forFormat(format);
    final env = MatchEnvironment(pitchType: PitchType.flat, weather: Weather.sunny);
    final engine = DeliveryResolutionEngine(random: _random);
    final batterRuns = <String, int>{}; final bowlerWickets = <String, int>{};
    var runs = 0, wickets = 0, balls = 0, batterIndex = 0, bowlerIndex = 0;
    while (balls < config.legalBallsPerInnings && wickets < 10 && batterIndex < team.players.length && (target == null || runs < target)) {
      final batter = team.players[batterIndex]; final bowler = bowlingTeam.players[bowlerIndex % bowlingTeam.players.length];
      final bat = ResolutionBatter(name: batter.name, baseTiming: batter.technique.toDouble(), baseDefense: batter.batting.toDouble(), concentration: .85, attributes: BattingStats(bat: batter.batting, pow: batter.power, tec: batter.technique, vp: batter.technique, vs: batter.technique));
      final bowl = ResolutionBowler(name: bowler.name, baseAccuracy: bowler.bowling.toDouble(), baseMovement: bowler.pace.toDouble(), isSpinner: bowler.spin, attributes: BowlingStats(bowl: bowler.bowling, ctrl: bowler.bowling, dth: bowler.bowling, pace: bowler.pace, varStat: bowler.bowling));
      final delivery = engine.resolve(environment: env, bowler: bowl, batter: bat, intent: BatterIntent.rotate);
      balls++;
      final scored = switch (delivery.outcome) { DeliveryOutcomeType.wicket || DeliveryOutcomeType.dot => 0, DeliveryOutcomeType.one => 1, DeliveryOutcomeType.two => 2, DeliveryOutcomeType.four => 4, DeliveryOutcomeType.six => 6 };
      runs += scored; batterRuns.update(batter.id, (v) => v + scored, ifAbsent: () => scored);
      if (delivery.outcome == DeliveryOutcomeType.wicket) { wickets++; bowlerWickets.update(bowler.id, (v) => v + 1, ifAbsent: () => 1); batterIndex++; }
      if (balls % config.ballsPerOver == 0) { env.advanceOver(); bowlerIndex++; }
    }
    return SimInningsResult(teamId: team.id, runs: runs, wickets: wickets, legalBalls: balls, batterRuns: Map.unmodifiable(batterRuns), bowlerWickets: Map.unmodifiable(bowlerWickets));
  }
}