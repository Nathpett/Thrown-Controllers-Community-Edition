class_name TriviaElement
extends VBoxContainer


func _ready():
	var element_button_h_box = load("res://trivia_editor/element_button_h_box.tscn").instantiate()
	add_child(element_button_h_box)
	move_child(element_button_h_box, 1)
	
	element_button_h_box.get_node("DeleteButton").connect("pressed", Callable(self, "_on_delete_button_pressed"))


func _on_delete_button_pressed() -> void:
	queue_free()
