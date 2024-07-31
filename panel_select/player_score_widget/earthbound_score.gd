extends HBoxContainer

var REGION_SIZE = Vector2(9, 14)
var score: int = 0: set = _set_score
var shown_score: float = 0
var children: Array
var cooldown = 0

@export var cooldown_reset: int = 2

func _ready():
	children = get_children()
	children.reverse()
	set_process(false)
	
	cooldown = cooldown_reset


func _process(delta):
	cooldown -= delta * 60
	if cooldown <= 0:
		cooldown = cooldown_reset
	else:
		return
	
	var dir = sign(score - shown_score)
	
	_tic(dir)
	shown_score += 0.25 * dir
	
	var r_score = 0
	if dir == 1:
		r_score = floor(shown_score)
	else:
		r_score = ceil(shown_score)
	
	if score == r_score:
		set_process(false)


func fast_set_score(_score: int) -> void:
	score = _score
	shown_score = score
	var cur_value: String = '%03d' % floor(shown_score)
	cur_value = cur_value.reverse()
	
	var i = 0
	for child in children:
		var texture: Texture = child.get_texture()
		var new_x = 32 * int(cur_value[i])
		texture.set_region(Rect2(Vector2(new_x, 0), REGION_SIZE))
		i += 1


func _tic(dir: int) -> void:
	var rounded_score
	if dir == 1:
		rounded_score = floor(shown_score)
	else:
		rounded_score = ceil(shown_score)
	
	var cur_value: String = '%03d' % rounded_score # TODO possible to insert variable instead of 3?
	cur_value = cur_value.reverse()
	
	if shown_score == 9:
		pass
	
	var n = int(cur_value[0]) 
	var i = 1 # Number for digits from the right that need changing.
	while (n + dir == -1 or n + dir == 10) and i < len(cur_value):
		if i < len(cur_value):
			n = int(cur_value[i])
		i += 1
	
	var children_to_change = children.slice(0, i)
	
	for child in children_to_change:
		var texture: Texture = child.get_texture()
		var cur_frame = texture.region.position.x
		var next_x = posmod(int(cur_frame / 8) + 1 * dir, 40)  * 8
		texture.set_region(Rect2(Vector2(next_x, 0), REGION_SIZE))


func _set_score(_score) -> void:
	score = _score
	if score != shown_score:
		set_process(true)

