class_name Category
extends GameScene

signal success
signal failure
signal devil_deal

@onready var question_label = $Control/Dialogue/MarginContainer/Label
@onready var dialogue = $Control/Dialogue

var override_trivia_data

func get_transition():
	var transition = super.get_transition()
	transition.text = get_category_type().capitalize()
	
	return transition


func get_title() -> String:
	return get_category_type().replace("_", " ")


func get_category_type() -> String:
	var fil = scene_file_path.get_file()
	return scene_file_path.get_file().left(len(fil) - 5)


func get_trivia_data():
	if override_trivia_data and override_trivia_data.size():
		return override_trivia_data
	return game.game_state.pop_trivia_data(get_category_type())
