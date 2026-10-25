import 'package:flutter_riverpod/flutter_riverpod.dart';

/// High-level lifecycle of a franchise save.
enum GamePhase { preSeason, auction, season, postSeason }

class GameSessionState {
  const GameSessionState({
    this.phase = GamePhase.preSeason,
    this.seasonNumber = 1,
    this.completedMatches = 0,
    this.lastAction = 'Welcome to Cricket Premier League.',
  })  : assert(seasonNumber >= 1),
        assert(completedMatches >= 0);

  final GamePhase phase;
  final int seasonNumber;
  final int completedMatches;
  final String lastAction;

  GameSessionState copyWith({
    GamePhase? phase,
    int? seasonNumber,
    int? completedMatches,
    String? lastAction,
  }) =>
      GameSessionState(
        phase: phase ?? this.phase,
        seasonNumber: seasonNumber ?? this.seasonNumber,
        completedMatches: completedMatches ?? this.completedMatches,
        lastAction: lastAction ?? this.lastAction,
      );
}

/// Riverpod's central coordinator for top-level game progression.
///
/// Domain engines remain responsible for cricket/auction calculations. This
/// controller coordinates phase transitions; it deliberately does not pretend
/// that persistent storage exists until a repository is implemented.
class GameController extends StateNotifier<GameSessionState> {
  GameController() : super(const GameSessionState());

  void startAuction() {
    state = state.copyWith(
      phase: GamePhase.auction,
      lastAction: 'Season ${state.seasonNumber} auction is ready.',
    );
  }

  void startSeason() {
    if (state.phase != GamePhase.auction &&
        state.phase != GamePhase.preSeason) {
      throw StateError('A season can only start from pre-season or auction.');
    }
    state = state.copyWith(
      phase: GamePhase.season,
      lastAction: 'Season ${state.seasonNumber} is underway.',
    );
  }

  void recordMatchCompleted() {
    if (state.phase != GamePhase.season) {
      throw StateError('Matches can only be completed during a season.');
    }
    state = state.copyWith(
      completedMatches: state.completedMatches + 1,
      lastAction: 'Match ${state.completedMatches + 1} completed.',
    );
  }

  void endSeason() {
    if (state.phase != GamePhase.season) {
      throw StateError('Only an active season can end.');
    }
    state = state.copyWith(
      phase: GamePhase.postSeason,
      lastAction: 'Season ${state.seasonNumber} completed.',
    );
  }

  void beginNextSeason() {
    if (state.phase != GamePhase.postSeason) {
      throw StateError('Finish the current season before starting another.');
    }
    state = state.copyWith(
      phase: GamePhase.preSeason,
      seasonNumber: state.seasonNumber + 1,
      completedMatches: 0,
      lastAction: 'Pre-season for Season ${state.seasonNumber + 1}.',
    );
  }
}

final gameControllerProvider =
    StateNotifierProvider<GameController, GameSessionState>(
  (ref) => GameController(),
);
