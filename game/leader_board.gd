class_name LeaderBoard
extends GameScene

signal gotten_off_stage

const ITEMS_PER_PAGE: float = 8.0

var interval_time = 0.025
var t_time = 0.4

var page: int = -1:set = _set_page
var players: Array
var avatars: Dictionary = {}
var on_stage: bool = false
var out_items: Array = []
var leaderboard
var complete_tween: Tween
var scores: Array


func _ready():
	super._ready()
	if game:
		leaderboard = game.game_state.leaderboard
	else:
		# TEST LEADERBOARD
		leaderboard = {"JIMBO": {"score": 0, "devil_state": false, "reigon_vector": Vector2(2, 2)},
						"BO": {"score": 0, "devil_state": true, "reigon_vector": Vector2(0, 2)},
						"MBO": {"score": 2, "devil_state": false, "reigon_vector": Vector2(1, 3)},
						"IMBO": {"score": 0, "devil_state": false, "reigon_vector": Vector2(2, 4)},
						"O": {"score": 3, "devil_state": false, "reigon_vector": Vector2(0, 8)},
						"add": {"score": 0, "devil_state": false, "reigon_vector": Vector2(2, 2)},
						"BaadO": {"score": 0, "devil_state": false, "reigon_vector": Vector2(0, 2)},
						"dd": {"score": 2, "devil_state": false, "reigon_vector": Vector2(1, 2)},
						"IMasdadBO": {"score": 0, "devil_state": false, "reigon_vector": Vector2(2, 6)},
						"dsadasdO": {"score": 3, "devil_state": false, "reigon_vector": Vector2(0, 4)},
			}
	
	players = leaderboard.keys()
	players.sort_custom(Callable(self, "_sort_score"))
	
	var avatar_packed = load("res://avatar/avatar.tscn")
	for player in players:
		var new_avatar = avatar_packed.instantiate()
		add_child(new_avatar)
		var player_data = leaderboard[player]
		
		new_avatar.visible = true
		new_avatar.position = $AvatarPosition.position
		new_avatar.reigon_vector = player_data["reigon_vector"]
		if player_data["devil_state"]:
			new_avatar.fast_soulless()
		
		avatars[player] = new_avatar
		var score = leaderboard[player]["score"]
		if !scores.has(score):
			scores.append(score)
	
	scores.sort_custom(Callable(self, "_sort_des"))
	
	var anchor_step = 1.0 / ITEMS_PER_PAGE
	for i in range(ITEMS_PER_PAGE):
		var new_item = $Control/Scores/Item.duplicate()
		new_item.anchor_top = i * anchor_step
		new_item.anchor_bottom = (i + 1) * anchor_step
		$Control/Scores/Control.add_child(new_item)
	
	if players.size():
		page = 0


func _input(event) -> void:
	if complete_tween and complete_tween.is_running():
		return
	if event.is_action_pressed("right"):
		page += 1
	if event.is_action_pressed("left"):
		page -= 1


func _sort_score(a, b) -> bool:
	var a_score = leaderboard[a]["score"]
	var b_score = leaderboard[b]["score"]
	
	return a_score > b_score


func _sort_des(a, b) -> bool:
	return a > b


func _set_page(idx: int) -> void:
	var page_ct = int(ceil(players.size() / ITEMS_PER_PAGE))
	idx = posmod(idx, page_ct)
	if page == idx:
		return
	
	page = idx
	
	if on_stage:
		_move_off_stage()
		await gotten_off_stage
	
	var first_idx = ITEMS_PER_PAGE * page
	var last_idx = min(first_idx + ITEMS_PER_PAGE, len(players))
	
	for i in range(first_idx, last_idx):
		var item_idx = i % int(ITEMS_PER_PAGE)
		var item = $Control/Scores/Control.get_child(item_idx)
		var player = players[i]
		var player_data = leaderboard[player]
		
		item.get_node("Place").text = _get_ord(scores.find(player_data["score"]) + 1)
		item.get_node("Name").text = player
		item.get_node("Score").text = str(player_data["score"])
		
		out_items.append(item)
		
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_interval(interval_time * item_idx)
		tween.tween_property(item, "offset_top", 0, t_time)
		tween.parallel().tween_property(item, "offset_bottom", 0, t_time)
		
#		avatar.move_to(selected_answer.get_global_position() + Vector2.RIGHT * selected_answer.size.x / 2 + Vector2.UP * 10)
		var move_position = item.get_global_position()
		move_position.y -= item.offset_top
		move_position.y += item.size.y / 2
		move_position.x -= 15
		avatars[player].move_to(move_position)
	
	complete_tween = create_tween()
	complete_tween.tween_interval(interval_time * out_items.size() + t_time)
	
	await complete_tween.finished
	
	on_stage = true


func _move_off_stage() -> void:
	var i = 0
	
	out_items.reverse()
	for item in out_items:
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tween.tween_interval(interval_time * i)
		tween.tween_property(item, "offset_top", 250, t_time)
		tween.parallel().tween_property(item, "offset_bottom", 250, t_time)
		i += 1
		
		var player = item.get_node("Name").text # this is hacky but it owkrks
		
		avatars[player].move_to($AvatarPosition.position)
		
	complete_tween = create_tween()
	complete_tween.tween_interval(interval_time * out_items.size() + t_time)
	
	await complete_tween.finished
	
	on_stage = false
	out_items = []
	emit_signal("gotten_off_stage")


func _get_ord(idx: int) -> String:
	var num = str(idx)
	var last_two = int(num.right(2))
	
	if last_two >= 11 and last_two <= 13:
		return num + "th"
	
	var last_one = int(num.right(1))
	if last_one == 1:
		return num + "st"
	if last_one == 2:
		return num + "nd"
	if last_one == 3:
		return num + "rd"
	
	return num + "th"
