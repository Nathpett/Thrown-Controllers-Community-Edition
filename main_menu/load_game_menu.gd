extends Control

var game
var focused_element


func _ready():
	var file_element_packed = load("res://main_menu/load_menu_file_element.tscn")
	var dir = DirAccess.open("user://saves")
	# get list of all saves with auto save token, if there are 3 or more, delete the oldest until there are 2. 
	for file in dir.get_files():
		var new_element = file_element_packed.instantiate()
		$MarginContainer/ScrollContainer/VBoxContainer.add_child(new_element)
		
		var game_state = ResourceLoader.load("user://saves/" + file)
		
		new_element.get_node("SaveNameLabel").text = file
		new_element.get_node("TriviaSet").text = "Trivia Set: " + game_state.initial_trivia_set
		new_element.get_node("DateLabel").text = StringTools.get_handsom_date(game_state.time_string)
		
		new_element.connect("focus_entered", Callable(self, "_on_file_element_focus_entered").bind(new_element))
	
	$MarginContainer/ScrollContainer/VBoxContainer.get_child(0).grab_focus()


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		queue_free()
	if event.is_action_pressed("ui_accept") and is_instance_valid(focused_element):
		game.load_game_state(focused_element.get_node("SaveNameLabel").text)


func _on_file_element_focus_entered(file_element) -> void:
	focused_element = file_element
	call_deferred("_update_blinker", file_element)


func _update_blinker(file_element) -> void:
	$Blinker.position = file_element.get_global_position() + Vector2.DOWN * file_element.size / 2 + Vector2.LEFT * 20
