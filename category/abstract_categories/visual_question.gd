class_name VisualQuestion
extends SimpleQuestion


@onready var color_rect = $Control/CategoryTitle/ColorRect
@onready var texture_rect: TextureRect = $Control/CategoryTitle/TextureRect


func progress() -> void:
	super.progress()
	color_rect.show()
	texture_rect.show()
	var folder_name = get_category_type()
	texture_rect.texture = load("res://trivia/" + folder_name  + "/" +  path)


func show_answer() -> void:
	super.show_answer()
	texture_rect.material = null
