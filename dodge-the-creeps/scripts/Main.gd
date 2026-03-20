extends Node

@export var enemy_scene: PackedScene
var score: int = 0
var screen_size: Vector2

func _ready():
	screen_size = Vector2(480, 720)

func game_over():
	$ScoreTimer.stop()
	$EnemyTimer.stop()
	$HUD.show_game_over()

func new_game():
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("Get Ready!")
	get_tree().call_group("enemies", "queue_free")

func _on_score_timer_timeout():
	score += 1
	$HUD.update_score(score)

func _on_start_timer_timeout():
	$EnemyTimer.start()
	$ScoreTimer.start()

func _on_enemy_timer_timeout():
	var enemy = enemy_scene.instantiate()

	# Pick a random edge to spawn from
	var spawn_pos = Vector2.ZERO
	var direction: float = 0.0
	var edge = randi() % 4

	match edge:
		0:  # Top
			spawn_pos = Vector2(randf() * screen_size.x, -40)
			direction = randf_range(PI / 4.0, 3.0 * PI / 4.0)
		1:  # Bottom
			spawn_pos = Vector2(randf() * screen_size.x, screen_size.y + 40)
			direction = randf_range(-3.0 * PI / 4.0, -PI / 4.0)
		2:  # Left
			spawn_pos = Vector2(-40, randf() * screen_size.y)
			direction = randf_range(-PI / 4.0, PI / 4.0)
		3:  # Right
			spawn_pos = Vector2(screen_size.x + 40, randf() * screen_size.y)
			direction = randf_range(3.0 * PI / 4.0, 5.0 * PI / 4.0)

	enemy.position = spawn_pos
	enemy.rotation = direction

	var speed = randf_range(150.0, 250.0)
	enemy.linear_velocity = Vector2(cos(direction), sin(direction)) * speed

	add_child(enemy)
	enemy.add_to_group("enemies")
