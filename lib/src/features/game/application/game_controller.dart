import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local_storage_service.dart';

/// High-level lifecycle of a franchise save.
enum GamePhase { preSeason, auction, season, postSeason }

class GameSessionState {
  const GameSessionState({
    this.phase = GamePhase.preSeason,
    this.seasonNumber = 1,
    this.completedMatches = 0,
    this.lastAction = 'Welcome to Cricket Premier League.',
    this.campaignId,
    this.league = 'Indian Premier League',
    this.franchiseName = 'Coastal Premier Lions',
    this.purseCr = 120,
    this.difficulty = 'Normal',
  })  : assert(seasonNumber >= 1),
        assert(completedMatches >= 0),
        assert(purseCr >= 0);

  final GamePhase phase;
  final int seasonNumber;
  final int completedMatches;
  final String lastAction;
  final String? campaignId;
  final String league;
  final String franchiseName;
  final double purseCr;
  final String difficulty;

  GameSessionState copyWith({
    GamePhase? phase,
    int? seasonNumber,
    int? completedMatches,
    String? lastAction,
    String? campaignId,
    String? league,
    String? franchiseName,
    double? purseCr,
    String? difficulty,
  }) =>
      GameSessionState(
        phase: phase ?? this.phase,
        seasonNumber: seasonNumber ?? this.seasonNumber,
        completedMatches: completedMatches ?? this.completedMatches,
        lastAction: lastAction ?? this.lastAction,
        campaignId: campaignId ?? this.campaignId,
        league: league ?? this.league,
        franchiseName: franchiseName ?? this.franchiseName,
        purseCr: purseCr ?? this.purseCr,
        difficulty: difficulty ?? this.difficulty,
      );
}

/// Coordinates campaign lifecycle. The save repository listens to these
/// state transitions and writes snapshots to local storage.
class GameController extends StateNotifier<GameSessionState> {
  GameController({LocalStorageService? storage})
      : _storage = storage ?? LocalStorageService(),
        super(const GameSessionState()) {
    final saved = _storage.loadSession();
    if (saved != null) {
      state = GameSessionState.fromJson(saved);
    }
    addListener((snapshot) {
      unawaited(_storage.saveSession(snapshot.toJson()));
    });
  }

  final LocalStorageService _storage;

  void startCampaign({
    required String campaignId,
    required String league,
    required String franchiseName,
    required double purseCr,
    required String difficulty,
  }) {
    state = GameSessionState(
      campaignId: campaignId,
      league: league,
      franchiseName: franchiseName,
      purseCr: purseCr,
      difficulty: difficulty,
      lastAction: '$franchiseName ready for Season 1 of $league.',
    );
  }

  void restoreCampaign({
    required String campaignId,
    required String league,
    required String franchiseName,
    required double purseCr,
    required String difficulty,
    required int seasonNumber,
    required int completedMatches,
    required String phase,
    required String lastAction,
  }) {
    final savedPhase = GamePhase.values.firstWhere(
      (value) => value.name == phase,
      orElse: () => GamePhase.preSeason,
    );
    state = GameSessionState(
      campaignId: campaignId,
      league: league,
      franchiseName: franchiseName,
      purseCr: purseCr,
      difficulty: difficulty,
      seasonNumber: seasonNumber,
      completedMatches: completedMatches,
      phase: savedPhase,
      lastAction: lastAction,
    );
  }

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
