extends HBoxContainer

var REGION_SIZE = Vector2(9, 14)

var score: int = 0: set = _set_score
var shown_score: float = 0
var children: Array
var cooldown = 0
var cooldown_reset = 4

func _ready():
	children = get_children()
	children.reverse()
	set_process(false)
	
	cooldown = cooldown_reset
	
	await get_tree().create_timer(3).timeout
	self.score = 11
	#await get_tree().create_timer(19).timeout
	#self.score = 100
	#await get_tree().create_timer(3).timeout
	#self.score = 90
	#await get_tree().create_timer(3).timeout
	#self.score = 24
	#await get_tree().create_timer(3).timeout
	#self.score = 7


func _process(delta):
	cooldown -= delta * 60
	if cooldown <= 0:
		cooldown = cooldown_reset
	else:
		return
	
	var dir = sign(score - shown_score)
	
	_tic(dir)
	shown_score += 0.25
	
	if score == floor(shown_score):
		set_process(false)


func _tic(dir: int) -> void:
	var cur_value = str(floor(shown_score)).reverse()
	
	if shown_score == 9:
		pass
	
	var n = int(cur_value[0]) 
	var i = 1 # Number for digits from the right that need changing.
	while (n + dir == -1 or n + dir == 10) and i < len(cur_value):
		n = int(cur_value[i])
		i += 1
	
	var children_to_change = children.slice(0, i)
	
	for child in children_to_change:
		var texture: Texture = child.get_texture()
		var cur_frame = texture.region.position.x
		var next_x = ((int(cur_frame / 8) + 1) % 40)  * 8
		texture.set_region(Rect2(Vector2(next_x, 0), REGION_SIZE))
		print(shown_score)
		
		i -= 1
	
	


func _set_score(_score) -> void:
	score = _score
	if score != shown_score:
		set_process(true)

