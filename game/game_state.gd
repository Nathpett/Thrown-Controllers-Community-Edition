class_name GameState
extends Resource

signal panels_changed

enum Mode {DEBUG, RANDOM, JUST_ONE}

@export var mode: Mode
# TODO this won't capture avialable reigon vectors... gotta refactor how that is edited


var panels: Dictionary = {}
var category_queue: Array = []
var current_contestant_name: String = ""
var current_contestant_score: int = 0
var current_contestant_avatar_reigon: Vector2
var devil_state = false
var fast_mode = false
var point_gain: int = 1
var temp_point_gain: int = 0 # set by choose your destiny
var exhausted_categories: Array = []
var leaderboard: Dictionary = {}
var trg_challenge_indexes: Dictionary = {}
var available_reigon_vectors: PackedVector2Array
var trivia


func setup() -> void:
	panels = {}
	match mode:
		Mode.DEBUG:
			# default to all categories for debugging
			var i = 1
			for cat in Trivia.CATEGORIES.keys():
				panels[i] = cat
				i += 1
		Mode.RANDOM:
			populate_singlefile(10)
		Mode.JUST_ONE:
			for i in range(1, 2):
				panels[i] = "pick_your_poison"
	
	trivia = load("res://trivia/trivia_1.tres") # TODO some day allow user to choose trivia resource when starting new game
	
	var trg_trivia_data = trivia.get("TheRunawayGuys_video_game_challenge")
	for host in trg_trivia_data:
		trg_challenge_indexes[host] = 0
	
	# using dims of NPC sheet, initialize available reigon vectors for avatars to draw from.
	var npc_sheet:Texture2D = load("res://assets/sprite_sheets/SNES - EarthBound Mother 2 - NPCs People.png")
	for j in (npc_sheet.get_height() / 50):
		for i in (npc_sheet.get_width() / 68):
			available_reigon_vectors.append(Vector2(i, j))


func on_success() -> void:
	current_contestant_score += max(point_gain, temp_point_gain)
	temp_point_gain = 0


func on_failure() -> void:
	if devil_state: 
		exit_devil_state()
	
	push_current_to_leaderboard()
	
	current_contestant_score = 0


func pop_trivia_data(_category_type: String):
	if !Trivia.has_trivia_data(_category_type):
		return null
	
	var trivia_data = trivia.get(_category_type).pop_front()
	
	return trivia_data


func deposit_trivia_data(_category_type: String, data):
	trivia[_category_type].insert(0, data)


func push_current_to_leaderboard() -> void:
	var player_data: Dictionary = {}
	player_data["score"] = current_contestant_score
	player_data["reigon_vector"] = current_contestant_avatar_reigon
	player_data["devil_state"] = devil_state
	leaderboard[current_contestant_name] = player_data


func is_contestant_name_available(_name) -> bool:
	return !leaderboard.has(_name)


func enter_devil_state() -> void:
	devil_state = true
	point_gain = 2
	refresh_cats()


func exit_devil_state() -> void:
	devil_state = false
	point_gain = 1
	refresh_cats()


func populate_singlefile(quant) -> void:
	for i in range(1, quant + 1):
		panels[i] = pop_category_queue()


func pop_category_queue() -> String:
	if category_queue.is_empty():
		category_queue = new_category_queue()
		category_queue.shuffle()
	return category_queue.pop_front()


func new_category_queue() -> Array:
	var new_queue = Array(Trivia.CATEGORIES.keys())
	for cat in exhausted_categories:
		new_queue.erase(cat)
	
	if devil_state:
		for cat in new_queue.duplicate():
			if !Trivia.is_devil(cat):
				new_queue.erase(cat)
	
	if fast_mode:
		for cat in new_queue.duplicate():
			if Trivia.is_video_game_challenge(cat):
				new_queue.erase(cat)
	
	return new_queue


func refresh_cats(allow_reload = true) -> void:
	if allow_reload:
		emit_signal("panels_changed")
	category_queue = []
	panels = {}
	populate_singlefile(10)


func enforce_devil_composition() -> void:
	#  Replace a non-brutal question with a brutal question to meet expected brutal ratio... min(0.5, score / 10) brutal questions over non brutals will be the score over 10 until a max of 0.5
	
	# first let's make a list of all indexes where there are no brutal categories
	var non_brutal_keys: Array = []
	for k in panels:
		if panels[k] != "brutal_question":
			non_brutal_keys.append(k)
	non_brutal_keys.shuffle()
	
	# replace random non-brutal questions with brutal questions until we hit dest ratio
	while true:
		var dest_brutal_ratio: float = min(0.5, current_contestant_score / 10.0)
		var actual_brutal_ratio: float = panels.values().count("brutal_question") / float(panels.keys().size())
		
		if actual_brutal_ratio < dest_brutal_ratio:
			# set a random non-brutal to brutal
			var key = non_brutal_keys.pop_back()
			panels[key] = "brutal_question"
		else:
			return


func check_exhaust(cur_category_type) -> void:
	if !Trivia.has_trivia_data(cur_category_type):
		return
	if !len(trivia[cur_category_type]):
		_exhaust_category(cur_category_type)


func _exhaust_category(cat: String) -> void:
	exhausted_categories.append(cat)
	while cat in category_queue:
		category_queue.erase(cat)
	
	# reroll all panels with the now exhausted category
	for n in panels:
		var p_cat = panels[n]
		if p_cat == cat:
			panels[n] = pop_category_queue()
	
	# exhaust anyone dependant on this category (e.g., if brutal questions exhausted, exhaust devil deal)
	var dependants = Trivia.get_dependants(cat)
	for dependant in dependants:
		_exhaust_category(dependant)
