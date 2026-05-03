extends CharacterBody3D

@export var thrust_force      : float = 2.0
@export var max_speed         : float = 40.0
@export var roll_speed        : float = 1.5
@export var turn_speed        : float = 1.5        # softcore A/D yaw speed
@export var mouse_sensitivity : float = 0.002
@export var velocity_redirect : float = 2.0        # how fast old velocity bleeds into new direction (softcore)

var _engines_started : bool = false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_object_local(Vector3.UP,   -event.relative.x * mouse_sensitivity)
		rotate_object_local(Vector3.RIGHT, event.relative.y * mouse_sensitivity)

	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta: float) -> void:
	_apply_rotation(delta)

	if GameManager.movement_mode == GameManager.MovementMode.SOFTCORE:
		_apply_thrust_softcore(delta)
	else:
		_apply_thrust_realistic(delta)

	move_and_slide()

func _apply_rotation(delta: float) -> void:
	# Roll — Q/E always
	var roll_input := Input.get_axis("roll_right", "roll_left")
	rotate_object_local(Vector3.FORWARD, roll_input * roll_speed * delta)

	# Softcore: A/D yaw the ship instead of strafing
	if GameManager.movement_mode == GameManager.MovementMode.SOFTCORE:
		var yaw_input := Input.get_axis("move_right", "move_left")
		rotate_object_local(Vector3.UP, yaw_input * turn_speed * delta)

func _apply_thrust_softcore(delta: float) -> void:
	var forward_input := Input.get_axis("move_back", "move_forward")

	if forward_input != 0.0:
		_engines_started = true

		# Target velocity is always where the nose points
		var target_velocity : Vector3 = transform.basis.z * max_speed * sign(forward_input)

		# Blend current velocity toward target — this bleeds out old sideways/stale velocity
		# velocity_redirect controls how aggressively old momentum is shed
		velocity = velocity.move_toward(target_velocity, thrust_force * velocity_redirect * delta)

	# Passive speed cap — never exceed max
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed

func _apply_thrust_realistic(delta: float) -> void:
	var direction := Vector3.ZERO

	direction -= transform.basis.z * Input.get_axis("move_forward", "move_back")
	direction += transform.basis.x * Input.get_axis("move_left", "move_right")
	direction += transform.basis.y * Input.get_axis("move_down", "move_up")

	if direction != Vector3.ZERO:
		_engines_started = true
		velocity += direction.normalized() * thrust_force * delta

	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed
	elif _engines_started and velocity.length() < max_speed and direction == Vector3.ZERO:
		velocity = velocity.move_toward(velocity.normalized() * max_speed, thrust_force * delta * 0.3)
