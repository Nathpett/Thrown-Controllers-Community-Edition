class_name Game
extends Node


var game_state: GameState
var current_scene: GameScene
var black_fade_transition = preload("res://screen_transitions/black_fade.tscn")

var msgbox: MessageBox
var avatar: Avatar
var editor_mode: bool = true
var editor_category: String
var editor_trivia_file_name: String

@onready var transitions = $Transitions


func _ready() -> void:
	randomize()
	
	current_scene = load("res://main_menu/main_menu.tscn").instantiate()
	$GameScenes.add_child(current_scene)
	current_scene.game = self
	current_scene.enable()
	
	avatar = load("res://avatar/avatar.tscn").instantiate()
	add_child(avatar)
	
	var dir = DirAccess.open("user://")
	if !dir.dir_exists("trivia"):
		dir.make_dir("trivia")
	if !dir.dir_exists("saves"):
		dir.make_dir("saves")
	# copy trivia.json, push it to this dir as 'default_trivia.json
	#if !dir.file_exists("user://trivia/default_trivia.json"):
	dir.copy("res://trivia/default_trivia.json", "user://trivia/default_trivia.json") # REMINDER ABOUT RELOADING GAME WHEN TRIVIA HAS BEEN CHANGED!


func _input(event):
	if event.is_action_pressed("pause") and !current_scene.scene_disabled:
		var pause_menu = load("res://pause_menu/pause_menu.tscn").instantiate()
		pause_menu.game = self
		$UI.add_child(pause_menu)
		get_tree().paused = true


func new_game(trivia_path: String, initial_mode: int, _fast_mode: bool) -> void:
	editor_mode = false
	game_state = GameState.new()
	game_state.initiate(trivia_path, initial_mode, _fast_mode)
	_register_game_state()


func load_game_state(file) -> void:
	editor_mode = false
	game_state = ResourceLoader.load("user://saves/" + file)
	_register_game_state()
	
	if game_state.current_contestant_name == "":
		change_scene_to_file(load("res://name_please/name_please.tscn").instantiate())
	else:
		change_scene_to_file(load("res://panel_select/panel_select.tscn").instantiate())


func change_scene_to_file(new_scene, transition = null) -> void:
	# Begin transition, wait to hear "screen_obscured", delete the current scene and add the new
	if !transition:
		transition = new_scene.get_transition()
	
	transitions.add_child(transition)
	
	current_scene.disable()
	current_scene.music_fade_off()
	await transition.screen_covered
	
	current_scene.queue_free()
	
	current_scene = new_scene
	current_scene.game = self
	$GameScenes.add_child(new_scene)
	_connect_game_scene(current_scene)
	
	# wait until transition is complete to actually allow input
	await transition.finished
	current_scene.enable()
	
	_show_message()


func play_category(category) -> void:
	var category_path = "res://category/concrete_categories/%s.tscn" % [category]
	change_scene_to_file(load(category_path).instantiate())


# just connect it to everything lol whatever man...
func _connect_game_scene(gs):
	if gs is PanelSelect:
		gs.connect("play_selected_panel", Callable(self, "_on_play_selected_panel"))
	if gs is Category:
		gs.connect("success", Callable(self, "_on_success"))
		gs.connect("failure", Callable(self, "_on_failure"))
		gs.connect("devil_deal", Callable(self, "_on_devil_deal"))


func _on_play_selected_panel(selected_panel) -> void:
	# remove selecte panel from panels
	game_state.panels.erase(selected_panel.number)
	play_category(selected_panel.category)
	if !game_state.panels.size():
		game_state.refresh_cats(false)


func _on_devil_deal(outcome) -> void:
	if outcome:
		enter_devil_state()
	
	var transition = load("res://screen_transitions/garage_door.tscn").instantiate()
	transition.text = "DEAL!" if outcome else "NO DEAL!"
	transition.trans_time = 0.4
	transition.hold_time = 0.4
	game_state.check_exhaust(current_scene.get_category_type())
	return_to_panel_select(transition)


func _on_success() -> void:
	var success_transition = load("res://screen_transitions/success_transition.tscn").instantiate()
	if editor_mode:
		change_scene_to_file(load("res://trivia_editor/trivia_editor.tscn").instantiate(), success_transition)
		return
	
	game_state.on_success()
	
	game_state.check_exhaust(current_scene.get_category_type())
	return_to_panel_select(success_transition)


func _on_failure() -> void:
	var transition = load("res://screen_transitions/failure_transition.tscn").instantiate()
	if editor_mode:
		change_scene_to_file(load("res://trivia_editor/trivia_editor.tscn").instantiate(), transition)
		return
	
	game_state.on_failure()
	if game_state.devil_state: 
		exit_devil_state()
	game_state.check_exhaust(current_scene.get_category_type())
	
	# ever heard of DRY? me neither.  putting this here to catch instances where the contestant would get the very last trivia wrong
	var cat_queue: Array = game_state.new_category_queue()
	if cat_queue.all(Callable(CategoryStatics, "is_not_substantive")):
		all_trivia_exhausted(transition)
		return
	
	game_state.auto_save()
	change_scene_to_file(load("res://name_please/name_please.tscn").instantiate(), transition)


func _on_panels_changed() -> void:
	if current_scene is PanelSelect:
		return_to_panel_select()


func enter_devil_state() -> void:
	game_state.enter_devil_state()
	avatar.fast_soulless()


func exit_devil_state() -> void:
	game_state.exit_devil_state()
	avatar.souledded()


func return_to_panel_select(transition = null, will_auto_save: bool = true) -> void:
	if game_state.devil_state:
		if game_state.exhausted_categories.has("devils_deal"):
			#exit devil state if devils_deal is exhausted
			_queue_user_message("All brutal questions have been used, \n the contestant's soul has been refunded.")
			exit_devil_state()
		else:
			game_state.enforce_devil_composition()
	# get a new category queue, if none of the categories are substantive, enter the end scene
	var cat_queue: Array = game_state.new_category_queue()
	if cat_queue.all(Callable(CategoryStatics, "is_not_substantive")):
		all_trivia_exhausted(transition)
		return
	
	if will_auto_save:
		game_state.auto_save()
	change_scene_to_file(load("res://panel_select/panel_select.tscn").instantiate(), transition)


func return_to_main_menu() -> void:
	# if there is a transition, destroy it
	for child in transitions.get_children():
		child.queue_free()
	change_scene_to_file(load("res://main_menu/main_menu.tscn").instantiate())


func show_leaderboard() -> void:
	change_scene_to_file(load("res://game/leader_board.tscn").instantiate())


func all_trivia_exhausted(transition = null) -> void:
	game_state.push_current_to_leaderboard()
	change_scene_to_file(load("res://game/end_screen.tscn").instantiate(), transition)


func _queue_user_message(message: String) -> void:
	msgbox = load("res://panel_select/msg_box.tscn").instantiate()
	msgbox.text = message
	msgbox.visible = false
	add_child(msgbox)


func _show_message() -> void:
	if is_instance_valid(msgbox):
		msgbox.visible = true


func _register_game_state() -> void:
	game_state.connect("panels_changed", Callable(self, "_on_panels_changed"))
