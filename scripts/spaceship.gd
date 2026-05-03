extends CharacterBody3D

@export var thrust_force      : float = 20.0
@export var max_speed         : float = 40.0
@export var roll_speed        : float = 1.5
@export var mouse_sensitivity : float = 0.002

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# All rotations in local space — roll can't corrupt these
		rotate_object_local(Vector3.UP,    -event.relative.x * mouse_sensitivity)
		rotate_object_local(Vector3.RIGHT,  event.relative.y * mouse_sensitivity)

	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta: float) -> void:
	_apply_rotation(delta)
	_apply_thrust(delta)
	move_and_slide()

func _apply_rotation(delta: float) -> void:
	var roll_input := Input.get_axis("roll_right", "roll_left")
	rotate_object_local(Vector3.FORWARD, roll_input * roll_speed * delta)

var _engines_started : bool = false

func _apply_thrust(delta: float) -> void:
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

	move_and_slide()
