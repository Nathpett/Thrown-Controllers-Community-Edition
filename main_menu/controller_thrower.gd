extends Node2D


var cont_icon_packed = preload("res://main_menu/ControllerIcon.tscn")
var throw_freq = 2 # per 60 frames
var throw_progress:float = 0

var change_throw_freq_progress: float = 0
var change_throw_freq_freq = 0.1 # per 60 frames


var conts: Array = [
	preload("res://assets/controller_icons_from_flaticon/cont.png"),
	preload("res://assets/controller_icons_from_flaticon/cont2.png"),
	preload("res://assets/controller_icons_from_flaticon/cont3.png"),
	preload("res://assets/controller_icons_from_flaticon/cont4.png"),
	preload("res://assets/controller_icons_from_flaticon/cont5.png"),
	preload("res://assets/controller_icons_from_flaticon/cont6.png"),
	preload("res://assets/controller_icons_from_flaticon/cont7.png"),
	preload("res://assets/controller_icons_from_flaticon/cont8.png"),
	preload("res://assets/controller_icons_from_flaticon/cont9.png"),
	preload("res://assets/controller_icons_from_flaticon/cont10.png"),
]


func _process(delta: float) -> void:
	if throw_progress >= 1.0:
		throw_cont()
		throw_progress = fmod(throw_progress, 1.0)
	throw_progress += delta * throw_freq
	
	if change_throw_freq_progress >= 1.0:
		throw_freq = randf_range(1, 10)
		change_throw_freq_progress = fmod(change_throw_freq_progress, 1.0)
	change_throw_freq_progress += delta * throw_freq
	
	

func throw_cont() -> void:
	var new_cont = cont_icon_packed.instantiate()
	new_cont.texture = conts[randi() % len(conts)]
	new_cont.position = lerp($a.position, $b.position, randf())
	
	add_child(new_cont)
