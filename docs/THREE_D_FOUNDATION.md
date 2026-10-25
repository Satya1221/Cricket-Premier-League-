# Code-first 3D foundation

## Rendering strategy

Keep the management game Flutter-native and isolate 3D rendering behind a small presentation boundary. This lets the app remain usable on devices where a 3D renderer is unsupported or too expensive.

### Proposed scene layers

1. **Stadium shell** — low-poly stands, pitch, floodlights and a rotating camera orbit.
2. **Player presentation** — licensed or original generic player silhouettes first; detailed rigs only after device profiling.
3. **Atmosphere** — time-of-day tint, restrained particles, crowd loops and UI-safe transitions.
4. **Flutter overlay** — auction controls, cards, analytics, squad and navigation remain accessible Flutter widgets.
5. **Fallback** — a static stadium artwork/gradient when the 3D surface is unavailable, paused or under memory pressure.

## Integration gate

Do not lock the project to a 3D package based only on a package name. Before adopting a renderer, verify current maintenance, Android compatibility, supported glTF features, shader behavior, license, and performance on the target phone. Build a disposable spike with one stadium mesh, one camera, one light and one animation before integrating it into the main application.

## Performance budgets

- Target 60 fps on capable hardware; gracefully reduce effects on weaker hardware.
- Avoid allocating meshes/materials in frame callbacks.
- Reuse scene objects and textures; cap texture dimensions and total resident assets.
- Pause rendering while the app is backgrounded.
- Keep auction and match simulation deterministic and independent of rendering frame rate.
- Track frame time, memory, shader compilation stutter and app resume behavior on-device.

## Current status

This document describes the integration boundary and acceptance criteria. It does not claim that a 3D scene or asset pipeline has already been implemented.
