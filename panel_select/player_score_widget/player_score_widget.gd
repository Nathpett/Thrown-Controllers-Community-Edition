extends Control

var avatar: Avatar
var game_state: GameState
var is_active: bool: set = _set_is_active

@onready var counter = $Counter


func _ready():
	avatar = load("res://avatar/avatar.tscn").instantiate()
	add_child(avatar)
	
	var _node = self.get_parent()
	while _node:
		if is_instance_valid(_node) and _node.name == "Main":
			game_state = _node.game.game_state
		_node = _node.get_parent()
	
	await get_tree().create_timer(0.1).timeout
	initiate()


func initiate():
	avatar.position = $AvatarHome.position
	avatar.visible = true
	
	if !is_instance_valid(game_state):
		return

func _set_is_active(_is_active) -> void:
	if is_active != _is_active:
		is_active = _is_active
		$DarkenRect.visible = !is_active
		avatar.is_walking = is_active
		
	
