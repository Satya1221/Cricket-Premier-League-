# Cricket Premier League — Feature Roadmap

This is an implementation roadmap, not a claim that every listed feature exists.

## Auction foundation
- Premium dark visual language and responsive auction screen.
- Demo player and franchise models.
- Increment ladder, current bid, leader marker, hammer close and next-lot flow.
- Purse, squad capacity and overseas roster constraints.
- Auction event feed and resettable demo career.
- Next: extract engine into pure domain layer, rival strategy AI, stronger tests and persistence.

## Management depth
- Player skill dimensions, role-specific ratings and career development.
- Form, fatigue, injury, morale and workload.
- Coaches and support staff.
- Youth academy and procedural player generation.
- Scouting uncertainty and regional assignments.
- Contracts, salary costs, sponsorships, ticket pricing and board objectives.
- Trade window, retention rules and multi-year auctions.
- Competition calendar, standings and season progression.

## Match engine
- Ball-by-ball simulation using player, tactic and environment inputs.
- Pitch and weather modifiers with bounded probability math.
- Batting intent, bowling plan, field settings and matchup strengths.
- Context-aware commentary and scorecard timeline.
- Wagon wheel, pitch map and replay metadata.

## 3D presentation
- Evaluate code-first rendering packages on the target Android device.
- Reusable low-poly stadium and generic player assets.
- Device quality settings and 2D fallback.
- Crowd ambience, intro scenes and camera presets.
- Frame-time and memory budgets for mid-range Android devices.

## 500+ feature target
Track 500+ independently testable features by subsystem. Do not count placeholders, repeated cosmetic variants or disconnected toggles as complete. Every feature needs acceptance criteria and a performance impact note.
