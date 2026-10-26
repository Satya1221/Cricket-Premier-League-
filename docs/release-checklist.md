# Pre-release phone checklist

Run this checklist on a real Android phone after the CI build succeeds. Automated tests do not replace interaction checks.

- [ ] Fresh install and first launch: the first screen explains what to do, rather than showing empty zero-filled stats.
- [ ] Review the player pool: every name is plausible, each player has a stable unique ID, and ratings are within the documented range.
- [ ] Read every label aloud: abbreviations expand into understandable wording; role enums are never shown as raw code identifiers.
- [ ] Identify the primary action on every screen without searching through multiple equally prominent filled buttons.
- [ ] Scroll every list to the very end: no content is hidden behind a bottom action or system navigation bar.
- [ ] Check the shortest supported screen height and a wider layout for clipping or horizontal overflow.
- [ ] Tap every chip, icon, and action: each control either performs its action or explains how to continue.
- [ ] Confirm that no demo-only label, placeholder team, debug instruction, or unsupported-action message is visible.
- [ ] Check money formatting across the auction and franchise economy: rupees use Indian digit grouping, and the auction purse remains distinct from operating funds.
- [ ] Confirm semantic colours are consistent: amber means action/selection, green means positive/available, red means negative/risk, and currency is not coloured amber by default.
- [ ] Save a career after a meaningful action, force-stop the app, reopen it, load that save, and verify the auction, roster, playing XI, fixtures, standings, and season number still match.
- [ ] Complete at least one fixture, inspect the scoreline and standings, then finish a season and verify the next season is clean while the previous season's records remain archived.
- [ ] Confirm the gavel sound and haptic fallback behave safely with device audio both enabled and muted.
- [ ] Install the release APK for the target CPU ABI and verify first launch, auction, match, finance, inbox, medical centre, save/reload, and off-season transition.

## CI evidence

The Flutter checks workflow runs static analysis, unit/widget tests, a debug APK build, and an obfuscated split-per-ABI release build. Release APKs and matching Dart obfuscation symbols are separate artifacts. Keep the symbols archived for diagnosing release crashes.
