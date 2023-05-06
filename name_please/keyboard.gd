extends NinePatchRect

signal ok(contestant_name)
signal swap

var alph_matrix = [ "abcdefghi  -#",
					"jklmnopqr  '~",
					"stuvwxyz   ./",
					"0123456789 !|",
					"Γ__ γ_     ?©",
					"             ",
					"Δ__ θ___δ___Ε"]

var keyboard_disabled: bool = true
var names = preload("res://assets/names/name_list.tres")
var longer_ones = {"Γ":"CAPITAL", "γ":"small", "Δ": "Don't Care", "θ":"Swap Avatar", "δ": "Backspace", "Ε":"OK"}
var special_keys = {"Γ":"to_caps", "γ":"to_lower", "Δ": "dont_care", "θ":"_swap", "δ": "backspace", "Ε":"_ok"}
var extra_offset = {"δ": 12, "Ε":12}
var escape_except = {".": "period", "/": "slash"}

var text_base_cell = Vector2(16, 10)
var cursor_base_cell = Vector2(11, 15)
var cursor_matrix_position = Vector2.ZERO # selecting 'a'

var is_upper: bool = true

@onready var second_try = $SecondTry
@onready var cursor = $SecondTry/Cursor
@onready var cursor_timer = $SecondTry/Cursor/Timer
@onready var name_dialogue = $"../NameDialogue"


func _ready() -> void:
	initiate_keys()
	
	move_cursor(cursor_matrix_position)


func _input(event: InputEvent) -> void:
	if keyboard_disabled:
		return
	if event.is_action_pressed("ui_up"):
		directional_move_cursor(Vector2.UP)
	if event.is_action_pressed("ui_down"):
		directional_move_cursor(Vector2.DOWN)
	if event.is_action_pressed("ui_left"):
		directional_move_cursor(Vector2.LEFT)
	if event.is_action_pressed("ui_right"):
		directional_move_cursor(Vector2.RIGHT)
	
	if event.is_action_pressed("ui_select"):
		press_key(alph_matrix[cursor_matrix_position.y][cursor_matrix_position.x])
	
	
	
	if  !event is InputEventKey:
		return
	var just_pressed = !event.is_echo() and event.is_pressed()
	
	if just_pressed:
		var k = event.as_text() # bruteforce time to get that puctuation baby!  what are scancodes I don't know!
		var inp
		match k:
			"Minus":
				inp = "-"
			"Shift+3":
				inp = "#"
			"Apostrophe":
				inp = "'"
			"Shift+QuoteLeft":
				inp = "~"
			"Period":
				inp = "."
			"Slash":
				inp = "/"
			"Shift+1":
				inp = "!"
			"Shift+BackSlash":
				inp = "|"
			"Shift+Slash":
				inp = "?"
			_:
				inp = OS.get_keycode_string(event.keycode)
		
		if len(inp) == 1:
			inp = inp.to_lower()
			for j in len(alph_matrix):
				if alph_matrix[j].find(inp) != -1:
					move_cursor(Vector2(alph_matrix[j].find(inp), j))
			type_char(inp)
	
	if event.keycode == KEY_BACKSPACE and just_pressed:
		backspace()
	
	if event.keycode == KEY_SHIFT and just_pressed:
		to_caps()
	
	if event.keycode == KEY_SHIFT and !event.is_echo() and !event.is_pressed():
		to_lower()
	
	if event.keycode == KEY_ENTER and just_pressed:
		easter_ok()


func press_key(key: String) -> void:
	if special_keys.get(key):
		call(special_keys[key])
	else:
		type_char(key)


func type_char(new_char) -> void:
	$TypeLetterSound.play()
	if is_upper:
		new_char = new_char.to_upper()
	name_dialogue.type_char(new_char)


func backspace() -> void:
	$BackSpaceSound.play()
	name_dialogue.backspace()


func to_caps() -> void:
	$TypeLetterSound.play()
	get_tree().call_group("keyboard_keys", "queue_free")
	is_upper = true
	await get_tree().create_timer(.3).timeout # simulating slow reload when replacing letters
	initiate_keys()


func to_lower() -> void:
	$TypeLetterSound.play()
	get_tree().call_group("keyboard_keys", "queue_free")
	is_upper = false
	await get_tree().create_timer(.3).timeout # simulating slow reload when replacing letters
	initiate_keys()


func _ok() -> void:
	if name_dialogue.has_name():
		$OkSound.play()
		push_ok()


func easter_ok() -> void:
	if name_dialogue.has_name():
		$EasterEggOkSound.play()
		push_ok()


func push_ok() -> void:
#	keyboard_disabled = true
	var contestant_name = name_dialogue.get_contestant_name().to_upper()
	emit_signal("ok", contestant_name)


func dont_care() -> void:
	$TypeLetterSound.play()
	var new_name = names.list[randi() % len(names.list)]
	name_dialogue.set_cur_name(new_name)


func _swap() -> void:
	$TypeLetterSound.play()
	emit_signal("swap")


func directional_move_cursor(vec: Vector2) -> void:
	# play sound if vertical
	if vec.y:
		$CursorVerticalSound.play()
	if vec.x:
		$CursorHorizontalSound.play()
	
	
	var new_position = cursor_matrix_position + vec
	
	# handle overflow using wrap around
	new_position.x = fposmod(new_position.x, len(alph_matrix[0]))
	new_position.y = fposmod(new_position.y, len(alph_matrix))
	
	# Continue on vector path while on blank space, like ice puzzles!
	while alph_matrix[new_position.y][new_position.x] == " ":
		new_position += vec
		new_position.x = fposmod(new_position.x, len(alph_matrix[0]))
		new_position.y = fposmod(new_position.y, len(alph_matrix))
	
	# GO LEFT OR RIGHT IF "_"
	while alph_matrix[new_position.y][new_position.x] == "_":
		var offset = -1 if vec.x <= 0 else 1
		new_position.x += offset # this way if the vector is .RIGHT, we'll go right!
	
	# lol no DRY
	while alph_matrix[new_position.y][new_position.x] == " ":
		new_position += vec
		new_position.x = fposmod(new_position.x, len(alph_matrix[0]))
		new_position.y = fposmod(new_position.y, len(alph_matrix))
	
	move_cursor(new_position)


func move_cursor(_position: Vector2) -> void:
	var text = alph_matrix[_position.y][_position.x]
	cursor.position = cursor_base_cell + 16 * _position + Vector2.RIGHT * extra_offset.get(text, 0)
	cursor_matrix_position = _position


func initiate_keys() -> void:
	var keyboard_key_packed_scene = load("res://name_please/keyboard_key.tscn")
	var cell: Vector2 = Vector2.ZERO
	while true:
		if alph_matrix[cell.y] == "             ":
			cell.y += 1
		var new_key = keyboard_key_packed_scene.instantiate()
		var text = alph_matrix[cell.y][cell.x]
		new_key.position = text_base_cell + 16 * cell + Vector2.RIGHT * extra_offset.get(text, 0)
		new_key.text = longer_ones.get(text, text)
		if is_upper and len(new_key.text) == 1:
			new_key.text = new_key.text.to_upper()
		new_key.add_to_group("keyboard_keys")
		
		second_try.add_child(new_key)
		
		var i = 1
		while alph_matrix[cell.y][int(cell.x + i) % 13] == " " or alph_matrix[cell.y][int(cell.x + i) % 13] == "_":
			i += 1
		
		if cell.x + i < 13:
			cell.x += i
		else:
			if cell.y == 6:
				break
			else:
				cell.x = 0
				cell.y += 1


func _on_Timer_timeout() -> void:
	pass
	
	var region = cursor.get_texture().region
	if region.position.x == 0:
		cursor.get_texture().set_region(Rect2(Vector2(4, 0), region.size))
	else:
		cursor.get_texture().set_region(Rect2(Vector2(0, 0), region.size))

