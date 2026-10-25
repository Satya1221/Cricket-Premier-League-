import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/game_theme.dart';

/// Lightweight code-rendered glass button; no image assets required.
class PremiumGlassButton extends StatelessWidget {
  const PremiumGlassButton({
    required this.text,
    required this.onPressed,
    this.icon,
    this.height = 58,
    this.accent = GamePalette.gold,
    this.enabled = true,
    super.key,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  final Color accent;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final active = enabled && onPressed != null;
    return Semantics(
      button: true,
      enabled: active,
      label: text,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 9, sigmaY: 9),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: active ? onPressed : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: height,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accent.withValues(alpha: active ? 0.20 : 0.06),
                      Colors.white.withValues(alpha: active ? 0.07 : 0.025),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: accent.withValues(alpha: active ? 0.58 : 0.18),
                    width: 1.2,
                  ),
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.10),
                            blurRadius: 18,
                            offset: const Offset(0, 5),
                          ),
                        ]
                      : const [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: active ? accent : Colors.white38),
                      const SizedBox(width: 10),
                    ],
                    Flexible(
                      child: Text(
                        text,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: active ? Colors.white : Colors.white38,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
