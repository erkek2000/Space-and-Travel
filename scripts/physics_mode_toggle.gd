extends Node

# ─────────────────────────────────────────────
#  PhysicsModeToggle.gd
#  Attach this node directly to GameManager.
#  Press X to toggle between SOFTCORE and REALISTIC.
# ─────────────────────────────────────────────

@export var toggle_key: Key = KEY_X

var _hud: CanvasLayer
var _btn_softcore: Button
var _btn_realistic: Button


func _ready() -> void:
	_build_hud()
	_refresh_hud()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == toggle_key:
			_toggle()
			get_viewport().set_input_as_handled()


func _toggle() -> void:
	var gm = get_parent()

	if gm.movement_mode == gm.MovementMode.SOFTCORE:
		gm.movement_mode = gm.MovementMode.REALISTIC
	else:
		gm.movement_mode = gm.MovementMode.SOFTCORE

	_refresh_hud()


# ════════════════════════════════════════════
#  HUD
# ════════════════════════════════════════════
func _build_hud() -> void:
	_hud = CanvasLayer.new()
	_hud.name = "PhysicsModeHUD"
	_hud.layer = 10
	add_child(_hud)

	var container := HBoxContainer.new()
	container.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	container.position = Vector2(8, 8)
	container.add_theme_constant_override("separation", 4)
	_hud.add_child(container)

	_btn_softcore  = _make_indicator_button("SOFT",      Color(0.30, 0.85, 0.50))
	_btn_realistic = _make_indicator_button("REAL PHYS", Color(0.95, 0.45, 0.20))

	container.add_child(_btn_softcore)
	container.add_child(_btn_realistic)


func _make_indicator_button(label: String, active_color: Color) -> Button:
	var btn := Button.new()
	btn.text = label
	btn.focus_mode = Control.FOCUS_NONE
	btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.custom_minimum_size = Vector2(62, 18)

	var style_active := StyleBoxFlat.new()
	style_active.bg_color = active_color
	for corner in ["corner_radius_top_left","corner_radius_top_right","corner_radius_bottom_left","corner_radius_bottom_right"]:
		style_active.set(corner, 3)
	style_active.content_margin_left   = 4
	style_active.content_margin_right  = 4
	style_active.content_margin_top    = 2
	style_active.content_margin_bottom = 2

	var style_inactive := StyleBoxFlat.new()
	style_inactive.bg_color = Color(0.12, 0.12, 0.12, 0.70)
	for side in ["border_width_left","border_width_right","border_width_top","border_width_bottom"]:
		style_inactive.set(side, 1)
	style_inactive.border_color = active_color.darkened(0.35)
	for corner in ["corner_radius_top_left","corner_radius_top_right","corner_radius_bottom_left","corner_radius_bottom_right"]:
		style_inactive.set(corner, 3)
	style_inactive.content_margin_left   = 4
	style_inactive.content_margin_right  = 4
	style_inactive.content_margin_top    = 2
	style_inactive.content_margin_bottom = 2

	btn.set_meta("style_active",   style_active)
	btn.set_meta("style_inactive", style_inactive)
	btn.set_meta("active_color",   active_color)
	btn.add_theme_font_size_override("font_size", 9)

	return btn


func _refresh_hud() -> void:
	var gm = get_parent()
	var is_soft = gm.movement_mode == gm.MovementMode.SOFTCORE
	_set_button_active(_btn_softcore,  is_soft)
	_set_button_active(_btn_realistic, not is_soft)


func _set_button_active(btn: Button, is_active: bool) -> void:
	var style_on  = btn.get_meta("style_active")   as StyleBoxFlat
	var style_off = btn.get_meta("style_inactive")  as StyleBoxFlat
	var col       = btn.get_meta("active_color")    as Color

	if is_active:
		btn.add_theme_stylebox_override("normal", style_on)
		btn.add_theme_stylebox_override("hover",  style_on)
		btn.add_theme_color_override("font_color", Color.BLACK)
		btn.modulate = Color(1, 1, 1, 1.0)
	else:
		btn.add_theme_stylebox_override("normal", style_off)
		btn.add_theme_stylebox_override("hover",  style_off)
		btn.add_theme_color_override("font_color", col.lightened(0.1))
		btn.modulate = Color(1, 1, 1, 0.45)
