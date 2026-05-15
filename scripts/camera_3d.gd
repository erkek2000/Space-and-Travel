extends Camera3D

@export var mouse_sensitivity : float = 0.0005
@export var pitch_limit       : float = 30.0
@export var return_speed      : float = 2.0
@export var ship_scale        : float = 0.05

var _pitch : float = 0.0
var _yaw   : float = 0.0

func _ready() -> void:
	set_as_top_level(true)

func _process(delta: float) -> void:
	var parent   : Node3D = get_parent()
	var offset   : Vector3 = Vector3(0.0, 12.0, -47.0) * ship_scale

	# Keep offset in world space, not rotated with ship
	global_position = parent.global_position + offset

	_pitch = lerp(_pitch, 0.0, return_speed * delta)
	_yaw   = lerp(_yaw,   0.0, return_speed * delta)

	# Follow ship rotation but flip x and z to correct inversions
	var base : Vector3 = parent.rotation
	rotation = Vector3(
		-base.x + _pitch,
		base.y + _yaw + deg_to_rad(180.0),
		-base.z
	)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_yaw   -= event.relative.x * mouse_sensitivity
		_pitch -= event.relative.y * mouse_sensitivity
		_pitch  = clamp(_pitch, deg_to_rad(-pitch_limit), deg_to_rad(pitch_limit))
