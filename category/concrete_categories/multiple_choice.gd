extends ComplexQuestion

var answers: Array
var answer_indx
var avatar
var selected_answer
var answered = false

@onready var a1 = $Control/Answers/A1
@onready var a2 = $Control/Answers/A2
@onready var a3 = $Control/Answers/A3
@onready var a4 = $Control/Answers/A4


func ready_trivia() -> void:
	var trivia_data = game.game_state.pop_trivia_data(get_category_type())
	
	answers = trivia_data["answers"]
	answer_indx = trivia_data["answer"]
	question = trivia_data["question"]
	
	avatar = game.avatar.duplicate()
	avatar.visible = true
	add_child(avatar)
	
	avatar.position = Vector2(300, 300)


func initiate_questions() -> void:
	$Control/CategoryTitle.visible = false
	dialogue.show_text(question)
	dialogue.centerify()
	
	var tween = create_tween()
	
	var t_time = 0.5
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(dialogue, "anchor_top", 0.1, t_time)
	tween.parallel().tween_property(dialogue, "anchor_bottom", 0.3, t_time)
	tween.parallel().tween_property(dialogue, "anchor_right", 0.95, t_time)
	tween.parallel().tween_property(dialogue, "anchor_left", 0.05, t_time)
	
	tween.parallel().tween_property(a1, "offset_top", 0, t_time)
	tween.parallel().tween_property(a1, "offset_bottom", 0, t_time)
	
	tween.parallel().tween_property(a2, "offset_left", 0, t_time)
	tween.parallel().tween_property(a2, "offset_right", 0, t_time)
	
	tween.parallel().tween_property(a3, "offset_left", 0, t_time)
	tween.parallel().tween_property(a3, "offset_right", 0, t_time)
	
	tween.parallel().tween_property(a4, "offset_top", 0, t_time)
	tween.parallel().tween_property(a4, "offset_bottom", 0, t_time)
	
	var _answers = answers.duplicate()
	for child in $Control/Answers.get_children():
		child.show_text(_answers.pop_front())


func left() -> void:
	select_answer(a3)


func right() -> void:
	select_answer(a2)


func up() -> void:
	select_answer(a1)


func down() -> void:
	select_answer(a4)


func complx_progress() -> void:
	if !selected_answer:
		return
	
	if answered:
		return
	answered = true
	
	selected_answer.clear_bbcode()
	
	var indx = $Control/Answers.get_children().find(selected_answer)
	var was_correct = indx == answer_indx
	
	print(was_correct)
	var tween = create_tween()
	var t_time = 0.4
	
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	for child in $Control/Answers.get_children():
		if answer_indx != $Control/Answers.get_children().find(child):
			tween.chain().tween_property(child, "offset_top", 450, t_time)
			tween.parallel().tween_property(child, "offset_bottom", 450, t_time)
	tween.chain().tween_callback($Control/Answers.get_children()[answer_indx].push_wave)
	
	tween.chain().tween_interval(3.0)
	
	await tween.finished
	
	if was_correct:
		emit_signal("success")
	else:
		emit_signal("failure")


func select_answer(_selected_answer) -> void:
	if selected_answer:
		selected_answer.clear_bbcode()
	
	selected_answer = _selected_answer
	selected_answer.push_shake()
	avatar.move_to(selected_answer.get_global_position() + Vector2.RIGHT * selected_answer.size.x / 2 + Vector2.UP * 10)

