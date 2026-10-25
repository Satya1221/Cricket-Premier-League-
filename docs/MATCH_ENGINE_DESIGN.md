# Match Engine — first implementation

## Implemented mechanics
- Green pitch opening seam/swing boost, overcast swing and aging-ball swing decline.
- Late reverse-swing window on an abrasive pitch.
- Dusty-pitch wear and spin effectiveness; night dew reduces spin control.
- Fast-bowler stamina drain and consecutive-over fatigue penalty.
- Batter concentration accumulation, eye-in benefit and low-concentration slog risk.
- Left-arm orthodox matchup modifier based on batter handedness.
- Field presets and a basic adjustment after repeated cover boundaries.
- Seeded ball outcomes, concise commentary and highlight metadata for the 3D director.

## Architecture
The resolver is pure Dart, independent of widgets, frame rate and renderer. Replaying the same input with the same seed reproduces the result. `BallOutcome.directorShouldShow3D` signals highlight-worthy events; neutral balls need only update 2D commentary and match state.

This is a first gameplay model, not statistically validated real-world cricket data. Balance values should be tuned against simulation batches before competitive use. The caller must advance over/innings state and mark completed overs correctly.
