import '../src/features/auction/domain/player.dart';

class SquadValidationResult {
  const SquadValidationResult(this.errors);
  final List<String> errors;
  bool get isValid => errors.isEmpty;
}

class SquadValidator {
  const SquadValidator({this.maxOverseas = 4});
  final int maxOverseas;

  SquadValidationResult validate(List<AuctionPlayer> selectedPlayers) {
    final errors = <String>[];
    if (selectedPlayers.length != 11) errors.add('Select exactly 11 players');
    if (!selectedPlayers.any((p) => p.role == PlayerRole.wicketKeeper)) errors.add('Missing Wicketkeeper');
    if (selectedPlayers.where((p) => p.bowling > 40).length < 5) errors.add('Not enough bowlers');
    if (selectedPlayers.where((p) => p.isOverseas).length > maxOverseas) errors.add('Maximum $maxOverseas overseas players allowed');
    if (selectedPlayers.map((p) => p.id).toSet().length != selectedPlayers.length) errors.add('Duplicate players selected');
    return SquadValidationResult(List.unmodifiable(errors));
  }

  bool validateLineup(List<AuctionPlayer> selectedPlayers) => validate(selectedPlayers).isValid;

  void requireValidLineup(List<AuctionPlayer> selectedPlayers) {
    final result = validate(selectedPlayers);
    if (!result.isValid) throw FormatException(result.errors.join('; '));
  }
}
