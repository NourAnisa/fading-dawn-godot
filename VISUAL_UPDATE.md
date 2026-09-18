# Ashwood visual pass 2

Original procedural assets. This update is still a stylized prototype, not AAA or photorealistic.

Changes:
- Fix HUD bottom offsets and center reticle using a full-screen Control parent.
- Replace cone trees with irregular branching trees and batched canopy clusters.
- Replace flat rectangular grass with crossed tapered blades and wind shader.
- Weathered world-space procedural color variation for ground, bark and building.
- Add house upper frontage, window panels, shutters, roof seams, entrance steps and warm porch lamps.
- Add rocks and distant hills; conceal the visible perimeter walls but keep boundary collision.
- Rounded survivor silhouette, simple leg motion and shoulder camera offset.
- Preserve existing combat, supplies, objectives and synchronization addon.

Validation: all three GDScript files parse with gdtoolkit. Whitespace checks pass.
Godot runtime, shader compilation, appearance, camera collisions and frame rate have NOT been verified here.
Shader noise is color variation, not a downloaded PBR texture or scanned asset.
Rocks are decorative; trees have trunk collision. Foliage uses simplified clustered geometry.

Laptop checks:
1. Stop the game, save/commit your work, and run git pull --ff-only origin main.
2. F5: verify HP/ammunition at bottom left and crosshair at center.
3. Resize the game window: check that both remain visible.
4. Walk to the porch, enter the outpost, collect supplies, shoot enemies and reload.
5. Inspect Debugger for script/shader errors; measure frame rate on your hardware.
6. Test tree collision and shoulder camera near walls, death and restart.

Next production assets needed: licensed rigged survivor and animation set, realistic leaf meshes,
PBR ground/building materials, enemy models, sound, terrain and proper enemy navigation.
