extends TriviaElement


#"multiple_choice": [
#	{"question": "Mandiblard, Sheargrub, and Crawmads are monsters from which game series?",
#	"answers": ["Monster Hunter", "Pokemon", "Pikmin", "Zelda"],
#	"answer": 2
#	}
#],

var answer_texts: Array = []

func _ready():
	answer_texts.append($VBoxContainer/StringElement/TextEdit)
	answer_texts.append($VBoxContainer/StringElement2/TextEdit)
	answer_texts.append($VBoxContainer/StringElement3/TextEdit)
	answer_texts.append($VBoxContainer/StringElement4/TextEdit)
	
	for text in answer_texts:
		var check = text.get_node("CheckButton")
		check.connect("pressed", Callable(self, "_on_check_button_pressed").bind(check))


func get_question() -> Dictionary:
	var question: Dictionary = {}
	
	question["question"] = $Question/TextEdit.text
	var answers: Array
	var answer = -1
	var i = 0
	for text in answer_texts:
		answers.append(text.text)
		var check = text.get_node("CheckButton")
		if check.button_pressed:
			answer = i
		i += 1
	
	question["answers"] = answers
	question["answer"] = answer
	
	return question


func set_question(question: Dictionary) -> void:
	$Question/TextEdit.text = question["question"]
	var i = 0
	for text in answer_texts:
		text.text = question["answers"][i]
		i += 1
	
	var answer = question["answer"]
	answer_texts[answer].get_node("CheckButton").button_pressed = true


func _on_check_button_pressed(sending_button):
	for text in answer_texts:
		var check = text.get_node("CheckButton")
		if check != sending_button:
			check.button_pressed = false
