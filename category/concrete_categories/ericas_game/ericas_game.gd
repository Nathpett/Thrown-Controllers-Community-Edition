extends ComplexQuestion

enum {INITIAL, INPUT, TIME_TO_ANSWER}

signal complex_progress_done
signal letters_pushed

var alph_matrix = "___________HE__________HE______________HE?__"
var hint = "Phrase"
var default_letters = "rstlne"
var remaining_letters = "abcdefghijklmnopqrstuvwxyz"
var complex_index = 0



func _ready():
	super._ready()
	
	$Node2D/Vanna.connect("touch_letter", Callable(self, "_on_vanna_touch_letter"))


func _input(event):
	if complex_index != INPUT:
		super._input(event)
		return
	
	if  !event is InputEventKey:
		return
	
	var player_letters = $Control/HUD/Right/PlayerLetters
	var just_pressed = !event.is_echo() and event.is_pressed()
	
	if just_pressed:
		var k = event.as_text()
		if len(k) == 1 and _can_push(k):
			player_letters.text += k + "  "
	
	if event.keycode == KEY_BACKSPACE and just_pressed:
		player_letters.text = player_letters.text.left(len(player_letters.text) - 3)
	
	if event.keycode == KEY_ENTER and just_pressed and len(player_letters.text) == 12:
		var letters_to_push = player_letters.text
		letters_to_push = letters_to_push.replace(" ", "").to_lower()
		_push_letters(letters_to_push)
		
		await self.letters_pushed
		
		complex_index = TIME_TO_ANSWER
		complx_progress()



func _can_push(k: String) -> bool:
	var player_letters = $Control/HUD/Right/PlayerLetters
	if len(player_letters.text) == 12:
		return false
	if player_letters.text.contains(k):
		return false
	if !remaining_letters.contains(k.to_lower()):
		return false
	if len(player_letters.text) == 9 and !"AEIOU".contains(k):
		return false
	if len(player_letters.text) < 9 and "AEIOU".contains(k):
		return false
	return true


func initiate_questions() -> void:
	var fortune_letter_packed = load("res://category/concrete_categories/ericas_game/fortune_letter.tscn")
	for i in range(44):
		var new_texture_rect = fortune_letter_packed.instantiate()
		new_texture_rect.char = alph_matrix[i].to_lower()
		$Control/TextureRect2/GridContainer.add_child(new_texture_rect)
	for letter in default_letters:
		$Control/HUD/Left/DefaultLetters.text += letter + "  "


func complx_progress() -> void:
	disable()
	match complex_index:
		INITIAL:
			$Control/HUD/Left/Hint.text = hint
			for letter in default_letters:
				$Control/HUD/Left/DefaultLetters.visible_characters += 3
				await get_tree().create_timer(0.6).timeout
			_push_letters(default_letters)
			await self.letters_pushed
			complex_index = INPUT
			enable()
		INPUT: # validate input letters, push them
			pass
		TIME_TO_ANSWER:
			# Start timer, play music
			pass


func _push_letters(letters) -> void:
	var letter_vectors = []
	
	for letter in letters:
		letter_vectors += _get_letter_vectors(alph_matrix, letter)
		remaining_letters = remaining_letters.replace(letter, "")
	
	letter_vectors.sort()
	# if vanna is standing on the right, reverse the letter vectors
	if $Node2D/Vanna.position.x == $Node2D/Vanna.right_home_x:
		letter_vectors.reverse()
	
	$Node2D/Vanna.touch_letters(letter_vectors)
	
	for vector in letter_vectors:
		var idx = vector.x + vector.y * 11
		var fortune_letter = $Control/TextureRect2/GridContainer.get_child(idx)
		
		$LetterSound.play()
		fortune_letter.is_blue = true
		await get_tree().create_timer(0.5).timeout
	emit_signal("letters_pushed")


func _get_letter_vectors(text: String, letter: String) -> Array:
	var letter_vectors = []
	text = text.to_lower()
	var i = 0
	for char in text:
		if char == letter:
			letter_vectors.append(Vector2i(i % 11, i / 11))
		i += 1
	return letter_vectors


func _on_vanna_touch_letter(letter_vector: Vector2) -> void:
	print(letter_vector)
	var idx = letter_vector.x + letter_vector.y * 11
	var touched_letter = $Control/TextureRect2/GridContainer.get_child(idx)
	touched_letter.reveal()
