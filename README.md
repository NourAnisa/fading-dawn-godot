# Fading Dawn (Godot)

Playable third-person survival prototype built with Godot Engine 4.
Original procedural assets; inspired by forest-survival atmosphere, not a copy of Once Human assets.
This is NOT an AAA production or a finished open-world game.

## Getting Started
1. Open Godot Engine 4.x
2. Click **Import** and select the `project.godot` file in this directory
3. Click **Import & Edit**
4. Press F5. The world is generated at runtime, so the editor scene is minimal.

## Ashwood prototype
- Sunset sky, distance fog, shadows, pine forest, batched grass and a derelict outpost.
- Third-person movement, sprint, jump, spring-arm camera and right-click zoom.
- Raycast shooting, 24-round magazine, reload, three hostile sentinels.
- Recover three glowing supply crates with E and defeat the three sentinels.
- HP, ammunition, mission counters, death and Enter-to-restart.
- Unlimited reserve ammunition. No save system, multiplayer, audio or realistic character animation yet.
- Block-model survivor and enemies are placeholders, not realistic production assets.

## Controls
WASD move; Shift sprint; Space jump; mouse look; left click shoot;
right click zoom; R reload; E collect a nearby crate; Esc release/capture cursor.
Enter restarts after death. F8 stops the game in the editor.

## Updating your local project
Save your own work and commit local changes first, then run `git pull --ff-only origin main`
from the project folder. Stop if Git reports a conflict; do not use reset --hard.

## Validation status
Source reviewed and Git whitespace checked. No Godot executable was available in the authoring
environment, so runtime, rendering and frame rate remain UNVERIFIED on the target laptop.
Test F5, movement/collision, camera against walls, shooting/reload, collecting all crates,
enemy damage, death/restart, and both completed objective counters. Report debugger errors.

## Next production pass
Replace placeholders with licensed rigged characters, animation and PBR environment assets;
add terrain variation, audio, enemy navigation, save/load, LOD and hardware-based profiling.
