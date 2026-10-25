import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local_storage_service.dart';

class UserPreferencesState {
  const UserPreferencesState({this.difficulty = 'Normal', this.soundEnabled = true});

  final String difficulty;
  final bool soundEnabled;

  UserPreferencesState copyWith({String? difficulty, bool? soundEnabled}) =>
      UserPreferencesState(
        difficulty: difficulty ?? this.difficulty,
        soundEnabled: soundEnabled ?? this.soundEnabled,
      );

  Map<String, Object?> toJson() => {
        'difficulty': difficulty,
        'soundEnabled': soundEnabled,
      };

  factory UserPreferencesState.fromJson(Map<String, Object?> json) =>
      UserPreferencesState(
        difficulty: json['difficulty'] as String? ?? 'Normal',
        soundEnabled: json['soundEnabled'] as bool? ?? true,
      );
}

class UserPreferencesNotifier extends StateNotifier<UserPreferencesState> {
  UserPreferencesNotifier(this._storage)
      : super(UserPreferencesState.fromJson(
          _storage.loadPreferences() ?? const <String, Object?>{},
        ));

  final LocalStorageService _storage;

  Future<void> setDifficulty(String difficulty) async {
    state = state.copyWith(difficulty: difficulty);
    await _storage.savePreferences(state.toJson());
  }

  Future<void> setSoundEnabled(bool enabled) async {
    state = state.copyWith(soundEnabled: enabled);
    await _storage.savePreferences(state.toJson());
  }
}

final userPreferencesProvider =
    StateNotifierProvider<UserPreferencesNotifier, UserPreferencesState>(
  (ref) => UserPreferencesNotifier(LocalStorageService()),
);
