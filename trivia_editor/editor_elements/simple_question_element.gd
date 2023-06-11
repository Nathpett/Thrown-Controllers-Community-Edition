extends TriviaElement


func get_question() -> Dictionary:
	var question = {}
	
	for element in _get_elements():
		question[element.name.to_snake_case()] = element.get_node("TextEdit").text
	
	return question


func set_question(question: Dictionary) -> void:
	for element in _get_elements():
		element.get_node("TextEdit").text = question[element.name.to_snake_case()]


func _get_elements() -> Array:
	var elements = []
	for child in get_children():
		if child is StringElement:
			elements.append(child)
	return elements
