# Cricket Premier League — Implementation Memory & Handoff

Last updated: 2026-10-25
Working branch: `modernization/flutter-auction-foundation`

This file is the project handoff log for future AI assistants and developers. Read it before making further changes. It records what has been added, what it actually does, and what is still incomplete. Do not describe domain-only/in-memory systems as persistent or fully integrated.

## Product direction

Flutter/Dart cricket franchise management game with a polished dark navy, gold and emerald visual style. Core gameplay includes IPL-style auctions, franchise purse/squad constraints, match delivery simulation, bowling/captaincy tactics, player development, calendar and season management.

## Implementation history

### Auction, contracts and currency
- `lib/src/features/auction/domain/player_contract.dart`: domain contract model. Auction hammer price is captured as the per-season salary; also stores base price, years remaining, overseas status and signed season. `advanceSeason()` decrements contract years.
- `lib/src/core/cricket_currency.dart`: formats values in Indian cricket currency (crores/lakhs).
- `lib/src/features/auction/domain/purse_rules.dart`: default ₹120 Cr purse, 18-player minimum, 25-player maximum, maximum 8 overseas players and configurable reserve per missing squad player.
- `lib/src/features/auction/domain/player.dart`: `AuctionPlayer.contract`, `annualSalaryCr` and `contractYearsRemaining`.
- `lib/src/features/auction/domain/auction_engine.dart`: validates bids and creates a 3-season contract at the final bid. The final bid is deducted from the auction purse when a lot is sold.
- `lib/src/features/auction/auction_screen.dart`: uses the Indian cricket currency formatter.
- Important accounting rule: the winning bid is already deducted from the auction purse. Do not deduct the same bid a second time as a separate salary charge against that same purse. Annual salary is a contract record for payroll/financial reporting.

### Match engine and bowling tactics
- `lib/src/features/match/domain/bowling_angle_engine.dart`: crease position, bowling arm/style, batter handedness, line, length, variation, field trap, and matchup modifiers.
- `lib/src/features/match/domain/delivery_resolution_engine.dart`: probabilistic delivery resolution with batting intent, bowler tactic, pitch/environment modifiers and optional tactical modifiers.
- `lib/src/features/match/matchday_screen.dart`: matchday scoreboard and delivery controls; this is a sample match, not yet a full match/innings persistence system.
- On 2026-10-25, explicit `break` statements were added to line/length/variation switch cases in `bowling_angle_engine.dart` to prevent unintended switch fall-through / compile errors.

### Previously added management systems (check source before extending)
- Academy/player-growth domain and screen/provider.
- Medical center/workload domain and screen/provider.
- Field placement editor and engine.
- Press-conference event/dialog and engine.
- Game phase/season tracker, global calendar and inbox.
- Auto-simulation and league simulation domain engines.
- These systems have previously been created in the feature folders, but many are in-memory and some are not wired into a shared season save. Do not assume database persistence or full simulator integration without implementing and verifying it.

## Known architectural facts / constraints
- Flutter/Dart with Riverpod. Current dependencies include `flutter_riverpod`, `audioplayers`, `flutter_animate`, and `google_fonts`.
- Dart SDK constraint is >=3.4.0 <4.0.0.
- Isar is NOT configured: no Isar dependency, generated schemas or build_runner setup was present at the last review. Models in this branch are plain Dart unless stated otherwise.
- Avoid introducing generated database code until a storage decision and generation workflow are implemented end-to-end.
- No build, analyzer, or tests have been run by the assistant for the latest domain additions. Verify locally before treating the branch as release-ready.
- Do not commit secrets or API tokens. Keep configuration and credentials out of source control.

## Remaining work checklist (ordered)

### P0 — correctness and integration
- [ ] Run `flutter pub get`, `dart format .`, `flutter analyze`, and `flutter test` in a real Flutter SDK environment; fix all failures. This was intentionally not run by the previous assistant.
- [ ] Make bowling tactics interactive in the matchday UI: crease, arm, style, batter stance, line, length, variation and field trap should come from state instead of a hard-coded preset.
- [ ] Give wickets a dismissal subtype (bowled, caught, LBW, stumped, run out) and apply the matching tactical multiplier only to its corresponding dismissal. The current resolver uses generic wicket outcomes and cannot claim accurate dismissal-specific simulation.
- [ ] Ensure match formats use their configured ball limits, including The Hundred, and add extras/no-balls/wides, strike rotation, over changes, bowler limits and innings/result handling.
- [ ] Add tests for auction purse constraints, overseas limits, contracts, match outcome probability bounds and format-specific ball limits.

### P1 — season lifecycle and persistence
- [ ] Add a season-advance orchestration flow: expire contracts, decrement years, release expired players, generate renewals/retirements, advance fixtures/calendar, update form/injuries and compute salary obligations.
- [ ] Choose and implement real persistence for saves (Isar or another maintained local database). Include schema/generation, migration/versioning, repository interfaces, save/load and restart recovery.
- [ ] Integrate auction, calendar, league simulation, academy, medical, field placement, press events and match results through a single season/game state or repositories rather than disconnected demo providers.
- [ ] Ensure auction salaries and purse accounting are clearly separated in UI and season reports.

### P2 — gameplay completeness
- [ ] Full squad and playing XI rules (max 4 overseas in XI, max 8 overseas in squad, minimum 18 players) enforced at selection/season start, not just auction bid time.
- [ ] AI team selection, role balance, realistic player skill distributions and multi-season progression.
- [ ] Complete scorecards, commentary events, match results, points table, playoffs/final, season awards and save/load.
- [ ] Wire the screens to the main navigation and replace demo teams/players with the actual roster data.

## Working rules for future AI agents
1. Work on `modernization/flutter-auction-foundation` unless the user explicitly chooses another branch.
2. Read this file and relevant source files before editing.
3. Implement changes directly; the user prefers minimal narration and dislikes repeated inspect/check loops.
4. Do not claim a feature is integrated, persistent or tested unless the code and verification support that claim.
5. Keep changes modular, use existing Riverpod/theme conventions, and do not add a dependency without updating `pubspec.yaml` and the project setup.
6. After each meaningful batch, update this file with commit links/paths and mark checklist items only when genuinely complete.
