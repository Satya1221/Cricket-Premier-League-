import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/fixture_model.dart';

/// Per-campaign schedule storage; separate careers never overwrite each other.
class SeasonScheduleRepository {
  SeasonScheduleRepository({this.saveId = 'default'});
  static const boxName = 'season_schedule';
  final String saveId;
  String get key => 'active-season-$saveId';
  Box<dynamic> get _box => Hive.box<dynamic>(boxName);

  Future<void> save(List<FixtureModel> fixtures) =>
      _box.put(key, jsonEncode(fixtures.map((f) => f.toJson()).toList()));

  List<FixtureModel> load() {
    final raw = _box.get(key);
    if (raw is! String) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map((m) => FixtureModel.fromJson(Map<String, Object?>.from(m)))
          .toList();
    } on FormatException {
      return const [];
    }
  }
}
