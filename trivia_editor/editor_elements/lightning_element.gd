extends TriviaElement


func get_question() -> Dictionary:
	var question = {}
	question["theme"] = $Theme/TextEdit.text
	question["left"] = $Left/TextEdit.text
	question["right"] = $Right/TextEdit.text
	question["time_limit"] = $TimeLimit/SpinBox.value
	
	var questions_list = []
	for child in $ListQuestionElement.get_elements():
		questions_list.append([child.get_node("TextEdit").text, child.get_node("TextEdit/CheckButton").button_pressed])
	
	question["questions"] = questions_list
	
	return question


func set_question(question: Dictionary) -> void:
	$Theme/TextEdit.text = question["theme"]
	$Left/TextEdit.text = question["left"]
	$Right/TextEdit.text = question["right"]
	$TimeLimit/SpinBox.value = question["time_limit"]
	
	var question_list = question["questions"]
	for q in question_list:
		var item = $ListQuestionElement.add_element()
		item.get_node("TextEdit").text = q[0]
		item.set_toggle_pressed(q[1])
