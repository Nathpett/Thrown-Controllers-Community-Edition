class_name ComplexQuestion
extends SimpleQuestion

@export var manual_validation: bool = false

var question_started: bool = false
var question_over: bool = false
# parent to lightning round and multiple choice, just some things those two will have in common that I felt needed abstraction


func progress() -> void:
	if dialogue.is_printing():
		dialogue.show_all()
		return
	
	if !question_started:
		question_started = true
		initiate_questions()
	else: 
		dialogue.show_all()
		complx_progress()


func initiate_questions() -> void:
	pass


func complx_progress() -> void:
	pass


func player_success() -> void:
	if manual_validation:
		super.player_success()


func player_failure() -> void:
	if manual_validation:
		super.player_failure()


func show_answer() -> void:
	pass
