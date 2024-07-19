class_name GameScene
extends Node

signal play_selected_panel(number)

@export var screen_transition: PackedScene = preload("res://screen_transitions/black_fade.tscn")
@export var trans_time: float = 0.4
@export var hold_time: float = 0.0


var scene_disabled = true
var main = null
var game = null


func _ready() -> void:
	if get_tree().current_scene.name == self.name:
		call_deferred("enable")
	
	var _node = self.get_parent()
	while _node:
		if _node.name == "Main":
			main = _node
			game = main.game
		_node = _node.get_parent()


func enable() -> void:
	scene_disabled = false


func disable() -> void:
	scene_disabled = true


func music_fade_off() -> void:
	var music = get_node_or_null("Music")
	if !is_instance_valid(music):
		return
	
	var tween = create_tween()
	tween.tween_property(music, "volume_db", -80, 2)
	

func get_title() -> String:
	return "GAMESCENE!!"


func get_transition() -> ScreenTransition:
	var transition = screen_transition.instantiate()
	transition.trans_time = trans_time
	transition.hold_time = hold_time
	
	return transition

