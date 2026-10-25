import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../squad/application/initial_player_pool_provider.dart';
import '../../squad/domain/regen_factory.dart';
import '../../../theme/game_theme.dart';
import 'home_screen.dart';
import '../application/game_controller.dart';
import '../data/campaign_store.dart';

/// Cinematic boot sequence. The current project does not yet have a configured
/// Isar schema/player collection, so this prepares the first 300-player pool in
/// memory rather than pretending to persist it. Replace the in-memory seed with
/// the Isar-backed initializer when PlayerEntity and its generated schema land.
class StartupScreen extends ConsumerStatefulWidget {
  const StartupScreen({super.key});

  @override
  ConsumerState<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends ConsumerState<StartupScreen> {
  String _loadingText = 'Booting match engine...';
  double _progress = 0;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _bootGame();
  }

  Future<void> _setStage(String message, double value) async {
    if (!mounted) return;
    setState(() {
      _loadingText = message;
      _progress = value;
    });
    await Future<void>.delayed(const Duration(milliseconds: 350));
  }

  Future<void> _bootGame() async {
    try {
      await _setStage('Initializing world state...', 0.12);
      await _setStage('Scouting global player pool...', 0.35);

      // Deterministic name uniqueness is enforced by RegenFactory.
      final initialPool = RegenFactory().generateDraftClass(300);
      ref.read(initialPlayerPoolProvider.notifier).state = initialPool;
      await _setStage('Generated ${initialPool.length} prospects...', 0.62);
      await _setStage('Preparing auction systems...', 0.82);
      await _setStage('Preparing franchise headquarters...', 1);

      await Future<void>.delayed(const Duration(milliseconds: 450));
      if (!mounted) return;
      final campaignId = 'campaign-${DateTime.now().millisecondsSinceEpoch}';
      ref.read(gameControllerProvider.notifier).startCampaign(
        campaignId: campaignId,
        league: 'Indian Premier League',
        franchiseName: 'Coastal Premier Lions',
        purseCr: 120,
        difficulty: 'Normal',
      );
      // Persist a save slot so the campaign can be reloaded from the main menu.
      try {
        await CampaignStore.save(CampaignSave(
          id: campaignId,
          league: 'Indian Premier League',
          franchiseName: 'Coastal Premier Lions',
          purseCr: 120,
          difficulty: 'Normal',
          lastAction: 'New campaign created.',
        ));
      } catch (error) {
        debugPrint('Could not write campaign slot: $error');
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _failed = true;
        _loadingText = 'Unable to initialize the game. Please retry.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                    border: Border.all(
                      color: GamePalette.emerald.withValues(alpha: 0.35),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: GamePalette.emerald.withValues(alpha: 0.18),
                        blurRadius: 42,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.sports_cricket_rounded,
                    size: 76,
                    color: GamePalette.emerald,
                  ),
                )
                    .animate(onPlay: (controller) =>
                        controller.repeat(reverse: true))
                    .scaleXY(
                      begin: 0.98,
                      end: 1.05,
                      duration: 1200.ms,
                      curve: Curves.easeInOutSine,
                    ),
                const SizedBox(height: 38),
                const Text(
                  'CRICKET PREMIER LEAGUE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 3,
                  ),
                ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.25),
                const SizedBox(height: 10),
                const Text(
                  'BUILD YOUR FRANCHISE. CREATE YOUR LEGACY.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.6,
                    color: Colors.white54,
                    fontWeight: FontWeight.w700,
                  ),
                ).animate().fadeIn(delay: 250.ms),
                const SizedBox(height: 56),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(end: _progress),
                          duration: const Duration(milliseconds: 450),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, _) =>
                              LinearProgressIndicator(
                            value: value,
                            minHeight: 4,
                            backgroundColor: Colors.white10,
                            color: GamePalette.emerald,
                          ),
                        ),
                      ),
                      const SizedBox(height: 17),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) =>
                            FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.08, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        ),
                        child: Text(
                          _loadingText,
                          key: ValueKey<String>(_loadingText),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      if (_failed) ...[
                        const SizedBox(height: 18),
                        FilledButton(
                          onPressed: () {
                            setState(() {
                              _failed = false;
                              _progress = 0;
                            });
                            _bootGame();
                          },
                          child: const Text('RETRY'),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
