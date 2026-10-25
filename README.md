# Cricket Premier League — Modernization

A clean, code-first rebuild of the Cricket Premier League Android management game.

## Direction
- Premium mobile-first cricket management UI with a dark, gold and emerald visual system.
- Auction prototype with bid increments, leader tracking, hammer close, sold/unsold status, purse updates, squad capacity and overseas limits.
- Roadmap for deeper rival AI, careers, match simulation, scouting, player development and 3D presentation.

## Current branch foundation
A new Flutter entry point and responsive auction prototype are in `lib/main.dart`. Demo names and ratings are fictional placeholders, not official player data. The default branch previously contained only a minimal README; this branch starts clean without changing `main`.

## Local validation in Termux/Linux
Run from the project root:

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

The remote GitHub editing tools do not execute Flutter, Dart, Android SDK or device performance tests. Do not treat an APK as build-verified until those commands pass locally.

## 3D approach
Keep management UI and simulation deterministic and testable. Evaluate code-first 3D rendering packages and assets separately on the target Android device, with a 2D fallback and explicit memory/frame-time budgets.
