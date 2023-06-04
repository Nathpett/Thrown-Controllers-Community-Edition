class_name AudioQuestion
extends SimpleQuestion


func progress() -> void:
	super.progress()
	$Music.stream = ResourceLoader.load("res://trivia/" + path)
	$Music.play()

