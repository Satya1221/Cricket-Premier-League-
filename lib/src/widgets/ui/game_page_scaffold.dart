import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

/// Shared screen chrome for predictable navigation, spacing and a single
/// bottom-anchored primary action. Use secondary actions for lower-priority work.
class GamePageScaffold extends StatelessWidget {
  const GamePageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions = const [],
    this.primaryAction,
    this.secondaryActions,
    this.showBack = true,
    this.reserveBottomNavigation = false,
    this.bodyPadding = const EdgeInsets.all(AppSpace.lg),
    this.backgroundColor = AppColors.background,
  });

  final String title;
  final Widget body;
  final List<Widget> actions;
  final Widget? primaryAction;
  final Widget? secondaryActions;
  final bool showBack;
  final bool reserveBottomNavigation;
  final EdgeInsets bodyPadding;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: Text(title, style: AppType.heading),
          automaticallyImplyLeading: showBack,
          backgroundColor: backgroundColor,
          foregroundColor: AppColors.textPrimary,
          actions: actions,
        ),
        body: SafeArea(
          bottom: false,
          child: Padding(
            padding: bodyPadding.copyWith(
              bottom: reserveBottomNavigation
                  ? AppSpace.huge + AppSpace.xl
                  : maxBottomPadding(bodyPadding.bottom),
            ),
            child: body,
          ),
        ),
        bottomNavigationBar: primaryAction == null
            ? null
            : SafeArea(
                minimum: const EdgeInsets.all(AppSpace.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (secondaryActions != null) ...[
                      secondaryActions!,
                      const SizedBox(height: AppSpace.sm),
                    ],
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: primaryAction!,
                    ),
                  ],
                ),
              ),
      );

  static double maxBottomPadding(double value) =>
      value < AppSpace.lg ? AppSpace.lg : value;
}
