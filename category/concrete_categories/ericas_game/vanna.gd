extends Sprite2D

signal at_letter


enum LETTER_HEIGHT{TOP, SECOND, THIRD, BOTTOM}

var letter_turn_frame: int: set = _set_letter_turn_frame # == 0 or 1
var letter_height: int = 0
var first_letter_x = 27



func _process(delta):
	pass



func touch_letters(letter_vectors) -> void:
	for vector in letter_vectors:
		_seek(vector.x)
		await at_letter


func _set_letter_turn_frame(new_value: int) -> void:
	letter_turn_frame = new_value
	frame = 30 + letter_turn_frame + letter_height * 2


func _seek(x: int) -> void:
	$AnimationPlayer.play("walk")
	emit_signal("at_letter")
