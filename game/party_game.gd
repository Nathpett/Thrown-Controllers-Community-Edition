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


func _on_devil_deal(_outcome) -> void:
	pass


func _on_success() -> void:
	pass


func _on_failure() -> void:
	pass


func _on_play_selected_panel(_selected_panel) -> void:
	pass


func _on_panels_changed() -> void:
	pass


func enter_devil_state() -> void:
	pass


func exit_devil_state() -> void:
	pass


func return_to_panel_select(_transition = null, _will_auto_save: bool = true) -> void:
	main.change_scene_to_file(load("res://panel_select/party_panel_select.tscn").instantiate())


func show_leaderboard() -> void:
	pass


func all_trivia_exhausted(_transition = null) -> void:
	pass
