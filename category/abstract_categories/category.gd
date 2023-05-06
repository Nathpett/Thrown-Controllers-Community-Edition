class_name Category
extends GameScene

signal success
signal failure
signal devil_deal

@onready var question_label = $Control/Dialogue/MarginContainer/Label
@onready var dialogue = $Control/Dialogue


func get_transition():
	var transition = super.get_transition()
	transition.text = get_category_type()
	
	return transition


func get_title() -> String:
	return get_category_type().replace("_", " ")


func get_category_type() -> String:
	var fil = scene_file_path.get_file()
	return scene_file_path.get_file().left(len(fil) - 5)
