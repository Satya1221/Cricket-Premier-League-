import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'regen_factory.dart';

/// First-session prospect pool. Kept in Riverpod memory until persistent player
/// storage is introduced and connected to the auction/roster repositories.
final initialPlayerPoolProvider =
    StateProvider<List<YouthProspect>>((ref) => const []);
