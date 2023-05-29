class_name Game
extends Node


# TODO GET MUSIC ON LIST, IMPLEMENT TO MAKE MORE LIVELY
# TODO YOU IMPLEMENTED TRG VIDEO GAME CHALLENGE WONNNNGGGGG!!!! ITS GOTTA BE A COMPLEX QUESTION LIKE PICK YOUR POISON!!

var game_state: GameState
var current_scene: GameScene
var black_fade_transition = preload("res://screen_transitions/black_fade.tscn")

var msgbox: MessageBox
var avatar: Avatar


@onready var transitions = $Transitions


func _ready() -> void:
#	# check if trivia in user://, if none, copy and paste the default!
#	var dir = DirAccess.open("user://")
#	if !dir.dir_exists("trivia"):
#		Game.dir_deep_copy("res://trivia", "user://trivia")
	
	current_scene = load("res://main_menu/main_menu.tscn").instantiate()
	$GameScenes.add_child(current_scene)
	current_scene.game = self
	current_scene.enable()
	
	avatar = load("res://avatar/avatar.tscn").instantiate()
	add_child(avatar)
	
	_new_game_state()


func _new_game_state() -> void:
	game_state = GameState.new()
	game_state.mode = GameState.Mode.RANDOM
	game_state.setup()
	game_state.connect("panels_changed", Callable(self, "_on_panels_changed"))


func _input(event):
	if event.is_action_pressed("pause"):
		var pause_menu = load("res://pause_menu/pause_menu.tscn").instantiate()
		pause_menu.game = self
		$UI.add_child(pause_menu)
		get_tree().paused = true


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
	await transition.tree_exited
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
	game_state.on_success()
	
	var success_transition = load("res://screen_transitions/garage_door.tscn").instantiate()
	success_transition.text = "SUCCESS!"
	success_transition.trans_time = 0.4
	success_transition.hold_time = 0.4
	game_state.check_exhaust(current_scene.get_category_type())
	return_to_panel_select(success_transition)


func _on_failure() -> void:
	game_state.on_failure()
	game_state.check_exhaust(current_scene.get_category_type())
	
	var transition = load("res://screen_transitions/failure_transition.tscn").instantiate()
	change_scene_to_file(load("res://name_please/name_please.tscn").instantiate(), transition)


func _on_panels_changed() -> void:
	if current_scene is PanelSelect:
		change_scene_to_file(load("res://panel_select/panel_select.tscn").instantiate())


func enter_devil_state() -> void:
	game_state.enter_devil_state()
	avatar.fast_soulless()


func exit_devil_state() -> void:
	game_state.exit_devil_state()
	avatar.souledded()


func return_to_panel_select(transition) -> void:
	# exhaust the category if it's out of questions
	if game_state.devil_state:
		if game_state.exhausted_categories.has("devils_deal"):
			#exit devil state if devils_deal is exhausted
			_queue_user_message("All brutal questions have been used, \n the contestant's soul has been refunded.")
			exit_devil_state()
		else:
			game_state.enforce_devil_composition()
	
	change_scene_to_file(load("res://panel_select/panel_select.tscn").instantiate(), transition)


func return_to_main_menu() -> void:
	# if there is a transition, destroy it
	for child in transitions.get_children():
		child.queue_free()
	change_scene_to_file(load("res://main_menu/main_menu.tscn").instantiate())
	_new_game_state()


func _queue_user_message(message: String) -> void:
	msgbox = load("res://panel_select/msg_box.tscn").instantiate()
	msgbox.text = message
	msgbox.visible = false
	add_child(msgbox)


func _show_message() -> void:
	if is_instance_valid(msgbox):
		msgbox.visible = true


static func dir_deep_copy(path_from : String, path_to : String) -> void:
	var from_dir: DirAccess = DirAccess.open(path_from)
	if !from_dir.dir_exists(path_to):
		from_dir.make_dir_absolute(path_to)
	from_dir.list_dir_begin()
	var file_name = from_dir.get_next()
	while file_name:
		if from_dir.current_is_dir():
			Game.dir_deep_copy("%s/%s" % [path_from, file_name], "%s/%s" % [path_to, file_name])
		else:
			from_dir.copy("%s/%s" % [path_from, file_name], "%s/%s" % [path_to, file_name])
		file_name = from_dir.get_next()
	
