extends CharacterBody3D

@export var speed: float = 8.0
@export var rotation_speed: float = 10.0

var move_direction: Vector3 = Vector3.ZERO

func _physics_process(delta):
	var input_dir = Vector3.ZERO

	if Input.is_action_pressed("move_forward"):
		input_dir.z -= 1
	if Input.is_action_pressed("move_back"):
		input_dir.z += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1

	if input_dir.length() > 0:
		input_dir = input_dir.normalized()
		# Smoothly rotate to face movement direction
		var target_angle = atan2(input_dir.x, input_dir.z)
		rotation.y = lerp_angle(rotation.y, target_angle, rotation_speed * delta)

	velocity.x = input_dir.x * speed
	velocity.z = input_dir.z * speed
	# Simple gravity
	velocity.y -= 20.0 * delta
	if position.y < 0.7:
		velocity.y = max(velocity.y, 0.0)
		position.y = 0.7

	move_and_slide()

	# Keep player on the platform
	position.x = clamp(position.x, -14.0, 14.0)
	position.z = clamp(position.z, -14.0, 14.0)
