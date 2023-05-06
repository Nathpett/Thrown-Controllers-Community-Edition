class_name NumberedPanel
extends Node2D

@onready var label = $ColorRect/Label

#var pseudo_postion: Vector3 = Vector3.ZERO # xyz range from -1.0 to 1.0  then position is set by xy and the panel selector's dims, and scale/z_index is set using z
var rect_dims: Vector2 = Vector2.ZERO

var number: int: set = _set_number
var category: String
var panel_index: int = 0: set = _set_panel_index
var panels_left: int: set = _set_panels_left
var local_angle: float # set by our pseudo_index / len(numbered_panels)
var eff_scale_limit = 2 # limit that scale may be before becoming invisible

func turn_off_spotlight() -> void:
	$SpotlightSprite.visible = false


func _set_number(_number:int) -> void:
	number = _number
	if _number == 10:
		label.text = "X"
	else:
		label.text = str(_number)


func _set_panel_index(new_index) -> void:
	panel_index = new_index
	_update_local_angle()


func _set_panels_left(new_panels_left) -> void:
	panels_left = new_panels_left
	_update_local_angle()

# setter helper
func _update_local_angle() -> void: # this will be called more than is needed, but whatever there's no need to optimize this project too much right now
	local_angle = -TAU * panel_index / panels_left


func _on_update_panel_position(radius, wheel_angle) -> void:
	#pseudo_position = pseudo_postion.rotated(Vector3.AXIS_Z, 0)
	var angle = fmod(wheel_angle + local_angle, TAU)
	var pseudo_position = Vector3.BACK.rotated(Vector3.DOWN, angle)
	pseudo_position *= radius
	
	position = Vector2(pseudo_position.x, pseudo_position.y) * rect_dims / 2
	var eff_z = inverse_lerp(-radius, radius, pseudo_position.z) + 0.05
	z_index = floor(max(1.01, eff_z * 10))
	
	var eff_scale = max(0.4, pseudo_position.z)
	scale = Vector2.ONE * eff_scale
	if eff_scale > eff_scale_limit:
		visible = false
	else:
		visible = true


func _on_wheel_index_changed(wheel_index) -> void:
	if wheel_index == panel_index:
		$SpotlightSprite.visible = true
		modulate = Color.WHITE
	else:
		$SpotlightSprite.visible = false
		modulate = Color(0.4, 0.4, 0.4, 1.0)
