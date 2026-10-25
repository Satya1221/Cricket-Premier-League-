import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:cricket_premier_league/data/local_storage_service.dart';

void main() {
  late Directory tempDirectory;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('cpl-save-test-');
    Hive.init(tempDirectory.path);
    await Hive.openBox<dynamic>(LocalStorageService.boxName);
  });

  tearDown(() async {
    await Hive.close();
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  test('session data survives save and load', () async {
    final storage = LocalStorageService();
    final session = <String, Object?>{
      'campaignId': 'test-campaign',
      'seasonNumber': 3,
      'completedMatches': 7,
      'purseCr': 42.5,
      'phase': 'season',
    };

    await storage.saveSession(session);
    final restored = storage.loadSession();

    expect(restored, isNotNull);
    expect(restored!['campaignId'], 'test-campaign');
    expect(restored['seasonNumber'], 3);
    expect(restored['completedMatches'], 7);
    expect(restored['purseCr'], 42.5);
    expect(restored['phase'], 'season');
  });

  test('invalid JSON is treated as a missing save', () async {
    final box = Hive.box<dynamic>(LocalStorageService.boxName);
    await box.put(LocalStorageService.sessionKey, '{invalid json');
    expect(LocalStorageService().loadSession(), isNull);
  });
}
