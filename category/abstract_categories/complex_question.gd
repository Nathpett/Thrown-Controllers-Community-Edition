class_name ComplexQuestion
extends SimpleQuestion

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


# override parent's method to nullifiy them?? nate what sort of sins are you cooking up?
func player_success() -> void:
	pass


func player_failure() -> void:
	pass


func show_answer() -> void:
	pass
