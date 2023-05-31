extends GameScene

const ITEMS_PER_PAGE: float = 8.0

var page: int :set = _set_page
var players: Array


func _ready():
	super._ready()
	players = game.game_state.leaderboard.keys()
	players.sort_custom(Callable(self, "_sort_score"))
	
	var avatar_packed = load("res://avatar/avatar.tscn")
	for player in players:
		var new_avatar = avatar_packed.instantiate()
		add_child(new_avatar)
		var player_data = game.game_state.leaderboard[player]
		
		new_avatar.visible = true
		new_avatar.position = Vector2(-50, randi_range(0, 400))
		new_avatar.reigon_vector = player_data["reigon_vector"]
		if player_data["devil_state"]:
			new_avatar.fast_soulless()
	
	page = 0


func _sort_score(a, b) -> bool:
	var a_score = game.game_state.leaderboard[a]["score"]
	var b_score = game.game_state.leaderboard[b]["score"]
	
	return a_score > b_score


func _set_page(idx: int) -> void:
	var page_ct = ceil(players.size() / ITEMS_PER_PAGE)
	idx %= page_ct
	if page == idx:
		return
	
	page = idx
	
	# TODO NEXT Call out old avatars/scores, call in new ones


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
	
	return "AA"
