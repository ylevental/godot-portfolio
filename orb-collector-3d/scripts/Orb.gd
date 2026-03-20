extends Area3D

signal collected

var base_y: float = 0.0
var time: float = 0.0

func _ready():
	base_y = position.y
	time = randf() * TAU

func _process(delta):
	time += delta * 2.0
	position.y = base_y + sin(time) * 0.3
	rotate_y(delta * 3.0)

func _on_body_entered(body):
	if body is CharacterBody3D:
		collected.emit()
		queue_free()
