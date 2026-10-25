# Cricket Premier League — Modernization

A clean, code-first rebuild of the Cricket Premier League Android management game. The target is a premium Flutter management experience with a deterministic cricket simulation and an isolated, device-profiled code-first 3D presentation layer.

## Current foundation

- Flutter + Riverpod app entry point and shared dark / gold / emerald theme.
- Responsive auction screen with player scouting details, purse metrics, franchise war room, live bid feed and sold/unsold controls.
- Deterministic player valuation and bid-increment ladder.
- Purse, squad-size and overseas-player constraints.
- Prevents a franchise from bidding against itself.
- Rival strategy valuation that accounts for archetype, aggression, role fit and manager pressure.
- Regression tests for auction state transitions, purse settlement, squad limits and rival bidding.
- GitHub Actions workflow for formatting, static analysis and tests.

Demo names and ratings are fictional placeholders, not official player data.

## Architecture

- `lib/src/features/auction/domain`: pure auction rules and state.
- `lib/src/features/auction/application`: Riverpod controller.
- `lib/src/features/auction/data`: demo data.
- `lib/src/features/auction`: Flutter presentation.
- `lib/src/theme`: reusable visual tokens.
- `docs/THREE_D_FOUNDATION.md`: 3D rendering boundary, performance budgets and integration gate.
- `docs/FEATURE_ROADMAP.md`: staged feature plan.

## Local validation

Run from the project root:

```bash
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter build apk --debug
```

The connected GitHub editing tools can commit source, but do not execute Flutter, Dart, Android SDK or device performance tests. Do not treat the APK as build-verified until these commands pass in a Flutter-enabled environment.

## 3D strategy

Keep management UI and simulation deterministic and testable. Evaluate current code-first rendering packages and assets separately on the target Android device. Require Android compatibility, acceptable licensing, a 2D fallback and measured memory/frame-time budgets before adopting a 3D package.
