import 'package:flutter/material.dart';

import '../../../theme/game_theme.dart';
import 'startup_screen.dart';

/// First entry point. Keep campaign setup separate from the active franchise
/// dashboard so launching the app does not silently start a new career.
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  void _startNewGame(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const StartupScreen()),
    );
  }

  void _showUnavailable(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature is not available yet. Campaign save/load is not connected.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 190,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1C4A42), Color(0xFF111827)],
                      ),
                      border: Border.all(color: GamePalette.gold.withValues(alpha: .4)),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sports_cricket_rounded, size: 64, color: GamePalette.gold),
                        SizedBox(height: 18),
                        Text(
                          'CRICKET PREMIER LEAGUE',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 19, letterSpacing: 2, fontWeight: FontWeight.w900),
                        ),
                        SizedBox(height: 7),
                        Text(
                          'BUILD YOUR FRANCHISE. CREATE YOUR LEGACY.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 9, letterSpacing: 1.2, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 34),
                  FilledButton.icon(
                    onPressed: () => _startNewGame(context),
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    label: const Text('NEW CAMPAIGN'),
                    style: FilledButton.styleFrom(
                      backgroundColor: GamePalette.gold,
                      foregroundColor: const Color(0xFF101820),
                      minimumSize: const Size.fromHeight(58),
                      textStyle: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: .8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _showUnavailable(context, 'Load Game'),
                    icon: const Icon(Icons.folder_open_rounded),
                    label: const Text('LOAD GAME'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: GamePalette.line),
                      minimumSize: const Size.fromHeight(54),
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _showUnavailable(context, 'Settings'),
                    icon: const Icon(Icons.tune_rounded),
                    label: const Text('SETTINGS'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: GamePalette.line),
                      minimumSize: const Size.fromHeight(54),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'CAREER MODE • FRANCHISE MANAGEMENT • MATCHDAY',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: GamePalette.muted, fontSize: 9, letterSpacing: 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
