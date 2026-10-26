import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../application/game_controller.dart';
import '../../auction/domain/auction_state.dart';
import '../../auction/domain/player.dart';

/// JSON-in-Hive save model avoids generated adapters while the domain is still
/// evolving. Each slot includes campaign metadata and real auction/roster state.
class CampaignSave {
  const CampaignSave({
    required this.id,
    required this.league,
    required this.franchiseName,
    required this.purseCr,
    required this.difficulty,
    this.seasonNumber = 1,
    this.completedMatches = 0,
    this.phase = 'preSeason',
    this.lastAction = 'New campaign created.',
    this.squadCount = 0,
    this.lastSavedAt,
    this.auctionSnapshot,
    this.calendarSnapshot,
    this.rosterSnapshot,
  });

  final String id;
  final String league;
  final String franchiseName;
  final double purseCr;
  final String difficulty;
  final int seasonNumber;
  final int completedMatches;
  final String phase;
  final String lastAction;
  final int squadCount;
  final DateTime? lastSavedAt;
  final Map<String, dynamic>? auctionSnapshot;
  final Map<String, dynamic>? calendarSnapshot;
  final Map<String, dynamic>? rosterSnapshot;

  Map<String, dynamic> toJson() => {
        'id': id,
        'league': league,
        'franchiseName': franchiseName,
        'purseCr': purseCr,
        'difficulty': difficulty,
        'seasonNumber': seasonNumber,
        'completedMatches': completedMatches,
        'phase': phase,
        'lastAction': lastAction,
        'squadCount': squadCount,
        'lastSavedAt': (lastSavedAt ?? DateTime.now()).toIso8601String(),
        'auctionSnapshot': auctionSnapshot,
        'calendarSnapshot': calendarSnapshot,
        'rosterSnapshot': rosterSnapshot,
      };

  factory CampaignSave.fromJson(Map<String, dynamic> json) => CampaignSave(
        id: json['id'] as String,
        league: json['league'] as String? ?? 'Premier T20 League',
        franchiseName: json['franchiseName'] as String? ?? 'My Franchise',
        purseCr: (json['purseCr'] as num?)?.toDouble() ?? 120,
        difficulty: json['difficulty'] as String? ?? 'Normal',
        seasonNumber: (json['seasonNumber'] as num?)?.toInt() ?? 1,
        completedMatches: (json['completedMatches'] as num?)?.toInt() ?? 0,
        phase: json['phase'] as String? ?? 'preSeason',
        lastAction: json['lastAction'] as String? ?? 'Campaign loaded.',
        squadCount: (json['squadCount'] as num?)?.toInt() ?? 0,
        lastSavedAt: DateTime.tryParse(json['lastSavedAt'] as String? ?? ''),
        auctionSnapshot: (json['auctionSnapshot'] as Map?)?.cast<String, dynamic>(),
        calendarSnapshot: (json['calendarSnapshot'] as Map?)?.cast<String, dynamic>(),
        rosterSnapshot: (json['rosterSnapshot'] as Map?)?.cast<String, dynamic>(),
      );

  CampaignSave copyWith({
    String? league,
    String? franchiseName,
    double? purseCr,
    String? difficulty,
    int? seasonNumber,
    int? completedMatches,
    String? phase,
    String? lastAction,
    int? squadCount,
    DateTime? lastSavedAt,
    Map<String, dynamic>? auctionSnapshot,
    Map<String, dynamic>? calendarSnapshot,
    Map<String, dynamic>? rosterSnapshot,
  }) =>
      CampaignSave(
        id: id,
        league: league ?? this.league,
        franchiseName: franchiseName ?? this.franchiseName,
        purseCr: purseCr ?? this.purseCr,
        difficulty: difficulty ?? this.difficulty,
        seasonNumber: seasonNumber ?? this.seasonNumber,
        completedMatches: completedMatches ?? this.completedMatches,
        phase: phase ?? this.phase,
        lastAction: lastAction ?? this.lastAction,
        squadCount: squadCount ?? this.squadCount,
        lastSavedAt: lastSavedAt ?? this.lastSavedAt,
        auctionSnapshot: auctionSnapshot ?? this.auctionSnapshot,
        calendarSnapshot: calendarSnapshot ?? this.calendarSnapshot,
        rosterSnapshot: rosterSnapshot ?? this.rosterSnapshot,
      );
}

class CampaignSettings {
  const CampaignSettings({
    this.soundEnabled = true,
    this.simulationSpeed = 1.0,
    this.defaultDifficulty = 'Normal',
  });

  final bool soundEnabled;
  final double simulationSpeed;
  final String defaultDifficulty;

  Map<String, dynamic> toJson() => {
        'soundEnabled': soundEnabled,
        'simulationSpeed': simulationSpeed,
        'defaultDifficulty': defaultDifficulty,
      };

  factory CampaignSettings.fromJson(Map<String, dynamic> json) => CampaignSettings(
        soundEnabled: json['soundEnabled'] as bool? ?? true,
        simulationSpeed: (json['simulationSpeed'] as num?)?.toDouble() ?? 1,
        defaultDifficulty: json['defaultDifficulty'] as String? ?? 'Normal',
      );
}

class CampaignStore {
  CampaignStore._();

  static const _saveBoxName = 'cpl_campaign_saves';
  static const _settingsBoxName = 'cpl_game_settings';
  static const _activeIdKey = 'active_campaign_id';

  static Box<String>? _saves;
  static Box<String>? _settings;

  static Future<void> initialize() async {
    await Hive.initFlutter();
    _saves = await Hive.openBox<String>(_saveBoxName);
    _settings = await Hive.openBox<String>(_settingsBoxName);
  }

  static Box<String> get _saveBox {
    final box = _saves;
    if (box == null || !box.isOpen) {
      throw StateError('CampaignStore.initialize() must complete before use.');
    }
    return box;
  }

  static Box<String> get _settingsBox {
    final box = _settings;
    if (box == null || !box.isOpen) {
      throw StateError('CampaignStore.initialize() must complete before use.');
    }
    return box;
  }

  static bool get isInitialized => _saves?.isOpen == true && _settings?.isOpen == true;

  static String? get activeCampaignId => isInitialized ? _settingsBox.get(_activeIdKey) : null;

  static Future<void> setActiveCampaign(String id) =>
      _settingsBox.put(_activeIdKey, id);

  static List<CampaignSave> listSaves() {
    final slots = <CampaignSave>[];
    for (final raw in _saveBox.values) {
      try {
        slots.add(CampaignSave.fromJson(
          (jsonDecode(raw) as Map).cast<String, dynamic>(),
        ));
      } catch (_) {
        // A damaged slot should not prevent the other slots from loading.
      }
    }
    slots.sort((a, b) =>
        (b.lastSavedAt ?? DateTime(2000)).compareTo(a.lastSavedAt ?? DateTime(2000)));
    return List.unmodifiable(slots);
  }

  static CampaignSave? load(String id) {
    final raw = _saveBox.get(id);
    if (raw == null) return null;
    try {
      return CampaignSave.fromJson(
        (jsonDecode(raw) as Map).cast<String, dynamic>(),
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> save(CampaignSave save) async {
    final timestamped = save.copyWith(lastSavedAt: DateTime.now());
    await _saveBox.put(timestamped.id, jsonEncode(timestamped.toJson()));
    await setActiveCampaign(timestamped.id);
  }

  static Future<void> delete(String id) async {
    await _saveBox.delete(id);
    if (activeCampaignId == id) {
      await _settingsBox.delete(_activeIdKey);
    }
  }

  static Future<CampaignSettings> readSettings() async {
    final raw = _settingsBox.get('settings');
    if (raw == null) return const CampaignSettings();
    try {
      return CampaignSettings.fromJson(
        (jsonDecode(raw) as Map).cast<String, dynamic>(),
      );
    } catch (_) {
      return const CampaignSettings();
    }
  }

  static Future<void> writeSettings(CampaignSettings settings) =>
      _settingsBox.put('settings', jsonEncode(settings.toJson()));

  static Future<void> saveSession(GameSessionState state) async {
    final id = activeCampaignId;
    if (id == null) return;
    final existing = load(id);
    if (existing == null) return;
    await save(existing.copyWith(
      seasonNumber: state.seasonNumber,
      completedMatches: state.completedMatches,
      phase: state.phase.name,
      lastAction: state.lastAction,
      league: state.league,
      franchiseName: state.franchiseName,
      purseCr: state.purseCr,
      difficulty: state.difficulty,
    ));
  }

  /// Restores the active campaign's auction snapshot, if one has been saved.
  /// Invalid or older snapshots are ignored so a damaged save cannot block boot.
  static AuctionState? loadActiveAuction() {
    final id = activeCampaignId;
    if (id == null) return null;
    final snapshot = load(id)?.auctionSnapshot;
    if (snapshot == null) return null;
    try {
      return AuctionState.fromJson(Map<String, dynamic>.from(snapshot));
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveAuction(AuctionState state) async {
    final id = activeCampaignId;
    if (id == null) return;
    final existing = load(id);
    if (existing == null) return;
    AuctionTeam? userTeam;
    for (final team in state.teams) {
      if (team.id == 'cpl') {
        userTeam = team;
        break;
      }
    }
    final rosterTeam = userTeam;
    await save(existing.copyWith(
      purseCr: rosterTeam?.purseCr ?? existing.purseCr,
      squadCount: rosterTeam?.squad.length ?? existing.squadCount,
      auctionSnapshot: state.toJson(),
      lastAction: state.message,
    ));
  }


  static Map<String, dynamic>? loadActiveRoster() {
    if (!isInitialized) return null;
    final id = activeCampaignId;
    final snapshot = id == null ? null : load(id)?.rosterSnapshot;
    return snapshot == null ? null : Map<String, dynamic>.from(snapshot);
  }

  static Future<void> saveActiveRoster(Map<String, dynamic> snapshot) async {
    if (!isInitialized) return;
    final id = activeCampaignId;
    if (id == null) return;
    final existing = load(id);
    if (existing == null) return;
    await save(existing.copyWith(rosterSnapshot: snapshot));
  }

  static Future<void> saveCalendar(Map<String, dynamic> snapshot) async {
    final id = activeCampaignId;
    if (id == null) return;
    final existing = load(id);
    if (existing == null) return;
    await save(existing.copyWith(calendarSnapshot: snapshot));
  }
}
