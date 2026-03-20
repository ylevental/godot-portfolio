# Dodge the Creeps

A 2D top-down survival game built in Godot 4.2. Dodge waves of randomly generated enemies for as long as you can.

<!-- Replace with an actual screenshot -->
![Gameplay](./screenshot.png)

## Gameplay

- Move with **WASD** or **arrow keys**
- Avoid the spinning enemies that spawn from all screen edges
- Survive as long as possible — your score increases every second
- Getting hit ends the game; press **Start** to retry

## Architecture

```
scenes/
  Main.tscn      — Root scene: orchestrates timers, spawning, and game flow
  Player.tscn    — Area2D player with triangle polygon and collision shape
  Enemy.tscn     — RigidBody2D enemy with randomized polygon appearance
  HUD.tscn       — CanvasLayer with score label, message, and start button

scripts/
  Main.gd        — Game loop: spawning enemies from random edges, score tracking
  Player.gd      — Movement, screen clamping, motion trail rendering
  Enemy.gd       — Random shape/color generation (octagon, diamond, square), spin
  HUD.gd         — Score display, message sequencing, start signal
  Starfield.gd   — Parallax-scrolling procedural star background
```

## Key Technical Details

- **Procedural enemy variety**: Each enemy randomly selects one of three polygon shapes, a hue in the red-orange-yellow range, and a random spin speed — all generated at runtime in `_ready()`
- **Edge spawning**: Enemies spawn outside a random screen edge with velocity directed inward, preventing predictable attack patterns
- **Player trail effect**: Custom `_draw()` renders a fading trail of circles behind the player using a ring buffer of recent positions
- **Starfield background**: 80 procedurally placed stars drift downward at varying speeds and brightnesses, re-wrapping at screen edges
- **Signal flow**: `Player.hit` → `Main.game_over()` → `HUD.show_game_over()` → `HUD.start_game` → `Main.new_game()`

## Running

Open `project.godot` in Godot 4.2+ and press F5.
