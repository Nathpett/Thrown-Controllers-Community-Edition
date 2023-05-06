class_name Game
extends Node

# TODO GET MUSIC ON LIST, IMPLEMENT TO MAKE MORE LIVELY
const CATEGORIES: Array[String] = ["easy_question", 
						"solo_video_game_challenge", 
						"brutal_question", 
						"TheRunawayGuys_video_game_challenge", 
						"audience_video_game_challenge",
						"leap_of_faith",
						"audio",
						"dialogue",
						"who_the_heck_is_that",
						"screenshot",
						"lightning_round",
						"multiple_choice",
						"devils_deal"]


@export var trivia: Resource

var current_scene: GameScene
var black_fade_transition = preload("res://screen_transitions/black_fade.tscn")

var leaderboard: Dictionary

var panel_categories: Array[String]
var devil_categories: Array[String]
var panels: Dictionary
var trivia_indexes = {} # track indexes of trivia we've popped from

# current game state
var current_contestant_name: String = ""
var current_contestant_score: int = 0
var devil_state = false
var point_gain = 1

@onready var avatar = $Avatar
@onready var transitions = $Transitions


func _ready() -> void:
	current_scene = load("res://main_menu/main_menu.tscn").instantiate()
	$GameScenes.add_child(current_scene)
	current_scene.game = self
	current_scene.enable()
	
	panel_categories = CATEGORIES.duplicate()
	devil_categories = CATEGORIES.duplicate()
	devil_categories.erase("easy_question")
	devil_categories.erase("brutal_qeustion")
	devil_categories.erase("multiple_choice")
	
	panels = {}
	# default to all categories for now
	for i in range(1, len(CATEGORIES) + 1):
		panels[i] = CATEGORIES[i - 1]


func change_scene_to_file(new_scene, transition = null) -> void:
	# Begin transition, wait to hear "screen_obscured", delete the current scene and add the new
	if !transition:
		transition = new_scene.get_transition()
	
	transitions.add_child(transition)
	
	current_scene.disable()
	await transition.screen_covered
	
	current_scene.queue_free()
	
	current_scene = new_scene
	current_scene.game = self
	$GameScenes.add_child(new_scene)
	_connect_game_scene(current_scene)
	
	# wait until transition is complete to actually allow input
	await transition.tree_exited
	current_scene.enable()


func push_current_to_leaderboard() -> void:
	leaderboard[current_contestant_name] = current_contestant_score


func pop_trivia_data(_category_type: String):
	if _category_type == "devils_deal":
		return null
	
	var indx = trivia_indexes.get(_category_type, 0)
	var trivia_data = trivia.get(_category_type)[indx]
	
	trivia_indexes[_category_type] = (indx + 1) % len(trivia.get(_category_type)) # just modulo so that we'll return something.  User will just have to provide enough questions to prevent this, atleast we wont crash if we run out of questions lol
	return trivia_data


func is_contestant_name_available(_name) -> bool:
	return !leaderboard.has(_name)


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
	
#	var category = panel_categories[selected_panel.number - 1]
	var category_path = "res://category/concrete_categories/%s.tscn" % [selected_panel.category]
	
	change_scene_to_file(load(category_path).instantiate())


func _on_devil_deal(outcome) -> void:
	if outcome:
		enter_devil_state()
	
	var transition = load("res://screen_transitions/garage_door.tscn").instantiate()
	transition.text = "DEAL!" if outcome else "NO DEAL!"
	transition.trans_time = 0.4
	transition.hold_time = 0.4
	change_scene_to_file(load("res://panel_select/panel_select.tscn").instantiate(), transition)


func _on_success() -> void:
	current_contestant_score += point_gain
	var success_transition = load("res://screen_transitions/garage_door.tscn").instantiate()
	success_transition.text = "SUCCESS!"
	success_transition.trans_time = 0.4
	success_transition.hold_time = 0.4
	change_scene_to_file(load("res://panel_select/panel_select.tscn").instantiate(), success_transition)


func _on_failure() -> void:
	if devil_state: 
		exit_devil_state()
	
	push_current_to_leaderboard()
	
	current_contestant_score = 0
	
	var transition = load("res://screen_transitions/failure_transition.tscn").instantiate()
	transition.text = "GAME OVER!"
	change_scene_to_file(load("res://name_please/name_please.tscn").instantiate(), transition)


func enter_devil_state() -> void:
	devil_state = true
	point_gain = 2 # ALSO TO REPLACE ALL GAME PANELS
	avatar.fast_soulless()


func exit_devil_state() -> void:
	devil_state = false
	point_gain = 1
	avatar.souledded()
