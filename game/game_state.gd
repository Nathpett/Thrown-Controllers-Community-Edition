class_name GameState
extends Resource

signal panels_changed

const AUTO_SAVE_LIMIT: int = 3

enum Mode {RANDOM, DEBUG, JUST_ONE}



@export var panels: Dictionary = {}
@export var category_queue: Array = []
@export var current_contestant_name: String = ""
@export var current_contestant_score: int = 0
@export var current_contestant_avatar_reigon: Vector2
@export var devil_state = false
@export var fast_mode = false
@export var point_gain: int = 1
@export var temp_point_gain: int = 0 # set by choose your destiny
@export var exhausted_categories: Array = []
@export var leaderboard: Dictionary = {}
@export var trg_challenge_indexes: Dictionary = {}
@export var available_reigon_vectors: PackedVector2Array
@export var initial_trivia_set: String = ""
@export var time_string: String = ""
@export var trivia: Dictionary


func initiate(trivia_path: String, initial_mode: int, _fast_mode: bool = false, shuffle_trivia: bool = false) -> void:
	trivia = load(trivia_path).data
	initial_trivia_set = trivia_path.get_file().get_basename()
	fast_mode = _fast_mode
	
	if shuffle_trivia:
		for arr in trivia.values():
			arr.shuffle()
	
	panels = {}
	match initial_mode:
		Mode.DEBUG:
			# default to all categories for debugging
			var i = 1
			for cat in CategoryStatics.CATEGORIES.keys():
				panels[i] = cat
				i += 1
		Mode.RANDOM:
			populate_singlefile(10)
		Mode.JUST_ONE:
			for i in range(1, 10):
				panels[i] = "who_the_heck_is_that"
	
	# in case any trivia starts the game with 0 data
	for cat in CategoryStatics.CATEGORIES:
		check_exhaust(cat)
	
	var trg_trivia_data = trivia.get("TheRunawayGuys_video_game_challenge")
	for dict in trg_trivia_data:
		var host = dict["host"]
		trg_challenge_indexes[host] = 0
	
	# using dims of NPC sheet, initialize available reigon vectors for avatars to draw from.
	var npc_sheet:Texture2D = load("res://assets/sprite_sheets/SNES - EarthBound Mother 2 - NPCs People.png")
	for j in (npc_sheet.get_height() / 50):
		for i in (npc_sheet.get_width() / 68):
			available_reigon_vectors.append(Vector2(i, j))


func save(save_name: String, use_time_string: bool = false) -> void:
	time_string = StringTools.stringify_date(Time.get_datetime_dict_from_system())
	if use_time_string:
		save_name += time_string
	ResourceSaver.save(self, "user://saves/%s.tres" % [save_name])


func auto_save() -> void:
	save("auto_save_", true)
	
	var dir = DirAccess.open("user://saves")
	# get list of all saves with auto save token, if there are 3 or more, delete the oldest until there are 2. 
	var save_files: Array = dir.get_files()
	save_files.filter(Callable(self, "_is_auto_save"))
	save_files.sort()
	while save_files.size() > AUTO_SAVE_LIMIT: # this won't acount for... daylight savings or system time changes, but you know what right now I don't care dangit!
		var to_delete = save_files.pop_front()
		dir.remove(to_delete)


func on_success() -> void:
	current_contestant_score += max(point_gain, temp_point_gain)
	temp_point_gain = 0


func on_failure() -> void:
	push_current_to_leaderboard()
	refresh_cats()
	current_contestant_score = 0


func pop_trivia_data(_category_type: String):
	if !CategoryStatics.has_trivia_data(_category_type):
		return null
	
#	var trivia_data = trivia.get(_category_type)[0]
	var trivia_data = trivia.get(_category_type).pop_front()
	
	return trivia_data


func deposit_trivia_data(_category_type: String, data):
	trivia[_category_type].insert(0, data)


func push_current_to_leaderboard() -> void:
	if current_contestant_name.length() == 0:
		return
	var player_data: Dictionary = {}
	player_data["score"] = current_contestant_score
	player_data["reigon_vector"] = current_contestant_avatar_reigon
	player_data["devil_state"] = devil_state
	leaderboard[current_contestant_name] = player_data
	
	current_contestant_name = ""


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
	var new_queue = Array(CategoryStatics.CATEGORIES.keys())
	for cat in exhausted_categories:
		new_queue.erase(cat)
	
	if devil_state:
		for cat in new_queue.duplicate():
			if !CategoryStatics.is_devil(cat):
				new_queue.erase(cat)
	
	if fast_mode:
		for cat in new_queue.duplicate():
			if CategoryStatics.is_video_game_challenge(cat):
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
	if !CategoryStatics.has_trivia_data(cur_category_type):
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
	var dependants = CategoryStatics.get_dependants(cat)
	for dependant in dependants:
		_exhaust_category(dependant)


func _is_auto_save(file_string: String) -> bool:
	return file_string.left(9) == "auto_save"
