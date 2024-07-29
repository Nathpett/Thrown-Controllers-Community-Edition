class_name PartyGame
extends Game


# TODO NEXT START DESIGNING PARTY GAME

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
	super._on_success()


# TODO CAche the question, allow other player to answer
func _on_failure() -> void:
	#super._on_failure() # TODO STILL HAVE TO DO THIS ALL
	#
	var transition = load("res://screen_transitions/failure_transition.tscn").instantiate()
	main.change_scene_to_file(load("res://game/game_steal.tscn").instantiate(), transition)
	#main.change_scene_to_file(load("res://panel_select/party_panel_select.gd").instantiate(), transition)


func return_to_panel_select(transition = null, _will_auto_save: bool = true) -> void:
	game_state.cycle_player()
	main.change_scene_to_file(load("res://panel_select/party_panel_select.tscn").instantiate(), transition)


func show_leaderboard() -> void:
	pass


func all_trivia_exhausted(_transition = null) -> void:
	pass
