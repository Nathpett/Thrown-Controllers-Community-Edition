extends ComplexQuestion


#var alph_matrix = [ "___________",
#					"___________",
#					"___________",
#					"___________"]

#var alph_matrix = [ "__TESTING__",
#					"HEHEHE'S___",
#					"____BUTT___",
#					"____HEAD?__"]

var alph_matrix = "__TESTING__HEHEHE'S_______BUTT_______HEAD?__"


var white_masks = [0, 0, 0, 0]

var default_letters = "rstlne"


func _ready():
	var fortune_letter_packed = load("res://category/concrete_categories/ericas_game/fortune_letter.tscn")
	for i in range(44):
		var new_texture_rect = fortune_letter_packed.instantiate()
#		new_texture_rect.char = alph_matrix[i / 11][i % 11].to_lower()
		new_texture_rect.char = alph_matrix[i].to_lower()
		$Control/TextureRect2/GridContainer.add_child(new_texture_rect)
	
	for letter in default_letters:
		$Control/HUD/Left/DefaultLetters.text += letter + "  "
	
	_push_letters(default_letters)
	for letter in default_letters:
		$Control/HUD/Left/DefaultLetters.visible_characters += 3
		await get_tree().create_timer(0.6).timeout


func _push_letters(letters) -> void:
	var letter_vectors = []
	
	for letter in letters:
		letter_vectors += _get_letter_vectors(alph_matrix, letter)
	
	letter_vectors.sort()
	print(letter_vectors)
	
#	$Vanna.touch_letters(letter_vectors)
	
	for vector in letter_vectors:
		var idx = vector.x + vector.y * 11
		var fortune_letter = $Control/TextureRect2/GridContainer.get_child(idx)
		
		$LetterSound.play()
		fortune_letter.is_blue = true
		await get_tree().create_timer(1).timeout


func _get_letter_vectors(text: String, letter: String) -> Array:
	var letter_vectors = []
	text = text.to_lower()
	var i = 0
	for char in text:
		if char == letter:
			letter_vectors.append(Vector2i(i % 11, i / 11))
		i += 1
	return letter_vectors
