extends ComplexQuestion

var time_limit: int
var questions: Array
var correct_arr: Array = []
var correct_ct: int = 0

@onready var results_hbox = $Control/ResultsHbox
@onready var check_box = $Control/ResultsHbox/Box


func ready_trivia() -> void:
	var trivia_data = game.game_state.pop_trivia_data(get_category_type())
	
	dialogue.show_text(trivia_data["theme"])
	time_limit = trivia_data.get("time_limit", 0)
	questions = trivia_data["questions"]
	
	$Control/LeftLabel.text = trivia_data.left + "\n<-----"
	$Control/RightLabel.text = trivia_data.right + "\n----->"


func initiate_questions() -> void:
	# add enough checkboxes to result_hbox to match number of questions
	# we start with 1 so we only add len - 1
	# because I didn't want to make the checkbox its own scene dangit!
	for _i in range(len(questions) - 1):
		results_hbox.add_child(check_box.duplicate())
	
	# start lightning round
	$Control/Header.start_timer(time_limit)
	$Control/Header/Timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	
	var tween = create_tween()
	var t_time = 1.0
	
	tween.parallel().tween_property($Control/Dialogue, "anchor_left", 0.25, t_time).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property($Control/Dialogue, "anchor_right", 0.75, t_time).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property($Control/LeftLabel, "offset_top", 0, t_time).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property($Control/LeftLabel, "offset_bottom", 0, t_time).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property($Control/RightLabel, "offset_top", 0, t_time).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property($Control/RightLabel, "offset_bottom", 0, t_time).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	dialogue.centerify()
	next_lightning()
	
	$Music.play()


func left() -> void:
	if question_started and !dialogue.is_printing() and !question_over:
		move_dialogue(true)
		submit_answer(true)


func right() -> void:
	if question_started and !dialogue.is_printing() and !question_over:
		move_dialogue(false)
		submit_answer(false)


func next_lightning() -> void:
	if questions:
		var q = questions.pop_front()
		dialogue.show_text(q[0])
		answer = q[1]
	else:
		conclude_lightning_round()


func move_dialogue(dir_bool: bool) -> void:
	var dir: int
	dir = -1 if dir_bool else 1
	
	var copy_dialogue = dialogue.duplicate()
	copy_dialogue.set_script(null)
	add_child(copy_dialogue)
	
	var tween = create_tween()
	var t_time = 0.4
	tween.tween_property(copy_dialogue, "offset_left", 500 * dir, t_time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(copy_dialogue, "offset_right", 500 * dir, t_time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)


func submit_answer(submitted_answer) -> void:
	var is_correct = submitted_answer == answer
	correct_arr.append(is_correct)
	if is_correct:
		correct_ct += 1
	
	next_lightning()


func conclude_lightning_round() -> void:
	$Music.stop()
	question_over = true 
	
	$Control/Header/Timer.stop()
	dialogue.hide()
	results_hbox.show()
	
	var i = 0
	for child in results_hbox.get_children():
		# set to correct texture
		if correct_arr[i]:
			child.get_child(0).texture = load("res://assets/img/check.png")
		else:
			child.get_child(0).texture = load("res://assets/img/x.png")
		i += 1
	
	var tween = create_tween()
	var t_time = 0.5
	var interval_times = []
	for j in range(len(correct_arr)):
		interval_times.append(0.2)
	
	# now make the last four intervals twice as long as the last for that dramatic drop baby!
	# but make the very last one interval time again
	for j in range(min(len(correct_arr), 4)):
		interval_times[-j] = 1 # TODO HERE!
	
	
	i = 0
	for child in results_hbox.get_children():
		child.get_child(0).offset_top = -220
		child.get_child(0).offset_bottom = -220
		tween.tween_property(child.get_child(0), "offset_top", 0, t_time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tween.parallel().tween_property(child.get_child(0), "offset_bottom", 0, t_time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tween.chain().tween_callback($Thunder.play)
		tween.tween_interval(i * 0.2)
		
		i += 1 + 5 * i / len(correct_arr) # this does a dramatic drop with 5 quesitions, but with 10 it could get agonizing, TODO SCALE SOMEHOW HERE SOME DAY!
#	tween.connect("finished", Callable(self, "_on_tween_all_completed"))

#
#func _on_tween_all_completed() -> void:
#	if correct_ct > len(correct_arr) / 2.0:
#		emit_signal("success")
#	else:
#		emit_signal("failure")


func _on_tween_complete(_object, _key) -> void:
	$Thunder.play()


func _on_timer_timeout() -> void:
	var tween = create_tween()
	tween.tween_property($OutOfTime, "offset_top", 0, 1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property($OutOfTime, "offset_bottom", 0, 1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	await tween.finished
	$Thunder.play()
