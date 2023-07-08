extends Sprite2D

signal letters_pushed
signal at_postion
signal touch_letter(letter_vector: Vector2)

enum LETTER_HEIGHT{TOP, SECOND, THIRD, BOTTOM}

var letter_turn_frame: int: set = _set_letter_turn_frame # == 0 or 1
var letter_height: int = 0
var first_letter_x = 27
var right_home_x = 224
var walk_speed = 50 # x pixels per second?


func _process(delta):
	pass


func touch_letters(letter_vectors) -> void:
	if len(letter_vectors) == 0:
		call_deferred("emit_signal", "letters_pushed")
		return
	
	for vector in letter_vectors:
		_seek(first_letter_x + vector.x * 16)
		await self.at_postion
		letter_height = vector.y
		$AnimationPlayer.play("turn_letter")
		await $AnimationPlayer.animation_finished
		emit_signal("touch_letter", vector)
	
	# go to whichever home is closer, left home (0) or right home, and gesticulate
	var right_home_dist = right_home_x - position.x
	if right_home_dist < right_home_x / 2:
		_seek(right_home_x)
	else:
		_seek(0)
	
	await at_postion
	flip_h = position.x == right_home_x
	
	$AnimationPlayer.play("gesticulate")
	
	await $AnimationPlayer.animation_finished
	
	emit_signal("letters_pushed")


func _set_letter_turn_frame(new_value: int) -> void:
	letter_turn_frame = new_value
	frame = 30 + letter_turn_frame + letter_height * 2



func _seek(x_position) -> void:
	$AnimationPlayer.play("walk")
	
	frame = 20 # because playing the walk animation is too slow! we need that frame asap or else it flips the wrong frame and looks ugly!
	flip_h = x_position < position.x
	
	var walk_tween = create_tween()
	var dist = abs(position.x - x_position)
	
	walk_tween.tween_property(self, "position", Vector2(x_position, 0), dist/walk_speed)
	await walk_tween.finished
	
	emit_signal("at_postion")
