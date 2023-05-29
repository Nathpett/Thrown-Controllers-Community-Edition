class_name AudioQuestion
extends SimpleQuestion

func ready_trivia() -> void:
	super.ready_trivia()
	#$TriviaAudio.stream = load("user://trivia/" + path)
	$TriviaAudio.stream = ResourceLoader.load("res://trivia/" + path)


func progress() -> void:
	super.progress()
	$TriviaAudio.play()

