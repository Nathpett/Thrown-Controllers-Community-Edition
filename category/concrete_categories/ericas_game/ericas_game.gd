extends ComplexQuestion

enum {INITIAL, INPUT, TIME_TO_ANSWER, COUNT_DOWN}

signal complex_progress_done

# TODO BUG! one can spam enter after submitting letters lol

var alph_matrix = "___________HE__________HE______________HE?__"
var hint = "Phrase"
var default_letters = "rstlne"
var remaining_letters = "abcdefghijklmnopqrstuvwxyz"
var complex_index = 0



func _ready():
	super._ready()
	
	$Node2D/Vanna.connect("touch_letter", Callable(self, "_on_vanna_touch_letter"))


func _input(event):
	if !(complex_index == INPUT or complex_index == COUNT_DOWN):
		super._input(event)
		return
	
	match complex_index:
		INPUT:
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
				
				await $Node2D/Vanna.letters_pushed
				
				$TimeToSolve.play()
				await $TimeToSolve.finished
				
				$Music.play()
				
				complex_index = TIME_TO_ANSWER
				complx_progress()
		COUNT_DOWN:
			super._input(event)


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


func ready_trivia():
	var trivia_data = get_trivia_data()
	if trivia_data:
		hint = trivia_data["hint"]
		var answer: String = trivia_data["answer"]
		alph_matrix = ""
		for line in answer.split("\n"):
			alph_matrix += line.left(11)
			while len(alph_matrix) % 11 != 0:
				alph_matrix += "_"
		while len(alph_matrix) < 44:
			alph_matrix += "_"


func initiate_questions() -> void:
	var fortune_letter_packed = load("res://category/concrete_categories/ericas_game/fortune_letter.tscn")
	for i in range(44):
		var new_texture_rect = fortune_letter_packed.instantiate()
		new_texture_rect.char = alph_matrix[i].to_lower()
		$Control/TextureRect2/GridContainer.add_child(new_texture_rect)
	for letter in default_letters:
		$Control/HUD/Left/DefaultLetters.text += letter + "  "


func complx_progress() -> void:
	match complex_index:
		INITIAL:
			disable()
			$Control/HUD/Left/Hint.text = hint
			for letter in default_letters:
				$Control/HUD/Left/DefaultLetters.visible_characters += 3
				await get_tree().create_timer(0.6).timeout
			_push_letters(default_letters)
			await $Node2D/Vanna.letters_pushed
			
			$ThreeCons.play()
			await $ThreeCons.finished
			
			complex_index = INPUT
			enable()
		INPUT: # validate input letters, push them
			pass
		TIME_TO_ANSWER:
			manual_validation = true
			showable_answer = true
			$Control/Header.start_timer(30)
			$Control/Header/Timer.connect("timeout", Callable(self, "_on_timer_timeout"))
			complex_index = COUNT_DOWN
		COUNT_DOWN:
			pass


func show_answer() -> void:
	$Control/Header/Timer.stop()
	$Music.stop()
	# get list of all indexes of unrevealed letters
	var remain_idxs: Array = []
	var i = 0
	for char in alph_matrix:
		if remaining_letters.contains(char.to_lower()):
			remain_idxs.append(i)
		i += 1
	
	for idx in remain_idxs:
		var letter = $Control/TextureRect2/GridContainer.get_child(idx)
		letter.reveal()
		await get_tree().create_timer(0.25).timeout


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
	var idx = letter_vector.x + letter_vector.y * 11
	var touched_letter = $Control/TextureRect2/GridContainer.get_child(idx)
	touched_letter.reveal()


func _on_timer_timeout() -> void:
	pass # TODO TIMES UP VANNA SOUND
