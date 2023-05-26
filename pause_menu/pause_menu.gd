extends Control


func _input(event):
	if event.is_action_pressed("pause"):
		_unpause()
		get_viewport().set_input_as_handled()


func _unpause() -> void:
	queue_free()
	get_tree().paused = false
