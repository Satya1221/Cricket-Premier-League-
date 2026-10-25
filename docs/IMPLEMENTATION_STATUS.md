# Implementation Status

## Implemented in this branch
- New Flutter app entry point with a premium dark, gold and emerald theme.
- Auction screen with player dossier, valuation display, franchise purse cards, bidding feed and auction controls.
- Auction state machine for ready, bidding, sold, unsold and completed states.
- Player and team domain models, player valuation baseline, bid increment ladder and rival decision rules.
- Guardrails for purse, squad size and overseas roster count.
- Demo data and initial domain/widget tests.
- GitHub Actions checks for formatting, analysis and tests.

## Known limitations that must be addressed next
- The roster is synthetic demo data and must be replaced with a curated, licensed, accurate player database.
- Current UI exposes manual franchise selection; rival profiles are defined in the engine but timed automated bidding has not yet been integrated into the UI.
- No persistent multi-season career/save migration yet.
- No ball-by-ball match simulation or tactical matchday experience yet.
- No 3D renderer/assets are included yet. A proper hardware test is required to select and validate a code-first 3D route.
- Build, analyzer, and automated test status must be read from GitHub Actions; never infer success merely from code being committed.
- IPL rule configuration (for example roster size and overseas caps) should be versioned per competition rather than hard-coded globally.
