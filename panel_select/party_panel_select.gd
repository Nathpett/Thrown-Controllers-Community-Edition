extends PanelSelect


func _ready():
	super._ready()
	
	if game.game_state.active_player_idx == -1:
		game.game_state.active_player_idx = 0
	
	game.game_state.active_player = game.game_state.playing_players[game.game_state.active_player_idx]
	$Control/ScoreBoard/HBoxContainer.get_child(game.game_state.active_player_idx).is_active = true
	
	game.game_state.lagging_players = game.game_state.players.duplicate(true)
	
	await animation_finished
	
	var i = 0
	for player_enum in game.game_state.playing_players:
		var widget = $Control/ScoreBoard/HBoxContainer.get_child(i)
		widget.set_score(game.game_state.players[player_enum]["score"])
		i += 1
	
	
