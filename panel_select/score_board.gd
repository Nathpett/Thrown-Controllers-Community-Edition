extends GameScene



func _ready():
	super._ready()
	
	var player_score_widget_packed = load("res://panel_select/player_score_widget/player_score_widget.tscn")
	for player_enum in game.game_state.playing_players:
		var new_widget = player_score_widget_packed.instantiate()
		$HBoxContainer.add_child(new_widget)
		new_widget.initiate(player_enum)


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
