extends Control

var player_enum = -1
var avatar: Avatar
var game_state: GameState
var is_active: bool = true: set = _set_is_active

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
	
	avatar.position = $AvatarHome.position
	avatar.visible = true


func initiate(player_enum: int):
	var player = game_state.players[player_enum] 
	
	$RichTextLabel.parse_bbcode("[center]%s" % [player["name"]])
	avatar.reigon_vector = player["reigon_vector"]
	
	self.is_active = false
	counter.fast_set_score(game_state.lagging_players[player_enum].get("score", 0))


func set_score(score: int) -> void:
	counter.score = score


func _set_is_active(_is_active) -> void:
	if is_active != _is_active:
		is_active = _is_active
		$DarkenRect.visible = !is_active
		avatar.is_walking = is_active
		
	
