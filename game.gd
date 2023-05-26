class_name Game
extends Node

enum Mode {DEBUG, RANDOM, JUST_ONE}
# TODO GET MUSIC ON LIST, IMPLEMENT TO MAKE MORE LIVELY

@export var trivia: Resource
@export var mode: Mode

var current_scene: GameScene
var black_fade_transition = preload("res://screen_transitions/black_fade.tscn")

var leaderboard: Dictionary

var panels: Dictionary
var category_queue: Array = []

# current game state
var current_contestant_name: String = ""
var current_contestant_score: int = 0
var devil_state = false
var point_gain: int = 1
var temp_point_gain: int = 0 # set by choose your destiny

var msgbox: MessageBox

@onready var avatar = $Avatar
@onready var transitions = $Transitions


func _ready() -> void:
	current_scene = load("res://main_menu/main_menu.tscn").instantiate()
	$GameScenes.add_child(current_scene)
	current_scene.game = self
	current_scene.enable()
	
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
			for i in range(1, 11):
				panels[i] = "brutal_question"


func _input(event):
	if event.is_action_pressed("pause"):
		var pause_menu = load("res://pause_menu/pause_menu.tscn").instantiate()
		$UI.add_child(pause_menu)
#		var settings_menu = load("res://settings_menu/settings_menu.tscn").instantiate()
#		$UI.add_child(settings_menu)
		get_tree().paused = true


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
	for cat in trivia.exhausted_categories:
		new_queue.erase(cat)
	
	if devil_state:
		for cat in new_queue.duplicate():
			if !Trivia.is_devil(cat):
				new_queue.erase(cat)
	
	return new_queue


func change_scene_to_file(new_scene, transition = null) -> void:
	# Begin transition, wait to hear "screen_obscured", delete the current scene and add the new
	if !transition:
		transition = new_scene.get_transition()
	
	transitions.add_child(transition)
	
	current_scene.disable()
	current_scene.music_fade_off()
	await transition.screen_covered
	
	current_scene.queue_free()
	
	current_scene = new_scene
	current_scene.game = self
	$GameScenes.add_child(new_scene)
	_connect_game_scene(current_scene)
	
	# wait until transition is complete to actually allow input
	await transition.tree_exited
	current_scene.enable()
	
	_show_message()


func push_current_to_leaderboard() -> void:
	leaderboard[current_contestant_name] = current_contestant_score


func pop_trivia_data(_category_type: String):
	if !Trivia.has_trivia_data(_category_type):
		return null
	
	#var indx = trivia_indexes.get(_category_type, 0)
	var trivia_data = trivia.get(_category_type).pop_front()
	if !len(trivia[_category_type]):
		_exhaust_category(_category_type)
	
	#trivia_indexes[_category_type] = (indx + 1) % len(trivia.get(_category_type)) # just modulo so that we'll return something.  User will just have to provide enough questions to prevent this, atleast we wont crash if we run out of questions lol
	return trivia_data


func deposit_trivia_data(_category_type: String, data):
	trivia[_category_type].insert(0, data)


func play_category(category) -> void:
	var category_path = "res://category/concrete_categories/%s.tscn" % [category]
	change_scene_to_file(load(category_path).instantiate())


func is_contestant_name_available(_name) -> bool:
	return !leaderboard.has(_name)


func _exhaust_category(cat: String) -> void:
	trivia.exhausted_categories.append(cat)
	while cat in category_queue:
		category_queue.erase(cat)
	
	for n in panels:
		var p_cat = panels[n]
		if p_cat == cat:
			panels[n] = pop_category_queue()
	
	# exhaust anyone dependant on this category (e.g., if brutal questions exhausted, exhaust devil deal)
	var dependants = Trivia.get_dependants(cat)
	for dependant in dependants:
		_exhaust_category(dependant)


# just connect it to everything lol whatever man...
func _connect_game_scene(gs):
	if gs is PanelSelect:
		gs.connect("play_selected_panel", Callable(self, "_on_play_selected_panel"))
	if gs is Category:
		gs.connect("success", Callable(self, "_on_success"))
		gs.connect("failure", Callable(self, "_on_failure"))
		gs.connect("devil_deal", Callable(self, "_on_devil_deal"))


func _on_play_selected_panel(selected_panel) -> void:
	# remove selecte panel from panels
	panels.erase(selected_panel.number)
	play_category(selected_panel.category)


func _on_devil_deal(outcome) -> void:
	if outcome:
		enter_devil_state()
	
	var transition = load("res://screen_transitions/garage_door.tscn").instantiate()
	transition.text = "DEAL!" if outcome else "NO DEAL!"
	transition.trans_time = 0.4
	transition.hold_time = 0.4
	return_to_panel_select(transition)


func _on_success() -> void:
	current_contestant_score += max(point_gain, temp_point_gain)
	temp_point_gain = 0
	var success_transition = load("res://screen_transitions/garage_door.tscn").instantiate()
	success_transition.text = "SUCCESS!"
	success_transition.trans_time = 0.4
	success_transition.hold_time = 0.4
	return_to_panel_select(success_transition)


func _on_failure() -> void:
	if devil_state: 
		exit_devil_state()
	
	push_current_to_leaderboard()
	
	current_contestant_score = 0
	
	var transition = load("res://screen_transitions/failure_transition.tscn").instantiate()
	change_scene_to_file(load("res://name_please/name_please.tscn").instantiate(), transition)


func enter_devil_state() -> void:
	devil_state = true
	point_gain = 2
	refresh_cats()
	avatar.fast_soulless()


func exit_devil_state() -> void:
	devil_state = false
	point_gain = 1
	refresh_cats()
	avatar.souledded()


func return_to_panel_select(transition) -> void:
	if devil_state:
		
		if trivia.exhausted_categories.has("devils_deal"):
			#exit devil state if devils_deal is exhausted
			_queue_user_message("All brutal questions have been used, \n the contestant's soul has been refunded.")
			exit_devil_state()
		else:
			enforce_devil_composition()
		
		
	change_scene_to_file(load("res://panel_select/panel_select.tscn").instantiate(), transition)


func refresh_cats() -> void:
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
			print(dest_brutal_ratio)
			print(panels.values())
			return


func _queue_user_message(message: String) -> void:
	msgbox = load("res://panel_select/msg_box.tscn").instantiate()
	msgbox.text = message
	msgbox.visible = false
	add_child(msgbox)


func _show_message() -> void:
	if is_instance_valid(msgbox):
		msgbox.visible = true
