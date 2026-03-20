extends CharacterBody2D
## Player controller with an explicit finite state machine.
##
## States: IDLE, RUN, JUMP, FALL, WALL_SLIDE
## Transitions are handled in _update_state() each physics frame.

signal coin_collected

# --------------- tuning constants ---------------
@export var run_speed: float = 200.0
@export var jump_force: float = -480.0
@export var gravity: float = 900.0
@export var wall_slide_gravity: float = 120.0
@export var wall_jump_force: Vector2 = Vector2(280.0, -440.0)
@export var coyote_time: float = 0.08
@export var jump_buffer_time: float = 0.1

# --------------- state enum ---------------
enum State { IDLE, RUN, JUMP, FALL, WALL_SLIDE }
var current_state: State = State.IDLE
var previous_state: State = State.IDLE

# --------------- internal timers ---------------
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var facing: int = 1  # 1 = right, -1 = left

# --------------- cosmetic ---------------
var squash_stretch: Vector2 = Vector2.ONE
var target_squash: Vector2 = Vector2.ONE
const SQUASH_LERP = 12.0
var spawn_position: Vector2 = Vector2.ZERO
const DEATH_Y: float = 600.0  # respawn if falling below this

func _ready() -> void:
	$Polygon2D.color = Color(0.2, 0.85, 0.4)
	spawn_position = position

func _physics_process(delta: float) -> void:
	_update_timers(delta)
	_update_state(delta)
	_apply_movement(delta)
	move_and_slide()
	_update_visuals(delta)
	# Respawn if fallen off the level
	if position.y > DEATH_Y:
		respawn()

func respawn() -> void:
	position = spawn_position
	velocity = Vector2.ZERO
	current_state = State.FALL
	coyote_timer = 0.0
	jump_buffer_timer = 0.0

# ========== STATE MACHINE ==========

func _update_state(delta: float) -> void:
	previous_state = current_state

	match current_state:
		State.IDLE:
			_state_idle(delta)
		State.RUN:
			_state_run(delta)
		State.JUMP:
			_state_jump(delta)
		State.FALL:
			_state_fall(delta)
		State.WALL_SLIDE:
			_state_wall_slide(delta)

func _transition_to(new_state: State) -> void:
	if new_state == current_state:
		return
	# Exit actions
	match current_state:
		State.JUMP:
			pass
		State.WALL_SLIDE:
			pass
	# Enter actions
	match new_state:
		State.JUMP:
			_do_jump()
		State.WALL_SLIDE:
			velocity.y = 0.0
	previous_state = current_state
	current_state = new_state

# ========== INDIVIDUAL STATES ==========

func _state_idle(_delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, run_speed * 0.3)
	target_squash = Vector2.ONE

	if not is_on_floor():
		_transition_to(State.FALL)
	elif _wants_jump():
		_transition_to(State.JUMP)
	elif _get_input_dir() != 0:
		_transition_to(State.RUN)

func _state_run(_delta: float) -> void:
	var dir = _get_input_dir()
	velocity.x = dir * run_speed
	if dir != 0:
		facing = dir
	target_squash = Vector2(0.9, 1.05)

	if not is_on_floor():
		_transition_to(State.FALL)
	elif _wants_jump():
		_transition_to(State.JUMP)
	elif dir == 0:
		_transition_to(State.IDLE)

func _state_jump(_delta: float) -> void:
	var dir = _get_input_dir()
	velocity.x = dir * run_speed if dir != 0 else move_toward(velocity.x, 0.0, run_speed * 0.1)
	if dir != 0:
		facing = dir

	# Variable-height jump: cut upward velocity on release
	if not Input.is_action_pressed("jump") and velocity.y < 0:
		velocity.y *= 0.5

	if velocity.y >= 0:
		_transition_to(State.FALL)

func _state_fall(_delta: float) -> void:
	var dir = _get_input_dir()
	velocity.x = dir * run_speed if dir != 0 else move_toward(velocity.x, 0.0, run_speed * 0.1)
	if dir != 0:
		facing = dir
	target_squash = Vector2(0.85, 1.15)

	if is_on_floor():
		target_squash = Vector2(1.2, 0.8)  # land squash
		if dir != 0:
			_transition_to(State.RUN)
		else:
			_transition_to(State.IDLE)
	elif _is_on_wall_and_holding():
		_transition_to(State.WALL_SLIDE)
	elif _wants_jump() and coyote_timer > 0.0:
		_transition_to(State.JUMP)

func _state_wall_slide(_delta: float) -> void:
	target_squash = Vector2(1.1, 0.95)

	if is_on_floor():
		_transition_to(State.IDLE)
	elif not is_on_wall_only() and not is_on_wall():
		_transition_to(State.FALL)
	elif _wants_jump():
		# Wall jump: push away from wall
		var wall_normal = get_wall_normal()
		velocity.x = wall_normal.x * wall_jump_force.x
		velocity.y = wall_jump_force.y
		facing = int(sign(wall_normal.x))
		current_state = State.JUMP  # direct set to avoid _do_jump()
		target_squash = Vector2(0.75, 1.25)
	elif _get_input_dir() == 0 or not _is_on_wall_and_holding():
		_transition_to(State.FALL)

# ========== HELPERS ==========

func _apply_movement(delta: float) -> void:
	if current_state == State.WALL_SLIDE:
		velocity.y += wall_slide_gravity * delta
		velocity.y = min(velocity.y, wall_slide_gravity)
	else:
		velocity.y += gravity * delta

func _do_jump() -> void:
	velocity.y = jump_force
	coyote_timer = 0.0
	jump_buffer_timer = 0.0
	target_squash = Vector2(0.75, 1.25)

func _update_timers(delta: float) -> void:
	# Coyote time: brief grace period after leaving a ledge
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta

	# Jump buffer: register jump input slightly before landing
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer -= delta

func _wants_jump() -> bool:
	return jump_buffer_timer > 0.0

func _get_input_dir() -> int:
	return int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))

func _is_on_wall_and_holding() -> bool:
	if not (is_on_wall_only() or is_on_wall()):
		return false
	var wall_normal = get_wall_normal()
	# Player must be pressing toward the wall
	var dir = _get_input_dir()
	return (dir != 0 and sign(dir) != sign(wall_normal.x))

# ========== VISUALS ==========

func _update_visuals(delta: float) -> void:
	squash_stretch = squash_stretch.lerp(target_squash, SQUASH_LERP * delta)
	$Polygon2D.scale = squash_stretch
	$Polygon2D.scale.x *= facing
	# State label for debug/demo
	$StateLabel.text = State.keys()[current_state]

func get_state_name() -> String:
	return State.keys()[current_state]
