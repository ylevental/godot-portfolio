extends Area2D
## A collectible coin that bobs up and down and spins.

signal collected

var base_y: float = 0.0
var time: float = 0.0

func _ready() -> void:
	base_y = position.y
	time = randf() * TAU  # offset so coins bob out of sync
	$Polygon2D.color = Color(1.0, 0.85, 0.1)

func _process(delta: float) -> void:
	time += delta * 3.0
	position.y = base_y + sin(time) * 4.0
	$Polygon2D.rotation += delta * 4.0

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		collected.emit()
		queue_free()
