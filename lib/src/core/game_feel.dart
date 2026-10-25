import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// Small, optional sound-and-haptics layer for auction feedback.
class GameFeel {
  GameFeel._();

  static final AudioPlayer _sfxPlayer = AudioPlayer();
  static bool _gavelAssetAvailable = false;

  /// Call once during startup. Add assets/sounds/gavel_slam.mp3 to enable audio.
  static Future<void> init() async {
    try {
      await _sfxPlayer.setSource(AssetSource('sounds/gavel_slam.mp3'));
      await _sfxPlayer.setVolume(1);
      _gavelAssetAvailable = true;
    } catch (_) {
      // Haptics still work when the optional sound asset has not been added.
      _gavelAssetAvailable = false;
    }
  }

  static void triggerBidTick() {
    HapticFeedback.selectionClick();
  }

  static Future<void> triggerGavelSlam() async {
    HapticFeedback.heavyImpact();
    if (!_gavelAssetAvailable) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(
        AssetSource('sounds/gavel_slam.mp3'),
        mode: PlayerMode.lowLatency,
      );
    } catch (_) {
      // Audio failure should never interrupt auction gameplay.
    }
  }

  static Future<void> dispose() => _sfxPlayer.dispose();
}
