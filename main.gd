class_name Main
extends Node

var game: Game
var current_scene: GameScene
var msgbox: MessageBox

var editor_mode: bool = true
var editor_category: String
var editor_trivia_file_name: String

@onready var transitions = $Transitions


func _ready():
	current_scene = load("res://main_menu/main_menu.tscn").instantiate()
	$GameScenes.add_child(current_scene)
	current_scene.main = self
	current_scene.enable()
	
	randomize()


func new_game(_game_mode: String, trivia_path: String, initial_mode: int, _fast_mode: bool, _shuffle_trivia: bool) -> void:
	game = load("res://game/game.tscn").instantiate()
	# TODO NEXT 
	editor_mode = false
	game_state = GameState.new()
	game_state.initiate(trivia_path, initial_mode, _fast_mode, _shuffle_trivia)
	_register_game_state()
	
	change_scene_to_file(load("res://name_please/name_please.tscn").instantiate())


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
	await transition.finished
	current_scene.enable()
	
	_show_message()


func return_to_main_menu() -> void:
	# if there is a transition, destroy it
	for child in transitions.get_children():
		child.queue_free()
	change_scene_to_file(load("res://main_menu/main_menu.tscn").instantiate())


# just connect it to everything lol whatever man...
func _connect_game_scene(gs):
	if gs is PanelSelect:
		gs.connect("play_selected_panel", Callable(self, "_on_play_selected_panel"))
	if gs is Category:
		gs.connect("success", Callable(self, "_on_success"))
		gs.connect("failure", Callable(self, "_on_failure"))
		gs.connect("devil_deal", Callable(self, "_on_devil_deal"))


func queue_user_message(message: String) -> void:
	msgbox = load("res://panel_select/msg_box.tscn").instantiate()
	msgbox.text = message
	msgbox.visible = false
	add_child(msgbox)


func _show_message() -> void:
	if is_instance_valid(msgbox):
		msgbox.visible = true
