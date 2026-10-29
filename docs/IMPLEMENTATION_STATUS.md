# Implementation Status

## Implemented in this branch
- Clean Flutter + Riverpod application entry point with a reusable dark, gold and emerald theme.
- Responsive auction screen with player dossier, valuation display, purse metrics, franchise war room, bid feed, hammer close and next-lot flow.
- Auction state machine for ready, bidding, sold, unsold and completed states.
- Player/team models, dynamic valuation baseline and bid increment ladder.
- Rival archetypes (aggressive, budget guardian, youth-first and role specialist), with role fit, aggression and manager-pressure modifiers.
- Manual rival AI round control that records bids and passes in the auction feed.
- Guardrails for purse, squad capacity, overseas roster count, closed lots and preventing a franchise from bidding against itself.
- Domain regression tests and a widget smoke test.
- GitHub Actions workflows for formatting, static analysis, unit/widget tests and debug APK generation.
- 3D integration notes defining a code-first rendering boundary, asset pipeline and device performance gates.

## Known limitations
- The roster is synthetic demo data, not official player data. Replace it with a curated dataset whose licensing and data sources are verified.
- The auction prototype currently allows manual franchise selection. The next product step is to define one human-controlled franchise and have AI control the others automatically.
- Multi-season career persistence and save migration are not implemented.
- Ball-by-ball simulation, tactical matchday management, scouting progression, youth generation, contracts and finances are not implemented.
- No 3D renderer or model assets are integrated yet. The renderer must be selected and profiled on the target Android device before calling this complete.
- APK build, analyzer and test results must be read from GitHub Actions; never infer success from commits alone.
- Competition rules (squad size, overseas limits, purse and retention rules) should be versioned per competition instead of remaining global constants.


## Integration branch: playable-core

- Auction squad balancing now targets each franchise's configured `minSquadSize` (18 by default), rather than the previous hard-coded 11-player threshold.
- Starting a season validates each auction squad against that same configured minimum and reports the affected franchise and required size.
- The legacy folders have **not** been deleted yet: active imports still depend on legacy fixture/schedule and storage adapters. Migrate those consumers before removing the old folders.
- Persistence currently uses Hive JSON snapshots, not Isar. Keep Hive as the existing storage backend during this integration pass; changing database technology is a separate migration and is not required to make campaign state authoritative.
- Local Flutter validation is unavailable in the current editing environment. CI must be used to verify analyzer, tests, and APK build before merge.
