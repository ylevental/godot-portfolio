extends Node2D
## Builds the level from an ASCII string map.
## Uses ColorRect nodes for visuals and StaticBody2D nodes for collision
## (more reliable than programmatic TileSet physics at runtime).
##
## Legend:
##   # = solid ground
##   - = one-way platform
##   C = coin spawn point
##   P = player spawn point
##   . = empty

const TILE_SIZE: int = 32

# ASCII level layout — easy to read and edit
const LEVEL_MAP: Array[String] = [
	"........................................",
	"....C...............C...................",
	"...###.............###..................",
	"........................................",
	".C..............C.............C.........",
	"###...........---..........###..........",
	"........................................",
	".......C...........C.......C............",
	"......###.........---....####...........",
	"........................................",
	"..C...........C...........C.............",
	"..###........---..........###...........",
	"........................................",
	"..P.....................................",
	"########################################",
]

var coins_collected: int = 0
var coins_total: int = 0

func _ready() -> void:
	_build_level()
	_spawn_coins()
	_spawn_player()

func _build_level() -> void:
	for row in range(LEVEL_MAP.size()):
		for col in range(LEVEL_MAP[row].length()):
			var ch = LEVEL_MAP[row][col]
			var tile_pos = Vector2(
				col * TILE_SIZE + TILE_SIZE / 2.0,
				row * TILE_SIZE + TILE_SIZE / 2.0
			)
			match ch:
				"#":
					_create_solid_tile(tile_pos)
				"-":
					_create_platform_tile(tile_pos)

func _create_solid_tile(pos: Vector2) -> void:
	# Visual — dark border with lighter fill
	var border := ColorRect.new()
	border.size = Vector2(TILE_SIZE, TILE_SIZE)
	border.position = pos - Vector2(TILE_SIZE / 2.0, TILE_SIZE / 2.0)
	border.color = Color(0.25, 0.18, 0.12)
	add_child(border)
	var inner := ColorRect.new()
	inner.size = Vector2(TILE_SIZE - 2, TILE_SIZE - 2)
	inner.position = border.position + Vector2(1, 1)
	inner.color = Color(0.4, 0.3, 0.2)
	add_child(inner)

	# Collision — StaticBody2D with RectangleShape2D
	var body := StaticBody2D.new()
	body.position = pos
	body.collision_layer = 1
	var shape := CollisionShape2D.new()
	var rect_shape := RectangleShape2D.new()
	rect_shape.size = Vector2(TILE_SIZE, TILE_SIZE)
	shape.shape = rect_shape
	body.add_child(shape)
	add_child(body)

func _create_platform_tile(pos: Vector2) -> void:
	# Visual — thin green bar at top of tile cell
	var top_left = pos - Vector2(TILE_SIZE / 2.0, TILE_SIZE / 2.0)
	var border := ColorRect.new()
	border.size = Vector2(TILE_SIZE, 8)
	border.position = top_left
	border.color = Color(0.35, 0.5, 0.35)
	add_child(border)
	var inner := ColorRect.new()
	inner.size = Vector2(TILE_SIZE - 2, 6)
	inner.position = top_left + Vector2(1, 1)
	inner.color = Color(0.5, 0.7, 0.5)
	add_child(inner)

	# Collision — one-way platform at top of tile cell
	var body := StaticBody2D.new()
	body.position = Vector2(pos.x, top_left.y + 4)
	body.collision_layer = 1
	var shape := CollisionShape2D.new()
	var rect_shape := RectangleShape2D.new()
	rect_shape.size = Vector2(TILE_SIZE, 8)
	shape.shape = rect_shape
	shape.one_way_collision = true
	body.add_child(shape)
	add_child(body)

func _spawn_coins() -> void:
	var coin_scene: PackedScene = load("res://scenes/Coin.tscn")
	for row in range(LEVEL_MAP.size()):
		for col in range(LEVEL_MAP[row].length()):
			if LEVEL_MAP[row][col] == "C":
				var coin = coin_scene.instantiate()
				coin.position = Vector2(
					col * TILE_SIZE + TILE_SIZE / 2.0,
					row * TILE_SIZE + TILE_SIZE / 2.0
				)
				coin.collected.connect(_on_coin_collected)
				add_child(coin)
				coins_total += 1
	$HUD/CoinLabel.text = "Coins: 0 / " + str(coins_total)

func _spawn_player() -> void:
	for row in range(LEVEL_MAP.size() - 1, -1, -1):
		for col in range(LEVEL_MAP[row].length()):
			if LEVEL_MAP[row][col] == "P":
				$Player.position = Vector2(
					col * TILE_SIZE + TILE_SIZE / 2.0,
					row * TILE_SIZE
				)
				return
	# Fallback: spawn above the first ground tile
	$Player.position = Vector2(80, TILE_SIZE * 13)

func _process(_delta: float) -> void:
	if $Player and $Camera2D:
		$Camera2D.position = $Camera2D.position.lerp($Player.position, 0.1)

func _on_coin_collected() -> void:
	coins_collected += 1
	$HUD/CoinLabel.text = "Coins: " + str(coins_collected) + " / " + str(coins_total)
	if coins_collected >= coins_total:
		$HUD/CoinLabel.text += "  — All collected!"
