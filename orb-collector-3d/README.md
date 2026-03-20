# Orb Collector 3D

A 3D collection game built in Godot 4.2. Navigate a platform and collect floating orbs that bob and spin in the air.

<!-- Replace with an actual screenshot -->
<!-- ![Gameplay](./screenshot.png) -->

## Gameplay

- Move with **WASD** or **arrow keys**
- Walk into floating blue orbs to collect them
- New orbs spawn after a short delay to replace collected ones
- The platform keeps 5 orbs active at all times

## Architecture

```
scenes/
  Main.tscn      — Root scene: platform, lighting, camera, HUD, player, and WorldEnvironment
  Player.tscn    — CharacterBody3D with capsule mesh (unshaded green)
  Orb.tscn       — Area3D with sphere mesh (unshaded blue), bobbing and spinning

scripts/
  Main.gd        — Orb spawning, camera follow, score tracking
  Player.gd      — 3D movement with smooth rotation, gravity, platform clamping
  Orb.gd         — Sine-wave bobbing, Y-axis rotation, collection signal
```

## Key Technical Details

- **Smooth camera follow**: Camera lerps toward an offset above the player each frame and continuously `look_at()` targets the player, creating a natural third-person feel
- **Character rotation**: Player capsule smoothly rotates to face the movement direction using `lerp_angle()` on the Y axis
- **Orb animation**: Each orb has a randomized phase offset (`randf() * TAU`) so they bob out of sync, adding visual variety with no extra assets
- **Signal-based collection**: Orbs emit a `collected` signal on body contact → Main decrements the counter, increments score, and schedules a replacement spawn after 0.5s
- **Unshaded materials**: Player and orbs use `shading_mode = 0` (unshaded) so they remain bright and visible regardless of lighting angle
- **Simple gravity**: Manual gravity in `_physics_process()` with a floor check at `y = 0.7` — lightweight alternative to a full physics floor for a flat platform

## Running

Open `project.godot` in Godot 4.2+ and press F5.
