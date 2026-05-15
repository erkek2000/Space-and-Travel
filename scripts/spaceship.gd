extends CharacterBody3D

@export var thrust_force      : float = 2.0
@export var max_speed         : float = 20.0
@export var roll_speed        : float = 1.5
@export var turn_speed        : float = 1.5
@export var velocity_redirect : float = 2.0

@onready var down_gas      : Node3D = %DownGas
@onready var up_gas        : Node3D = %UpGas
@onready var left_gas      : Node3D = %LeftGas
@onready var right_gas     : Node3D = %RightGas
@onready var roll_left_gas : Node3D = %RollLeftGas
@onready var roll_right_gas: Node3D = %RollRightGas

var _engines_started : bool = false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta: float) -> void:
	_apply_rotation(delta)
	_update_thrusters()

	if GameManager.movement_mode == GameManager.MovementMode.SOFTCORE:
		_apply_thrust_softcore(delta)
	else:
		_apply_thrust_realistic(delta)

	move_and_slide()

func _apply_rotation(delta: float) -> void:
	# Q/E roll always
	var roll_input := Input.get_axis("roll_right", "roll_left")
	rotate_object_local(Vector3.FORWARD, roll_input * roll_speed * delta)

	# A/D yaw the ship left/right in both modes
	var yaw_input := Input.get_axis("move_right", "move_left")
	rotate_object_local(Vector3.UP, yaw_input * turn_speed * delta)

	# W/S pitch the ship up/down in both modes
	var pitch_input := Input.get_axis("move_forward", "move_back")
	rotate_object_local(Vector3.RIGHT, pitch_input * turn_speed * delta)

func _update_thrusters() -> void:
	var thrusting := Input.is_action_pressed("thrust")
	var roll      := Input.get_axis("roll_left", "roll_right")
	var pitch     := Input.get_axis("move_forward", "move_back")
	var yaw       := Input.get_axis("move_left", "move_right")

	# Forward thruster fires on thrust key
	down_gas.visible       = thrusting
	# Retro thruster — not in your node list but ready if you add one

	# Roll gas
	roll_left_gas.visible  = roll < 0.0
	roll_right_gas.visible = roll > 0.0

	# Pitch gas (W/S now rotates, so up/down gas fires on pitch)
	up_gas.visible    = pitch < 0.0
	down_gas.visible  = pitch > 0.0 or thrusting

	# Yaw gas (A/D rotates)
	left_gas.visible  = yaw < 0.0
	right_gas.visible = yaw > 0.0

func _apply_thrust_softcore(delta: float) -> void:
	if Input.is_action_pressed("thrust"):
		_engines_started = true
		var target_velocity : Vector3 = transform.basis.z * max_speed
		velocity = velocity.move_toward(target_velocity, thrust_force * velocity_redirect * delta)

	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed

func _apply_thrust_realistic(delta: float) -> void:
	if Input.is_action_pressed("thrust"):
		_engines_started = true
		velocity += transform.basis.z * thrust_force * delta
