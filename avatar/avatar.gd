class_name Avatar
extends Node2D

signal soulless
signal done_moving

const SPRITE_STEP: Vector2 = Vector2(68, 50) # size of each sharacters sprite sheet in the whole NPC sprite sheet

enum Facing{UP, RIGHT, DOWN, LEFT}

var contestant_name = ""
var reigon_vector: Vector2: set = _set_reigon_vector
var facing: int: set = _set_facing
var is_walking: bool: set = _set_walking
var move_tween: Tween
var game

@onready var sprite = $Sprite2D


func _ready() -> void:
	$CPUParticles2D.emitting = false # since this lets us turn it on faster
	self.is_walking = true
	
	# look up the tree until we find the game lol
	var parent = get_parent()
	while not parent is Main and is_instance_valid(parent):
		parent = parent.get_parent()
	if is_instance_valid(parent):
		game = parent.game
	
	sprite.region_rect = Rect2(reigon_vector * SPRITE_STEP, SPRITE_STEP)


func randomize_character() -> void: #_fruits[randi() % _fruits.size()]
	self.reigon_vector = game.game_state.available_reigon_vectors[randi() % game.game_state.available_reigon_vectors.size()]


func _set_reigon_vector(new_reigon_vector) -> void:
	reigon_vector = new_reigon_vector
	if is_instance_valid(get_parent()):
		sprite.region_rect = Rect2(reigon_vector * SPRITE_STEP, SPRITE_STEP)


# actually remove the reigon vector from available_reigon_vectors
func confirm_character() -> void:
	var idx = game.game_state.available_reigon_vectors.find(reigon_vector)
	if idx != -1:
		game.game_state.available_reigon_vectors.remove_at(idx)


func advance_animation() -> void:
	# if odd, reduce by 1, else advance frame by 1,
	if sprite.frame % 2:
		sprite.frame -= 1
	else:
		sprite.frame += 1


func move_to(_position, walk_speed: float = 100, end_facing: int = Facing.DOWN) -> void:
	if move_tween:
		move_tween.kill()
	move_tween = create_tween()
	
	# I'm sure there's a more elegant way to do this.  But I'm not too smart.
	var angle = (position - _position).normalized().angle()
	angle = posmod(angle, TAU)
	if angle > PI/4 and angle <= 3 * PI/4:
		self.facing = Facing.UP
	elif angle > 3 * PI/4 and angle <= 5 * PI/4:
		self.facing = Facing.RIGHT
	elif angle > 5 * PI/4 and angle <= 7 * PI/4:
		self.facing = Facing.DOWN
	else:
		self.facing = Facing.LEFT
	
	var dist = position.distance_to(_position)
	
	move_tween.tween_property(self, "position", _position, dist / walk_speed)
	move_tween.set_trans(Tween.TRANS_LINEAR)
	
	await move_tween.finished
	
	self.facing = end_facing
	emit_signal("done_moving")


func become_soulless() -> void:
	var tween = create_tween()
	tween.parallel().tween_property($Sprite2D.get_material(), "shader_parameter/progress", 1.0, 7.0)
	tween.parallel().tween_method(Callable(self, "_shake"), 0, 0, 7.0)
	
	$AudioStreamPlayer2D.play()
	$CPUParticles2D.emitting = true
	
	await tween.finished
	
	$Sprite2D.position = Vector2.ZERO
	$CPUParticles2D.emitting = false
	
	emit_signal("soulless")


func fast_soulless() -> void:
	$Sprite2D.get_material().set_shader_parameter("progress", 1.0)


func souledded() -> void:
	$Sprite2D.get_material().set_shader_parameter("progress", 0.0)


func _shake(_a) -> void:
	$Sprite2D.position = randf_range(0, 2) * Vector2.RIGHT.rotated(randf_range(0, TAU))


func _set_facing(new_facing) -> void:
	facing = new_facing
	sprite.frame = facing * 2


func _on_Timer_timeout() -> void:
	advance_animation()
	$Sprite2D/Timer.start()


func _set_walking(new_value: bool) -> void:
	if is_walking == new_value:
		return
	is_walking = new_value
	if is_walking:
		$Sprite2D/Timer.start()
	else:
		$Sprite2D/Timer.stop()
