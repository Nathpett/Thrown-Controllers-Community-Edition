class_name AudioQuestion
extends SimpleQuestion

func ready_trivia() -> void:
	super.ready_trivia()
	$AudioStreamPlayer.stream = load("res://trivia/" + path)


func progress() -> void:
	super.progress()
	$AudioStreamPlayer.play()

