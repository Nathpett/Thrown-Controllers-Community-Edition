class_name ScreenTransition
extends Node

signal screen_covered
signal finished

var trans_time = 2.0
var hold_time = 2.0
var text : set = _set_text


func _exit_tree():
	emit_signal("finished")


func _set_text(new_value) -> void:
	text = new_value


