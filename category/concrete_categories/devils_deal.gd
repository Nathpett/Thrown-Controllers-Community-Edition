extends ComplexQuestion

var avatar: Avatar
var selected_element

func initiate_questions() -> void:
	avatar = game.avatar.duplicate()
	avatar.apply_scale(3 * Vector2.ONE)
	avatar.position = Vector2(-50,$Control.size.y/2)
	avatar.visible = true
	add_child(avatar)
	
	avatar.move_to(Vector2($Control.size.x/2, $Control.size.y/2), 400)
	
	var tween = create_tween()
	var t_time = 0.5
	
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(dialogue, "anchor_top", 1.0, t_time)
	tween.parallel().tween_property(dialogue, "anchor_bottom", 1.3, t_time)
	tween.parallel().tween_property(dialogue, "anchor_right", 0.6, t_time)
	tween.parallel().tween_property(dialogue, "anchor_left", 0.3, t_time)
	
	tween.parallel().tween_property($Control/Deal, "offset_left", 0, t_time)
	tween.parallel().tween_property($Control/Deal, "offset_right", 0, t_time)
	
	tween.parallel().tween_property($Control/NoDeal, "offset_left", 0, t_time)
	tween.parallel().tween_property($Control/NoDeal, "offset_right", 0, t_time)
	
	$Control/NoDeal.show_text("NO DEAL")
	$Control/Deal.show_text("DEAL")
	
	$Control/Dialogue/MarginContainer/Label.text = ""
	
	var music_stream
	if game.game_state.current_contestant_score < 5:
		music_stream = load("res://assets/sound/music/04. Questioning ~ Moderato 2001.mp3")
	else:
		music_stream = load("res://assets/sound/music/07. Questioning ~ Allegro 2001.mp3")
	$Music.stream = music_stream
	$Music.play()


func complx_progress() -> void:
	if !selected_element:
		return
	
	scene_disabled = true # no more input!
	
	if selected_element == $Control/NoDeal:
		emit_signal("devil_deal", false)
	else:
		avatar.become_soulless()
		await avatar.soulless
		await get_tree().create_timer(3).timeout
		emit_signal("devil_deal", true)


func right() -> void:
	_select_answer($Control/NoDeal)


func left() -> void:
	_select_answer($Control/Deal)


func _select_answer(_selected_element) -> void:
	if !question_started or _selected_element == selected_element:
		return
	
	if selected_element:
		selected_element.clear_bbcode()
	
	selected_element = _selected_element
	selected_element.push_shake()
	
	var point: Transform2D
	if selected_element == $Control/NoDeal:
		point = $NoDealPoint.transform
	else:
		point = $DealPoint.transform
	
	var tween = create_tween()
	var t_time = 0.4
	tween.tween_property($Blinker, "transform", point, t_time)
