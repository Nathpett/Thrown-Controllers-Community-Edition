extends GameScene

var trivia_data: Dictionary
var current_category: String: set = _set_current_category
var current_file_name: String: set = _set_current_file_name

@onready var options_button = $Control/Control/OptionButton
@onready var vbox_container = $ScrollContainer/VBoxContainer
@onready var trivia_json_button = $Control/Control2/TriviaJsonButton


func _ready():
	super._ready()
	var editiable_categories = CategoryStatics.CATEGORIES.keys()
	editiable_categories = editiable_categories.filter(Callable(CategoryStatics, "is_substantive"))
	for cat in editiable_categories:
		options_button.add_item(cat)
	
	_populate_trivia_json_button()
	
	if main.editor_category:
		current_category = main.editor_category
		options_button.select(editiable_categories.find(main.editor_category))
	else:
		current_category = options_button.text
	
	if main.editor_trivia_file_name:
		current_file_name = main.editor_trivia_file_name
		var files = DirAccess.open("user://trivia").get_files()
		trivia_json_button.select(files.find(main.editor_trivia_file_name + ".json"))
	else:
		current_file_name = trivia_json_button.text
	
	main.editor_mode = true


func _exit_tree():
	_save_trivia_set()


func _save_trivia_set() -> void:
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
	main.editor_category = new_value
	_load_category()


func _set_current_file_name(new_value: String) -> void:
	current_file_name = new_value
	main.editor_trivia_file_name = new_value
	var file = FileAccess.open("user://trivia/" + current_file_name + ".json", FileAccess.READ)
	trivia_data = JSON.parse_string(file.get_as_text())
	
	_load_category()


func _on_test_trivia(question: Dictionary) -> void:
	var category = load("res://category/concrete_categories/%s.tscn" % [current_category]).instantiate()
	if current_category == "TheRunawayGuys_video_game_challenge": # man what a hack! but I can't think of a better way to force the test to take the whole trivia_data
		category.override_trivia_data = trivia_data["TheRunawayGuys_video_game_challenge"]
	else:
		category.override_trivia_data = question
	main.change_scene_to_file(category)


func _on_trivia_json_button_item_selected(index):
	var new_cur_file_name
	if index == trivia_json_button.item_count - 1:
		var dir = DirAccess.open("user://trivia/")
		var number_tag = _get_unique_tag(dir)
		# copy trivia.json, push it to this dir as 'default_trivia.json
		dir.copy("res://trivia/trivia_abstracts.json", "user://trivia/%s_trivia.json" % [number_tag])
		
		new_cur_file_name = "%s_trivia" % [number_tag]
		trivia_json_button.set_item_text(index, new_cur_file_name)
		trivia_json_button.add_item("New")
	else:
		new_cur_file_name = trivia_json_button.text
	
	_save_trivia_set()
	current_file_name = new_cur_file_name


func _get_unique_tag(dir: DirAccess) -> String:
	var taken_tags: Array = []
	for file in dir.get_files():
		taken_tags.append(file.get_basename().left(3))
	taken_tags.sort()
	
	var tag = "def"
	var i = 1
	while taken_tags.has(tag):
		tag = StringTools.rjust(i, "0", 3)
		i += 1
	
	return tag
