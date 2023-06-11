extends Control

var trivia_data: Dictionary
var current_category: String: set = _set_current_category

func _ready():
	for cat in CategoryStatics.CATEGORIES:
		$Control/Control/OptionButton.add_item(cat)
	
	current_category = $Control/Control/OptionButton.text


func _unload_category():
	# save current category data to current trivia
	var questions: Array = []
	for child in $ScrollContainer/VBoxContainer.get_children():
		questions.append(child.get_question())
	
	trivia_data[current_category] = questions
	
	# kill all of $ScrollContainer/VBoxContainer's children
	for child in $ScrollContainer/VBoxContainer.get_children():
		child.queue_free()


func _load_category():
	var questions: Array = trivia_data.get(current_category, [])
	var element_packed = load(CategoryStatics.get_editor_element_path(current_category))
	for question in questions:
		var new_element = element_packed.instantiate()
		new_element.set_question(question)
		_add_item(new_element)
		# new_question.set_question(question)


func _add_item(item) -> void:
	$ScrollContainer/VBoxContainer.add_child(item)


func _on_option_button_item_selected(index):
	_unload_category()
	current_category = $Control/Control/OptionButton.text


func _on_add_item_button_pressed():
	_add_item(load(CategoryStatics.get_editor_element_path(current_category)).instantiate())
	

func _set_current_category(new_value: String) -> void:
	current_category = new_value
	_load_category()
