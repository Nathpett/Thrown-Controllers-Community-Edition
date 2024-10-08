extends ComplexQuestion

var time_limit: int
var questions: Array
var correct_arr: Array = []
var correct_ct: int = 0

@onready var results_hbox = $Control/ResultsHbox
@onready var check_box = $Control/ResultsHbox/Box


func ready_trivia() -> void:
	var trivia_data = get_trivia_data()
	
	questions = trivia_data["questions"]
	time_limit = trivia_data.get("time_limit", 0)
	var instructions = "Answer %s questions in %s seconds.\nget a majority of the questions correct to pass!" % [questions.size(), time_limit]
	
	dialogue.show_text("%s\nTheme: %s" % [instructions, trivia_data["theme"]])
	
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
		submit_answer(false)


func right() -> void:
	if question_started and !dialogue.is_printing() and !question_over:
		submit_answer(true)


func next_lightning() -> void:
	if questions:
		var q = questions.pop_front()
		dialogue.show_text(q[0])
		answer = q[1]
	else:
		conclude_lightning_round()


func move_dialogue(dir_bool: bool, is_correct: bool) -> void:
	var dir: int
	dir = 1 if dir_bool else -1
	
	var copy_dialogue = dialogue.duplicate()
	copy_dialogue.set_script(null)
	add_child(copy_dialogue)
	
	var tween = create_tween()
	var t_time = 0.4
	tween.tween_property(copy_dialogue, "offset_left", 500 * dir, t_time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(copy_dialogue, "offset_right", 500 * dir, t_time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	await tween.finished
	
	var ani_string
	var cor_color = Color.GREEN if is_correct else Color.RED
	var sound = $Correct if is_correct else $Incorrect
	cor_color.a = 0
	
	if dir_bool:
		ani_string = "RightFlash"
		$Control/RightFlash.modulate = cor_color
	else:
		ani_string = "LeftFlash"
		$Control/LeftFlash.modulate = cor_color
	
	sound.play()
	
	$FlashPlayer.play(ani_string)


func submit_answer(submitted_answer) -> void:
	var is_correct = submitted_answer == answer
	move_dialogue(submitted_answer, is_correct)
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
	
	# last four items interval time is twice as much as the last
	var interval = 0.2
	for j in range(1, min(len(correct_arr), 4) + 1):
		interval_times[-j] = interval * pow(2, (min(len(correct_arr), 4) + 1) - j)
		
	i = 0
	for child in results_hbox.get_children():
		child.get_child(0).offset_top = -220
		child.get_child(0).offset_bottom = -220
		tween.tween_property(child.get_child(0), "offset_top", 0, t_time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tween.parallel().tween_property(child.get_child(0), "offset_bottom", 0, t_time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tween.chain().tween_callback($Thunder.play)
		tween.tween_interval(interval_times[i])
		i += 1


func _on_tween_complete(_object, _key) -> void:
	$Thunder.play()


func _on_timer_timeout() -> void:
	var tween = create_tween()
	tween.tween_property($OutOfTime, "offset_top", 0, 1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property($OutOfTime, "offset_bottom", 0, 1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	await tween.finished
	$Thunder.play()
