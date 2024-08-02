class_name Game
extends Node


var game_state: GameState
var black_fade_transition = preload("res://screen_transitions/black_fade.tscn")

var main: Main
var avatar: Node
var mode: String = ""


func _ready() -> void:
	main = get_parent()
	
	avatar = load("res://avatar/avatar.tscn").instantiate()
	avatar.game = self
	add_child(avatar)
	
	var dir = DirAccess.open("user://")
	if !dir.dir_exists("trivia"):
		dir.make_dir("trivia")
	if !dir.dir_exists("saves"):
		dir.make_dir("saves")
	# copy trivia.json, push it to this dir as 'default_trivia.json
	#if !dir.file_exists("user://trivia/default_trivia.json"):
	dir.copy("res://trivia/default_trivia.json", "user://trivia/default_trivia.json") # REMINDER ABOUT RELOADING GAME WHEN TRIVIA HAS BEEN CHANGED!


func initiate(_trivia_path: String, _initial_mode: int, _fast_mode: bool, _shuffle_trivia: bool):
	pass


func go_to_name_please() -> void:
	main.change_scene_to_file(load("res://name_please/name_please.tscn").instantiate())


func load_game_state(file) -> void:
	main.editor_mode = false
	game_state = ResourceLoader.load("user://saves/" + file)
	_register_game_state()


func _on_devil_deal(_outcome) -> void:
	pass


func _on_success() -> void:
	var success_transition = load("res://screen_transitions/success_transition.tscn").instantiate()
	if main.editor_mode:
		main.change_scene_to_file(load("res://trivia_editor/trivia_editor.tscn").instantiate(), success_transition)
		return
	
	game_state.on_success()
	return_to_panel_select(success_transition)


func _on_failure() -> void:
	var transition = load("res://screen_transitions/failure_transition.tscn").instantiate()
	if main.editor_mode:
		main.change_scene_to_file(load("res://trivia_editor/trivia_editor.tscn").instantiate(), transition)
		return
	
	game_state.on_failure()
	
	# ever heard of DRY? me neither.  putting this here to catch instances where the contestant would get the very last trivia wrong
	var cat_queue: Array = game_state.new_category_queue()
	if cat_queue.all(Callable(CategoryStatics, "is_not_substantive")):
		all_trivia_exhausted(transition)
		return
	
	game_state.auto_save()


func _on_play_selected_panel(selected_panel) -> void:
	game_state.panels.erase(selected_panel.number)
	main.play_category(selected_panel.category)
	if !game_state.panels.size():
		game_state.refresh_cats(false)
	game_state.current_category = selected_panel.category


func _on_panels_changed() -> void:
	if main.current_scene is PanelSelect:
		return_to_panel_select()


func enter_devil_state() -> void:
	pass


func exit_devil_state() -> void:
	pass


func return_to_panel_select(_transition = null, _will_auto_save: bool = true) -> void:
	pass


func show_leaderboard() -> void:
	pass


func all_trivia_exhausted(_transition = null) -> void:
	pass


func _register_game_state() -> void:
	game_state.connect("panels_changed", Callable(self, "_on_panels_changed"))


func connect_game_scene(gs):
	if gs is PanelSelect:
		gs.connect("play_selected_panel", Callable(self, "_on_play_selected_panel"))
	if gs is Category:
		gs.connect("success", Callable(self, "_on_success"))
		gs.connect("failure", Callable(self, "_on_failure"))
		gs.connect("devil_deal", Callable(self, "_on_devil_deal"))


func new_avatar():
	return avatar.duplicate()
