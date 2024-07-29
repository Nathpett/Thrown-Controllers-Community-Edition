extends NamePlease


var cur_enum: int = 0

func _ready():
	super._ready()
	
	next_person(0)


func _input(event):
	if scene_disabled:
		return
	
	if event.is_action_pressed("left_person"):
		next_person(-1)
	if event.is_action_pressed("right_person"):
		next_person(1)
	if event.is_action_pressed("registration_complete"):
		disable()
		main.change_scene_to_file(load("res://panel_select/party_panel_select.tscn").instantiate())


func next_person(dir: int):
	if swapping:
		return
	swapping = true
	
	if dir:
		call_out_avatar()
		await avatar.done_moving
		
	swapping = false
	
	cur_enum += dir
	cur_enum = posmod(cur_enum, game.game_state.players.size())
	
	if dir:
		call_in_avatar() 
	
	var default_vector = game.game_state.available_reigon_vectors[0]
	avatar.reigon_vector = game.game_state.players[cur_enum].get("reigon_vector", default_vector)
	
	name_this_person.text = "This is %s" % [game.game_state.players[cur_enum]["name"]]
	$Control/Control/NameDialogue.clear()


func _on_ok(contestant_name) -> void:
	# don't progress if name taken
	if !game.game_state.is_contestant_name_available(contestant_name):
		name_this_person.text = "That name is taken"
		return
	
	avatar.confirm_character()
	
	game.game_state.add_player(cur_enum, contestant_name, avatar.reigon_vector)
	
	next_person(1)
