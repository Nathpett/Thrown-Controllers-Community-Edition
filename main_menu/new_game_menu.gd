extends GameScene



func _ready():
	var dir = DirAccess.open("user://trivia")
	for file in dir.get_files():
		$VBoxContainer/TriviaOptionButton.add_item(file.get_basename())


func _on_button_pressed():
	game.new_game($VBoxContainer/GameMode.text, "user://trivia/%s.json" % [$VBoxContainer/TriviaOptionButton.text], $VBoxContainer/ModeOptionButton.selected, $VBoxContainer/OnlyTriviaButton.button_pressed, $VBoxContainer/ShuffelTriviaButton.button_pressed)
