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
	
	#randomize()


func _input(event):
	if event.is_action_pressed("pause") and !current_scene.scene_disabled:
		var pause_menu = load("res://pause_menu/pause_menu.tscn").instantiate()
		pause_menu.main = self
		$UI.add_child(pause_menu)
		get_tree().paused = true


func new_game(_game_mode: String, _trivia_path: String, _initial_mode: int, _fast_mode: bool, _shuffle_trivia: bool) -> void:
	game = load("res://game/%s_game.tscn" % [_game_mode.to_lower()]).instantiate()
	game.mode = _game_mode
	
	add_child(game)
	game.initiate(_trivia_path, _initial_mode, _fast_mode, _shuffle_trivia)
	editor_mode = false


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
	if game:
		game.connect_game_scene(current_scene)
	
	# wait until transition is complete to actually allow input
	await transition.finished
	current_scene.enable()
	
	_show_message()


func play_category(category) -> void:
	var category_path = "res://category/concrete_categories/%s.tscn" % [category]
	change_scene_to_file(load(category_path).instantiate())


func return_to_main_menu() -> void:
	# if there is a transition, destroy it
	for child in transitions.get_children():
		child.queue_free()
	change_scene_to_file(load("res://main_menu/main_menu.tscn").instantiate())
	game.queue_free()


func queue_user_message(message: String) -> void:
	msgbox = load("res://panel_select/msg_box.tscn").instantiate()
	msgbox.text = message
	msgbox.visible = false
	add_child(msgbox)


func _show_message() -> void:
	if is_instance_valid(msgbox):
		msgbox.visible = true
