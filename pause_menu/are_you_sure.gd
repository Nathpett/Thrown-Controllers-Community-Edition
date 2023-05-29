extends Control


var yes_function: Callable
var pause_menu


func _ready():
	$HBoxContainer/NoButton.grab_focus()


func destroy() -> void:
	queue_free()


func _on_yes_button_pressed():
	yes_function.call()


func _on_no_button_pressed():
	queue_free()
	pause_menu.return_focus()
