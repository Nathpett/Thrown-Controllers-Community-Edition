extends ComplexQuestion

var withdrawn_callenges: Array
var challenges_visible: int = 0
var cursor_idx = 0
var selected_idx = -1

func ready_trivia() -> void:
	withdrawn_callenges = []
	
	for i in range(3):
		var trivia_data = game.game_state.pop_trivia_data(get_category_type())
		if trivia_data: 
			withdrawn_callenges.append(trivia_data)
		else:
			$Control2.get_child(i).queue_free()


func initiate_questions() -> void:
	var tween = create_tween()
	var t_time = 0.5
	
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(dialogue, "anchor_top", 1.0, t_time)
	tween.parallel().tween_property(dialogue, "anchor_bottom", 1.3, t_time)
	tween.parallel().tween_property(dialogue, "anchor_right", 0.6, t_time)
	tween.parallel().tween_property(dialogue, "anchor_left", 0.3, t_time)


func complx_progress() -> void:
	if challenges_visible != $Control2.get_children().size():
		show_challenge()
	else:
		select_idx()


func up() -> void:
	cursor_idx = posmod(cursor_idx - 1, $Control2.get_children().size())
	update_cursor()


func down() -> void:
	cursor_idx = posmod(cursor_idx + 1, $Control2.get_children().size())
	update_cursor()


func show_challenge() -> void:
	if challenges_visible == $Control2.get_children().size():
		return
	
	var child = $Control2.get_child(challenges_visible)
	var tween = create_tween()
	
	var t_time = 0.5
	
	tween.parallel().tween_property(child, "offset_top", 0, t_time)
	tween.parallel().tween_property(child, "offset_bottom", 0, t_time)
	
	var challenge = withdrawn_callenges[challenges_visible]
	child.show_text("%s - Challenge: %s" % [challenge["game"], challenge["challenge"]])
	
	challenges_visible += 1
	
	if challenges_visible == $Control2.get_children().size():
		await tween.finished
		activate_cursor()


func activate_cursor() -> void:
	$Cursor.visible = true
	update_cursor()


func update_cursor() -> void:
	var child = $Control2.get_child(cursor_idx)
	$Cursor.position = child.get_global_position() + Vector2(-0.5, 1) * (child.size.y / 2)


func select_idx() -> void:
	if selected_idx != -1:
		var child = $Control2.get_child(selected_idx)
		child.clear_bbcode()
	else:
		$Music.stream = load("res://assets/sound/music/04 Course Map Select.mp3")
		$Music.play()
	
	selected_idx = cursor_idx
	
	var child = $Control2.get_child(selected_idx)
	child.push_shake()


# puts unused challenges back in trivia
func deposit_challenges() -> void:
	var i = withdrawn_callenges.size() - 1
	withdrawn_callenges.reverse()
	for chal in withdrawn_callenges:
		if i != selected_idx:
			game.game_state.deposit_trivia_data(get_category_type(), chal)
		i -= 1


func player_success() -> void:
	if selected_idx != -1:
		deposit_challenges()
		emit_signal("success")


func player_failure() -> void:
	if selected_idx != -1:
		deposit_challenges()
		emit_signal("failure")
