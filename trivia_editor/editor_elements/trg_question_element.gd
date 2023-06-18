extends TriviaElement


func get_question() -> Dictionary:
	var question = {}
	question["host"] = $Host/TextEdit.text
	
	var challenge_list = []
	for child in $ListQuestionElement.get_elements():
		challenge_list.append(child.get_node("TextEdit").text)
	
	question["challenges"] = challenge_list
	
	return question


func set_question(question: Dictionary) -> void:
	$Host/TextEdit.text = question["host"]
	
	var challenge_list = question["challenges"]
	for challenge in challenge_list:
		var item = $ListQuestionElement.add_element()
		item.get_node("TextEdit").text = challenge
