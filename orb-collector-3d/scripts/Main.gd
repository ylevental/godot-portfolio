extends Node3D

@export var orb_scene: PackedScene
var score: int = 0
var orb_count: int = 0
const MAX_ORBS = 5

func _ready():
	# Spawn initial orbs
	for i in range(MAX_ORBS):
		spawn_orb()
	$HUD/ScoreLabel.text = "Orbs: 0"

func _process(_delta):
	# Camera follows player smoothly
	if $Player:
		var target = $Player.position + Vector3(0, 5, 4)
		$Camera3D.position = $Camera3D.position.lerp(target, 0.05)
		$Camera3D.look_at($Player.position, Vector3.UP)

func spawn_orb():
	var orb = orb_scene.instantiate()
	var x = randf_range(-12.0, 12.0)
	var z = randf_range(-12.0, 12.0)
	orb.position = Vector3(x, 1.0, z)
	orb.collected.connect(_on_orb_collected)
	add_child(orb)
	orb_count += 1

func _on_orb_collected():
	score += 1
	orb_count -= 1
	$HUD/ScoreLabel.text = "Orbs: " + str(score)
	# Spawn a replacement orb after a short delay
	await get_tree().create_timer(0.5).timeout
	spawn_orb()
