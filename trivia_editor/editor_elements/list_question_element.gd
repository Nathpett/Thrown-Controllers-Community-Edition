extends VBoxContainer

var last_item_focused = null

@export var toggles_visible:bool = false

func _on_button_pressed():
	add_element()


func add_element():
	var item: Node = load("res://trivia_editor/editor_elements/string_element.tscn").instantiate()
	item.show_delete_button()
	#item.set_label_text("%s:" % [get_children().size()])
	item.set_label_text("ELEMENT!")
	item.get_node("TextEdit/CheckButton").visible = toggles_visible
	add_child(item)
	
	return item


func get_elements() -> Array:
	var elements = []
	for child in get_children():
		if child is StringElement:
			elements.append(child)
	return elements
