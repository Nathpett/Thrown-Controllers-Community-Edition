class_name AudioQuestion
extends SimpleQuestion

func ready_trivia(trivia_data) -> void:
	super.ready_trivia(trivia_data)
	$AudioStreamPlayer.stream = load("res://trivia/" + path)


func progress() -> void:
	super.progress()
	$AudioStreamPlayer.play()

