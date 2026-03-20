extends Area2D

signal hit

@export var speed: float = 300.0
var screen_size: Vector2
var is_active: bool = false
var trail_points: Array[Vector2] = []
const MAX_TRAIL = 12

func _ready():
	screen_size = Vector2(480, 720)
	hide()

func _process(delta):
	if not is_active:
		return

	var velocity = Vector2.ZERO

	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		# Rotate to face movement direction
		rotation = velocity.angle() + PI / 2.0

	position += velocity * delta
	position = position.clamp(Vector2(16, 16), screen_size - Vector2(16, 16))

	# Update trail
	trail_points.push_front(position)
	if trail_points.size() > MAX_TRAIL:
		trail_points.resize(MAX_TRAIL)
	queue_redraw()

func _draw():
	if not is_active:
		return
	# Draw fading trail
	for i in range(1, trail_points.size()):
		var alpha = 1.0 - float(i) / float(MAX_TRAIL)
		var size = 4.0 * (1.0 - float(i) / float(MAX_TRAIL))
		var local_pos = trail_points[i] - position
		local_pos = local_pos.rotated(-rotation)
		draw_circle(local_pos, size, Color(0.3, 1.0, 0.5, alpha * 0.4))

func start(pos):
	position = pos
	rotation = 0
	is_active = true
	trail_points.clear()
	show()
	$CollisionShape2D.disabled = false

func die():
	is_active = false
	hide()
	$CollisionShape2D.set_deferred("disabled", true)

func _on_body_entered(_body):
	if is_active:
		die()
		hit.emit()
