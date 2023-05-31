extends Node


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ext"):
		get_tree().quit()
