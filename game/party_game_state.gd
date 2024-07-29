class_name PartyGameState
extends GameState

enum Players{DAD, SAV, SHEN, ALEX, NATE}

@export var players: Dictionary = {
	Players.DAD: {"name": "Dad"},
	Players.SAV: {"name": "Sav"},
	Players.SHEN: {"name": "Shen"},
	Players.ALEX: {"name": "Alex"},
	Players.NATE: {"name": "Nate"}
}

@export var lagging_players: Dictionary = {} # lagging dictionary to use to see what the scores were before they changed!
@export var playing_players: Array = []
@export var active_player_idx: int = -1
@export var active_player: int


func initiate(trivia_path: String, initial_mode: int, _fast_mode: bool = false, shuffle_trivia: bool = false) -> void:
	super.initiate(trivia_path, initial_mode, _fast_mode, shuffle_trivia)
	lagging_players = players.duplicate(true)


func iterate_player(dir: int = 1) -> void:
	active_player_idx = posmod(active_player_idx + dir, playing_players.size())


func cycle_player() -> void:
	active_player_idx += 1
	if active_player_idx >= playing_players.size():
		active_player_idx = 0
		playing_players.shuffle()
	active_player = playing_players[active_player_idx]


func import_new_questions() -> void: # TODO, check party trivia, import new ones on load?
	pass


func new_category_queue() -> Array:
	var new_queue = super.new_category_queue()
	
	new_queue.erase("devils_deal")
	
	return new_queue


func add_player(player_enum: int, player_name: String, reigon_vector: Vector2i):
	# if player is overwriting reigon vector, free that vector.
	if players[player_enum].has("reigon_vector"):
		var prev_reigon_vector = players[player_enum]["reigon_vector"]
		available_reigon_vectors.append(prev_reigon_vector)
	
	if !playing_players.has(player_enum):
		playing_players.append(player_enum)
	
	players[player_enum] = {"name": player_name, "reigon_vector": reigon_vector, "score": 0}


func on_success() -> void:
	var base_value = CategoryStatics.get_party_value(current_category)
	players[active_player]["score"] += base_value
	#var earned_points = 0 # TODO 
	
	#current_contestant_score += max(point_gain, temp_point_gain)
	#temp_point_gain = 0


func on_failure() -> void:
	pass
	#push_current_to_leaderboard()
	#refresh_cats()
	#current_contestant_score = 0
