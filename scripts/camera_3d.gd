extends Camera3D

@export var mouse_sensitivity : float = 0.002
@export var pitch_limit       : float = 60.0   # degrees, set 0 to disable

var _pitch : float = 0.0
var _yaw   : float = 0.0

func _ready() -> void:
	# Detach from parent transform so camera rotates independently
	set_as_top_level(true)

func _process(delta: float) -> void:
	var parent_pos  : Vector3 = get_parent().global_position
	var offset      : Vector3 = Vector3(0.0, 12.0, -47.0)
	var scale : float = 0.05
	global_position  = parent_pos + (offset*scale)
	rotation         = Vector3(_pitch, _yaw + deg_to_rad(180.0), 0.0)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_yaw   -= event.relative.x * mouse_sensitivity
		_pitch -= event.relative.y * mouse_sensitivity
		_pitch  = clamp(_pitch, deg_to_rad(-pitch_limit), deg_to_rad(pitch_limit))
		rotation = Vector3(_pitch, _yaw, 0.0)
