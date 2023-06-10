class_name AudioQuestion
extends SimpleQuestion


func progress() -> void:
	super.progress()
	var folder_name = get_category_type()
	$Music.stream = ResourceLoader.load("res://trivia/" + folder_name + "/" + path)
	$Music.play()

