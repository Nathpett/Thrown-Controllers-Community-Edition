extends Control


var game = null

@onready var timer_value = $VBoxContainer/Control3/TimerValue
@onready var header_timer: Timer = $Timer
@onready var score_label = $VBoxContainer/Control3/Score
@onready var contestant_name_label = $VBoxContainer/Control2/ContestantName
@onready var cat_title = $VBoxContainer/Control3/CategoryTitle

func _ready() -> void:
	update_stats()


func _enter_tree() -> void:
	var _node = self.get_parent()
	
	while _node:
		if _node.name == "Game":
			game = _node
		_node = _node.get_parent()


func _process(_delta: float) -> void:
	if header_timer.time_left:
		timer_value.text = str(ceil(header_timer.time_left))
	else:
		timer_value.text = "X"


func update_stats() -> void:
	if game and !game.editor_mode:
		contestant_name_label.text = game.game_state.current_contestant_name
		score_label.text = "SCORE:%s" % [game.game_state.current_contestant_score]
		cat_title.text = game.current_scene.get_title().to_upper()


func start_timer(time_limit: float) -> void:
	header_timer.start(time_limit)
