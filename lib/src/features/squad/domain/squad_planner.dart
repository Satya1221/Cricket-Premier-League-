/// Pure Dart squad selection and match-readiness validation.
///
/// UI layers can listen to their own state holder and call these methods;
/// this domain model intentionally has no Flutter dependency.
enum PlayerStyle { batter, bowler, allRounder, wicketKeeper }

class SquadPlayer {
  SquadPlayer({
    required this.id,
    required this.name,
    required this.style,
    required this.overallRating,
    required this.fitness,
  }) : assert(overallRating >= 1 && overallRating <= 100),
       assert(fitness >= 0 && fitness <= 1);

  final String id;
  final String name;
  final PlayerStyle style;
  final int overallRating;

  /// 1.0 means fully rested; values below 0.75 are considered tired.
  double fitness;
}

enum SquadSelectionResult { added, removed, alreadySelected, squadFull, notInSquad }

class SquadValidationResult {
  const SquadValidationResult({
    required this.errors,
    required this.warnings,
    required this.bowlingOptions,
    required this.tiredPlayerIds,
  });

  final List<String> errors;
  final List<String> warnings;
  final int bowlingOptions;
  final List<String> tiredPlayerIds;

  bool get isValid => errors.isEmpty;
  bool get canStartMatch => isValid;
}

class SquadPlanner {
  SquadPlanner(List<SquadPlayer> fullSquad)
      : fullSquad = List.unmodifiable(fullSquad);

  final List<SquadPlayer> fullSquad;
  final List<SquadPlayer> _playingXI = [];
  SquadPlayer? captain;
  SquadPlayer? wicketKeeper;

  List<SquadPlayer> get playingXI => List.unmodifiable(_playingXI);
  int get remainingSlots => 11 - _playingXI.length;

  SquadSelectionResult toggleSelection(SquadPlayer player) {
    if (!fullSquad.any((member) => member.id == player.id)) {
      return SquadSelectionResult.notInSquad;
    }

    final selectedIndex = _playingXI.indexWhere((member) => member.id == player.id);
    if (selectedIndex >= 0) {
      _playingXI.removeAt(selectedIndex);
      if (captain?.id == player.id) captain = null;
      if (wicketKeeper?.id == player.id) wicketKeeper = null;
      return SquadSelectionResult.removed;
    }

    if (_playingXI.length >= 11) return SquadSelectionResult.squadFull;
    _playingXI.add(player);

    if (player.style == PlayerStyle.wicketKeeper && wicketKeeper == null) {
      wicketKeeper = player;
    }
    return SquadSelectionResult.added;
  }

  bool assignCaptain(SquadPlayer player) {
    if (!_isSelected(player)) return false;
    captain = player;
    return true;
  }

  bool assignWicketKeeper(SquadPlayer player) {
    if (!_isSelected(player) || player.style != PlayerStyle.wicketKeeper) {
      return false;
    }
    wicketKeeper = player;
    return true;
  }

  bool _isSelected(SquadPlayer player) =>
      _playingXI.any((member) => member.id == player.id);

  /// Validates hard match requirements and reports fatigue separately as warnings.
  SquadValidationResult validateTeam() {
    final errors = <String>[];
    final warnings = <String>[];
    final tired = _playingXI.where((player) => player.fitness < 0.75).toList();

    if (_playingXI.length != 11) {
      errors.add('Playing XI must contain exactly 11 players (currently ${_playingXI.length}).');
    }
    if (captain == null || !_isSelected(captain!)) {
      errors.add('Appoint a captain from the selected Playing XI.');
    }
    if (wicketKeeper == null ||
        !_isSelected(wicketKeeper!) ||
        wicketKeeper!.style != PlayerStyle.wicketKeeper) {
      errors.add('Select a designated wicket-keeper from the Playing XI.');
    }

    final bowlingOptions = _playingXI
        .where((player) =>
            player.style == PlayerStyle.bowler ||
            player.style == PlayerStyle.allRounder)
        .length;
    if (bowlingOptions < 5) {
      errors.add('Insufficient bowling depth: $bowlingOptions bowling options selected; at least 5 are required.');
    }

    if (tired.isNotEmpty) {
      warnings.add(
        '${tired.length} selected player(s) have fitness below 75%: '
        '${tired.map((player) => player.name).join(', ')}. '
        'They may have reduced performance and increased injury risk.',
      );
    }

    return SquadValidationResult(
      errors: List.unmodifiable(errors),
      warnings: List.unmodifiable(warnings),
      bowlingOptions: bowlingOptions,
      tiredPlayerIds: List.unmodifiable(tired.map((player) => player.id)),
    );
  }

  /// Fitness multiplier for match-engine attributes, clamped to a safe range.
  /// This is a generic penalty hook, not a complete stamina simulation.
  double fitnessMultiplier(SquadPlayer player) {
    final fitness = player.fitness.clamp(0.0, 1.0);
    if (fitness >= 0.75) return 1.0;
    return (0.7 + fitness * 0.4).clamp(0.7, 1.0);
  }
}
