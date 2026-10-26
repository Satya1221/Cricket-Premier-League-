import 'dart:convert';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// Sound and haptics for match and auction feedback.
class GameFeel {
  GameFeel._();

  static final AudioPlayer _sfxPlayer = AudioPlayer();
  static Uint8List? _gavelBytes;

  /// Loads the small original WAV from the bundled base64 text asset.
  static Future<void> init() async {
    try {
      final encoded = await rootBundle.loadString('assets/sounds/gavel_slam.wav.b64');
      final decoded = Uint8List.fromList(base64Decode(encoded.trim()));
      _gavelBytes = decoded;
      await _sfxPlayer.setSource(BytesSource(decoded, mimeType: 'audio/wav'));
      await _sfxPlayer.setVolume(1);
    } catch (_) {
      // Sound remains optional on devices without an audio output/plugin.
      _gavelBytes = null;
    }
  }

  static void triggerBidTick() {
    HapticFeedback.selectionClick();
  }

  static Future<void> triggerGavelSlam() async {
    HapticFeedback.heavyImpact();
    final sound = _gavelBytes;
    if (sound == null) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(
        BytesSource(sound, mimeType: 'audio/wav'),
        mode: PlayerMode.lowLatency,
      );
    } catch (_) {
      // Audio failure should never interrupt gameplay.
    }
  }

  static Future<void> dispose() => _sfxPlayer.dispose();
}
