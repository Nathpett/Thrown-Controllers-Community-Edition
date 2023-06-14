class_name TriviaElement
extends VBoxContainer

signal test_trivia(question: Dictionary)


func _ready():
	var element_button_h_box = load("res://trivia_editor/element_button_h_box.tscn").instantiate()
	add_child(element_button_h_box)
	move_child(element_button_h_box, 1)
	
	element_button_h_box.get_node("DeleteButton").connect("pressed", Callable(self, "_on_delete_button_pressed"))
	element_button_h_box.get_node("TestButton").connect("pressed", Callable(self, "_on_test_button_pressed"))


func get_question() -> Dictionary:
	return {}


func set_question(_question: Dictionary) -> void:
	pass


func _on_delete_button_pressed() -> void:
	queue_free()


func _on_test_button_pressed() -> void:
	emit_signal("test_trivia", get_question())
