class_name StringElement
extends Control


func show_delete_button() -> void:
	$Label/Button.visible = true


func set_label_text(new_text) -> void:
	$Label.text = new_text


func set_toggle_pressed(new_value: bool) -> void:
	$TextEdit/CheckButton.button_pressed = new_value


func _on_button_pressed():
	queue_free()

