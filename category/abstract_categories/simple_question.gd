class_name SimpleQuestion
extends Category


const DOUBLE_TAP_TIME:float = 0.2

var cooldown_timers: Dictionary = {}  # <action name> : Timer
var question: String
var answer
var path: String


func _ready() -> void:
	super._ready()
	if game:
		var trivia_data = game.pop_trivia_data(get_category_type())
		ready_trivia(trivia_data)


func _input(event: InputEvent) -> void:
	if scene_disabled:
		return
	
	if event.is_action_pressed("correct_answer"):
		if is_double_tap("correct_answer"):
			player_success()
		else:
			register_double_tap("correct_answer")
	
	if event.is_action_pressed("incorrect_answer"):
		if is_double_tap("incorrect_answer"):
			player_failure()
		else:
			register_double_tap("incorrect_answer")
	
	if event.is_action_pressed("show_answer"):
		if is_double_tap("show_answer"):
			show_answer()
		else:
			register_double_tap("show_answer")
	
	if event.is_action_pressed("progress"):
		progress()
	
	if event.is_action_pressed("left"):
		left()
	
	if event.is_action_pressed("right"):
		right()
	
	if event.is_action_pressed("up"):
		up()
	
	if event.is_action_pressed("down"):
		down()



func register_double_tap(action:String) -> void:
	if cooldown_timers.get(action, false):
		cooldown_timers[action].free()
	
	var timer:Timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_on_double_tap_timeout"))
	timer.start(DOUBLE_TAP_TIME)
	cooldown_timers[action] = timer


func is_double_tap(action:String) -> bool:
	return cooldown_timers.has(action)


func ready_trivia(trivia_data):
	if trivia_data:
		question = trivia_data["question"]
		answer = trivia_data.get("answer", trivia_data["question"])
		path = trivia_data.get("path", "")


func player_success() -> void:
	emit_signal("success")


func player_failure() -> void:
	emit_signal("failure")


func show_answer() -> void:
	dialogue.show_text(answer)
#	question_label.text = answer


func left() -> void:
	pass


func right() -> void:
	pass


func up() -> void:
	pass


func down() -> void:
	pass


func progress() -> void:
	if dialogue.is_printing():
		dialogue.show_all()
		return
	else:
		dialogue.show_text(question)


func _on_double_tap_timeout() -> void:
	for action in cooldown_timers.duplicate(): # just check every timer lol
		if !cooldown_timers[action].time_left:
			cooldown_timers[action].queue_free()
			cooldown_timers.erase(action)
		
