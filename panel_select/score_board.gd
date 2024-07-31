extends GameScene



@export var is_highlight_active_player: bool = true


func _ready():
	super._ready()
	
	var player_score_widget_packed = load("res://panel_select/player_score_widget/player_score_widget.tscn")
	
	if !is_instance_valid(game):
		return
	
	for player_enum in game.game_state.playing_players:
		var new_widget = player_score_widget_packed.instantiate()
		$HBoxContainer.add_child(new_widget)
		new_widget.initiate(player_enum)
	
	if game.game_state.active_player_idx == -1:
		game.game_state.active_player_idx = 0
	
	game.game_state.active_player = game.game_state.playing_players[game.game_state.active_player_idx]
	if is_highlight_active_player:
		$HBoxContainer.get_child(game.game_state.active_player_idx).is_active = true
	
	game.game_state.lagging_players = game.game_state.players.duplicate(true)


func select_score(idx: int) -> void:
	var child = $HBoxContainer.get_child(idx)
	child.is_active = true
	$Spotlight.visible = true
	$Spotlight.position = Vector2(child.avatar.global_position.x, $Spotlight.position.y)
	$SpotLightSound.play()


func kill_spotlight() -> void:
	var child = $HBoxContainer.get_child(game.game_state.active_player_idx)
	child.is_active = false
	$Spotlight.visible = false


func update_scores() -> void:
	var i = 0
	for player_enum in game.game_state.playing_players:
		var widget = $HBoxContainer.get_child(i)
		widget.set_score(game.game_state.players[player_enum]["score"])
		i += 1

