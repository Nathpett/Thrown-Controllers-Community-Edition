extends ComplexQuestion

# by design this will have to be exhausted manually! it's more on the host to navigate that.

var cursor_idx = 0
var editor_trg_challenge_indexes: Dictionary = {}

func ready_trivia() -> void:
	var trivia_data = get_trivia_data()
	var texture_rect = $Control/Heads/TextureRect
	for data in trivia_data:
		var host = data["host"]
		var new_texture_rect = texture_rect.duplicate()
		$Control/Heads.add_child(new_texture_rect)
		# try to set texture using default names
		var new_texture = load("res://trivia/TheRunawayGuys_video_game_challenge/%s.png" % [host])
		if is_instance_valid(new_texture):
			new_texture_rect.texture = new_texture
		new_texture_rect.name = host
	
	texture_rect.free()


func get_trivia_data():
	if override_trivia_data and override_trivia_data.size():
		return override_trivia_data
	return game.game_state.trivia.get("TheRunawayGuys_video_game_challenge")


func initiate_questions() -> void:
	var tween = create_tween()
	var t_time = 1.0
	
	tween.parallel().tween_property($Control/Dialogue, "anchor_top", 0.75, t_time).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	dialogue.centerify()
	dialogue.show_text("select someone to recieve a challenge from!")
	
	$Cursor.visible = true
	$Control/Heads.visible = true
	
	call_deferred("update_cursor")


func complx_progress() -> void:
	var selected_host = $Control/Heads.get_child(cursor_idx)
	var host = selected_host.name 
	var trivia_data = get_trivia_data() 
	
	# ugly solution, but this is what happens when you want all trivia data to be elements in a list nate!
	var host_challenges: Array
	for data in trivia_data:
		if data["host"] == host:
			host_challenges = data["challenges"]
			break
	
	# indexes will be saved in game if we're not in editor mode, if we are in editor mode they'll be saved locally in editor_trg_challenge_indexes
	var challenge_idx
	if !game.main.editor_mode:
		challenge_idx = game.game_state.trg_challenge_indexes[host]
	else:
		challenge_idx = editor_trg_challenge_indexes.get(host, 0)
	
	dialogue.show_text("%s's challenge:\n%s" % [host.capitalize(), host_challenges[challenge_idx]])
	challenge_idx += 1
	challenge_idx %= host_challenges.size()
	
	if !game.main.editor_mode:
		game.game_state.trg_challenge_indexes[host] = challenge_idx
	else:
		editor_trg_challenge_indexes[host] = challenge_idx


func left() -> void:
	cursor_idx = posmod(cursor_idx - 1, $Control/Heads.get_children().size())
	update_cursor()


func right() -> void:
	cursor_idx = posmod(cursor_idx + 1, $Control/Heads.get_children().size())
	update_cursor()


func player_success() -> void:
	emit_signal("success")


func player_failure() -> void:
	emit_signal("failure")


func update_cursor() -> void:
	var child = $Control/Heads.get_child(cursor_idx)
	$Cursor.position = child.get_global_position() + Vector2(1.0, -0.1) * (child.size.x / 2)

