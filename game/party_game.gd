class_name PartyGame
extends Game



func initiate(_trivia_path: String, _initial_mode: int, _fast_mode: bool, _shuffle_trivia: bool):
	game_state = PartyGameState.new()
	game_state.initiate(_trivia_path, _initial_mode, _fast_mode, _shuffle_trivia)
	_register_game_state()
	
	go_to_name_please()


func load_game_state(file) -> void:
	pass


func go_to_name_please() -> void:
	main.change_scene_to_file(load("res://name_please/name_please_party.tscn").instantiate())


func _on_success() -> void:
	var success_transition = load("res://screen_transitions/success_transition.tscn").instantiate()
	if main.editor_mode:
		main.change_scene_to_file(load("res://trivia_editor/trivia_editor.tscn").instantiate(), success_transition)
		return
	
	game_state.on_success()
	game_state.use_cached = false
	
	
	return_to_panel_select(success_transition)


func _on_failure() -> void:
	var transition = load("res://screen_transitions/failure_transition.tscn").instantiate()
	if CategoryStatics.can_steal(game_state.current_category):
		game_state.on_failure() # put this right here so that the first player wrong in the steal cycle doesn't lose points
		game_state.use_cached = true
		main.change_scene_to_file(load("res://game/game_steal.tscn").instantiate(), transition)
		return
	
	super._on_failure()
	return_to_panel_select(transition)


func return_to_panel_select(transition = null, _will_auto_save: bool = true) -> void:
	game_state.check_exhaust(game_state.current_category)
	
	var cat_queue: Array = game_state.new_category_queue()
	if cat_queue.all(Callable(CategoryStatics, "is_not_substantive")):
		all_trivia_exhausted(transition)
		return
	
	game_state.cycle_player()
	main.change_scene_to_file(load("res://panel_select/party_panel_select.tscn").instantiate(), transition)


func all_trivia_exhausted(transition = null) -> void:
	main.change_scene_to_file(load("res://game/leader_board.tscn").instantiate(), transition)


func new_avatar():
	var _avatar = load("res://avatar/avatar.tscn").instantiate()
	_avatar.reigon_vector = game_state.players[game_state.active_player]["reigon_vector"]
	return _avatar
