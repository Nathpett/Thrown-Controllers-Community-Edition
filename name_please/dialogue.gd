extends NinePatchRect

@onready var progress_blinker = $ProgressBlinker
@onready var progress_blinker_timer = $ProgressBlinker/Timer

@onready var label = $MarginContainer/Label



func type_char(new_char) -> void:
	var indx = label.text.find("@")
	if indx < 0:
		return
	label.text[indx] = new_char
	
	if indx + 1 != len(label.text):
		label.text[indx + 1] = "@"


func backspace() -> void:
	var indx = label.text.find("@")
	if indx == 0: # yah I know I can just do if index, but I actually want to point out that index is 0 so we can't do anything
		return
	if indx == -1:
		label.text[len(label.text) - 1] = "@"
		return
	label.text[indx] = "-"
	label.text[indx - 1] = "@"


func has_name() -> bool:
	return label.text[0] != "@"


func set_cur_name(new_name: String) -> void:
	if len(new_name) < len(label.text):
		new_name += "@"
	
	while len(new_name) < len(label.text):
		new_name += "-"
	
	label.text = new_name # because the one


func get_contestant_name() -> String:
	var idx = label.text.find("@")
	#return label.text.left(len(label.text) - idx)
	if idx == -1:
		return label.text
	else:
		return label.text.left(idx)


func _on_Timer_timeout() -> void:
	var region = progress_blinker.get_texture().region
	if region.position.x == 0:
		progress_blinker.get_texture().set_region(Rect2(Vector2(9, 0), region.size))
		progress_blinker_timer.start(1/6)
		# WAIT ONE SIXTH
	else:
		progress_blinker.get_texture().set_region(Rect2(Vector2(0, 0), region.size))
		progress_blinker_timer.start(1/3)
		# WAIT ONE THIRD
