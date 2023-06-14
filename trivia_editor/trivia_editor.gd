extends GameScene

var trivia_data: Dictionary
var current_category: String: set = _set_current_category
var current_file_name: String: set = _set_current_file_name

@onready var options_button = $Control/Control/OptionButton
@onready var vbox_container = $ScrollContainer/VBoxContainer
@onready var trivia_json_button = $Control/Control2/TriviaJsonButton

# TODO NEXT, FIGURE OUT TRG CHALLENGE
# ALSO TODO, NEW FILE OPTION

func _ready():
	var editiable_categories = CategoryStatics.CATEGORIES.keys()
	editiable_categories = editiable_categories.filter(Callable(CategoryStatics, "is_substantive"))
	for cat in editiable_categories:
		options_button.add_item(cat)
	
	_populate_trivia_json_button()
	
	if game.editor_category:
		current_category = game.editor_category
		options_button.select(editiable_categories.find(game.editor_category))
	else:
		current_category = options_button.text
	
	if game.editor_trivia_file_name:
		current_file_name = game.editor_trivia_file_name
		var files = DirAccess.open("user://trivia").get_files()
		trivia_json_button.select(files.find(game.editor_trivia_file_name + ".json"))
	else:
		current_file_name = trivia_json_button.text
	
	game.editor_mode = true


func _exit_tree():
	_unload_category()
	var json = JSON.new()
	json.data = trivia_data
	
	ResourceSaver.save(json, "user://trivia/" + current_file_name + ".json")


func _unload_category():
	# save current category data to current trivia
	var questions: Array = []
	for child in vbox_container.get_children():
		questions.append(child.get_question())
	
	trivia_data[current_category] = questions
	
	# kill all of $ScrollContainer/VBoxContainer's children
	for child in vbox_container.get_children():
		child.queue_free()


func _load_category():
	var questions: Array = trivia_data.get(current_category, [])
	var element_packed = load(CategoryStatics.get_editor_element_path(current_category))
	for question in questions:
		var new_element = element_packed.instantiate()
		_add_item(new_element)
		new_element.set_question(question)
		# new_question.set_question(question)


func _add_item(item) -> void:
	vbox_container.add_child(item)
	item.connect("test_trivia", Callable(self, "_on_test_trivia"))


func _populate_trivia_json_button() -> void:
	trivia_json_button.clear()
	
	var dir = DirAccess.open("user://trivia")
	for file in dir.get_files():
		trivia_json_button.add_item(file.get_basename())
	trivia_json_button.add_item("New")


func _on_option_button_item_selected(index):
	_unload_category()
	current_category = options_button.text


func _on_add_item_button_pressed():
	_add_item(load(CategoryStatics.get_editor_element_path(current_category)).instantiate())
	

func _set_current_category(new_value: String) -> void:
	current_category = new_value
	game.editor_category = new_value
	_load_category()


func _set_current_file_name(new_value: String) -> void:
	current_file_name = new_value
	game.editor_trivia_file_name = new_value
	var file = FileAccess.open("user://trivia/" + current_file_name + ".json", FileAccess.READ)
	trivia_data = JSON.parse_string(file.get_as_text())
	
	_load_category()


func _on_test_trivia(question: Dictionary) -> void:
	var category = load("res://category/concrete_categories/%s.tscn" % [current_category]).instantiate()
	category.override_trivia_data = question
	game.change_scene_to_file(category)


func _on_trivia_json_button_item_selected(index):
	if index == trivia_json_button.item_count - 1:
		var dir = DirAccess.open("user://trivia/")
		var file_ct = dir.get_files().size()
		var number_tag = "000".right(3 - len(str(file_ct))) + str(file_ct)
		# copy trivia.json, push it to this dir as 'default_trivia.json
		dir.copy("res://trivia/trivia_abstracts.json", "user://trivia/%s_trivia.json" % [number_tag])
		_populate_trivia_json_button()
		return
	
	_unload_category()
	current_file_name = trivia_json_button.text
