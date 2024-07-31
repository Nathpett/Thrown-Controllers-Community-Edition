extends GameScene

var prev_active_player_idx: int = 0


func _input(event):
	if scene_disabled:
		return
	
	if event.is_action_pressed("right"):
		$Control/ScoreBoard.kill_spotlight()
		game.game_state.iterate_player(1)
		_update_spotlight()
	if event.is_action_pressed("left"):
		$Control/ScoreBoard.kill_spotlight()
		game.game_state.iterate_player(-1)
		_update_spotlight()
	if event.is_action_pressed("ui_select"):
		disable()
		main.play_category(game.game_state.current_category)
	if event.is_action_pressed("registration_complete"):
		disable()
		game.game_state.use_cached = false
		game.return_to_panel_select()
	

func enable() -> void:
	await get_tree().create_timer(0.1).timeout
	game.game_state.iterate_player(1)
	_update_spotlight()
	$Control/ScoreBoard.update_scores()
	super.enable()


func _update_spotlight() -> void:
	$Control/ScoreBoard.select_score(game.game_state.active_player_idx)
