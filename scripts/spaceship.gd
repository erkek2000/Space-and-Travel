extends CharacterBody3D

@export var thrust_force      : float = 2.0
@export var max_speed         : float = 20.0
@export var turn_speed        : float = 0.3
@export var roll_speed        : float = 0.3
@export var velocity_redirect : float = 2.0

@onready var down_gas       : Node3D = %DownGas
@onready var up_gas         : Node3D = %UpGas
@onready var left_gas       : Node3D = %LeftGas
@onready var right_gas      : Node3D = %RightGas
@onready var roll_left_gas  : Node3D = %RollLeftGas
@onready var roll_right_gas : Node3D = %RollRightGas
@onready var thrust_gas     : Node3D = %ThrustGas

var _engines_started : bool = false


# Realistic mode — accumulated rotation velocities
var _yaw_vel   : float = 0.0
var _pitch_vel : float = 0.0
var _roll_vel  : float = 0.0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# Each press adds or subtracts a fixed angular impulse — no decay
	if event.is_action_pressed("move_left"):
		_yaw_vel += turn_speed
	if event.is_action_pressed("move_right"):
		_yaw_vel -= turn_speed
	if event.is_action_pressed("move_forward"):
		_pitch_vel -= turn_speed
	if event.is_action_pressed("move_back"):
		_pitch_vel += turn_speed
	if event.is_action_pressed("roll_left"):
		_roll_vel += roll_speed
	if event.is_action_pressed("roll_right"):
		_roll_vel -= roll_speed

func _apply_rotation(delta: float) -> void:
	rotate_object_local(Vector3.UP,      _yaw_vel   * delta)
	rotate_object_local(Vector3.RIGHT,   _pitch_vel * delta)
	rotate_object_local(Vector3.FORWARD, _roll_vel  * delta)

func _physics_process(delta: float) -> void:
	_apply_rotation(delta)
	_update_thrusters()

	if GameManager.movement_mode == GameManager.MovementMode.SOFTCORE:
		_apply_thrust_softcore(delta)
	else:
		_apply_thrust_realistic(delta)

	move_and_slide()

func _update_thrusters() -> void:
	var thrusting : bool = Input.is_action_pressed("thrust")

	thrust_gas.visible = thrusting

	up_gas.visible         = Input.is_action_just_pressed("move_forward")
	down_gas.visible       = Input.is_action_just_pressed("move_back")
	left_gas.visible       = Input.is_action_just_pressed("move_left")
	right_gas.visible      = Input.is_action_just_pressed("move_right")
	roll_left_gas.visible  = Input.is_action_just_pressed("roll_left")
	roll_right_gas.visible = Input.is_action_just_pressed("roll_right")

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
