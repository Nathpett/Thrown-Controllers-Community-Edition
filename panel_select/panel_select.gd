class_name PanelSelect
extends GameScene

signal update_panel_position(radius, wheel_angle)
signal wheel_index_changed(wheel_index)
signal animation_finished

@export var number_of_panels: int = 10

var panel_packed_scene = preload("res://panel_select/numbered_panel.tscn")
var wheel_angle: float = 0
var wheel_radius: float = 0
var wheel_index: int: set = _set_wheel_index
var numbered_panels: Array = []


@onready var numbered_panels_control = $Control/PanelSelector/NumberedPanels
@onready var panel_selector = $Control/PanelSelector
@onready var wheel_tween: Tween


func _ready() -> void:
	super._ready()
	
	var val = 0
	if game:
		val = min(6.0, game.current_contestant_score)
	$Music.play(val * 125.0/7.0)


func _input(event: InputEvent) -> void:
	if scene_disabled:
		return
	
	if event.is_action_pressed("ui_right"):
		alter_wheel_index(1)
	if event.is_action_pressed("ui_left"):
		alter_wheel_index(-1)
	
	var just_pressed = !event.is_echo() and event.is_pressed()
	if just_pressed:
		_try_fast_select(event.as_text())
	
	if event.is_action_pressed("ui_select"):
		_panel_select_animation()


func enable() -> void:
	# initiation stuff
	initiate_panels()
	
	# opening animation
	_opening_animation()
	await self.animation_finished
	
	super.enable()


func get_title() -> String:
	return "SELECT A PANEL!"


func _opening_animation():
	var ani_tween = create_tween()
	var ani_time = 1 
	
	wheel_angle = 0
	wheel_radius = 5.0
	ani_tween.tween_property(self, "wheel_angle", TAU, ani_time).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	ani_tween.parallel().tween_property(self, "wheel_radius", 0.9, ani_time).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	ani_tween.parallel().tween_method(Callable(self, "_update_panels"), 0, 0, ani_time)
	
	await ani_tween.finished
	
	_set_wheel_index(0)
	emit_signal("animation_finished")


func _panel_select_animation():
	disable()
	
	var ani_tween = create_tween()
	var selected_panel: NumberedPanel = numbered_panels[wheel_index]
	
	selected_panel.turn_off_spotlight()
	selected_panel.eff_scale_limit = 100
	
	var ani_time = 2
	ani_tween.tween_property($AudioStreamPlayer, "volume_db", -80, ani_time)
	ani_tween.parallel().tween_property(self, "wheel_radius", 5.0, ani_time).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	ani_tween.parallel().tween_property(selected_panel, "modulate", Color.BLACK, ani_time).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	ani_tween.parallel().tween_method(Callable(self, "_update_panels"), 0, 0, ani_time)
	
	await ani_tween.finished
	
	emit_signal("play_selected_panel", selected_panel)


func _find_wheel_index(_number: int) -> int:
	var i = 0
	for np in numbered_panels:
		if np.number == _number:
			return i
		i += 1
	return -1


func _update_panels(_1): # because for some reason tween step calls with arguments??
	emit_signal("update_panel_position", wheel_radius, wheel_angle) 


func alter_wheel_index(index_change: int) -> void:
	#wheel_tween.kill()
	
	var faux_wheel_index = wheel_index + index_change
	motion_toward_wheel_index(faux_wheel_index)
	self.wheel_index = posmod(wheel_index + index_change, len(numbered_panels))


func motion_toward_wheel_index(index) -> void:
	if wheel_tween:
		wheel_tween.kill()
	
	wheel_tween = create_tween()
	
	var dest_angle: float = index * TAU / len(numbered_panels)
	
	# ok this block is hard to explain.  Basically the back tween makes the tween angle go back 
	# a bit, so we need to 'start' wheel angle at the angle with the shortest distance to dest_angle, which 
	# can be either start_wheel_angle + 0, +TAU, or -TAU... I think, i kinda workshopped it so maybe I'm wrong. seems to work
	var start_wheel_angle = fposmod(wheel_angle, TAU)
	if abs((start_wheel_angle + TAU) - dest_angle) < abs(start_wheel_angle - dest_angle):
		start_wheel_angle += TAU
	elif abs((start_wheel_angle - TAU) - dest_angle) < abs(start_wheel_angle - dest_angle):
		start_wheel_angle -= TAU
	
	wheel_angle = start_wheel_angle
	wheel_tween.tween_property(self, "wheel_angle", dest_angle, 0.5).set_trans(Tween.TRANS_BACK)
	wheel_tween.parallel().tween_method(Callable(self, "_update_panels"), 0, 0, 0.5)


func initiate_panels() -> void:
	var panels: Dictionary # because sometimes we need to test panel select without game loaded
	if game:
		panels = game.panels
	else:
		panels = {}
		for i in range(1, 11):
			panels[i] = "easy_question"
	
	for n in panels:
		var new_panel = new_numbered_panel(n)
		new_panel.category = panels[n]
		numbered_panels.append(new_panel)
	
	var np_ct = len(numbered_panels)
	var i = 0
	for numbered_panel in numbered_panels:
		numbered_panel.panels_left = np_ct
		numbered_panel.panel_index = i
		i += 1


# we don't need a factory
func new_numbered_panel(number:int) -> NumberedPanel:
	var new_panel = panel_packed_scene.instantiate()
	numbered_panels_control.add_child(new_panel)
	connect("update_panel_position", Callable(new_panel, "_on_update_panel_position"))
	connect("wheel_index_changed", Callable(new_panel, "_on_wheel_index_changed"))
	new_panel.rect_dims = $Control.size
	new_panel.number = number
	return new_panel


func _try_fast_select(k: String) -> void:
	if !k.is_valid_int():
		return
	var number = int(k)
	if number == 0: #im sure there's an elegant alternative but i'm not looking that hard
		number = 10
	
	var indx = _find_wheel_index(number)
	if indx != -1:
		self.wheel_index = indx
		motion_toward_wheel_index(indx)


func _set_wheel_index(new_wheel_index) -> void:
	wheel_index = new_wheel_index
	$SpotLight.play()
	emit_signal("wheel_index_changed", wheel_index)

