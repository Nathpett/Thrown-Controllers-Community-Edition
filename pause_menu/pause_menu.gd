extends Control

var opened_menus: Array = []
var game


func _ready():
	return_focus()
	if game.current_scene is LeaderBoard:
		$VBoxContainer/LeaderBoard.text = "return"
		return
	if not (game.current_scene is PanelSelect or game.current_scene.name == "EndScreen"):
		$VBoxContainer/LeaderBoard.disabled = true


func _input(event):
	if event.is_action_pressed("pause"):
		_unpause()
		get_viewport().set_input_as_handled()
	


func return_focus() -> void:
	visible = true
	$VBoxContainer/SettingsButton.grab_focus()


func _unpause() -> void:
	queue_free()
	for menu in opened_menus: # user could create a memeory leak if they just opened and closed settings menu all day haha but whatever it works
		if is_instance_valid(menu):
			menu.destroy()
	get_tree().paused = false


func _return_to_main_menu() -> void:
	game.return_to_main_menu()
	_unpause()


func _quit_game() -> void:
	get_tree().quit()


func _on_settings_button_pressed():
	var settings_menu = load("res://pause_menu/settings_menu.tscn").instantiate()
	get_parent().add_child(settings_menu)
	opened_menus.append(settings_menu)
	
	settings_menu.pause_menu = self
	visible = false


func _on_main_menu_button_pressed():
	var are_you_sure = load("res://pause_menu/are_you_sure.tscn").instantiate()
	get_parent().add_child(are_you_sure)
	are_you_sure.yes_function = Callable(self, "_return_to_main_menu")
	are_you_sure.pause_menu = self
	
	opened_menus.append(are_you_sure)
	visible = false


func _on_quit_game_button_pressed():
	var are_you_sure = load("res://pause_menu/are_you_sure.tscn").instantiate()
	get_parent().add_child(are_you_sure)
	are_you_sure.yes_function = Callable(self, "_quit_game")
	are_you_sure.pause_menu = self
	
	opened_menus.append(are_you_sure)
	visible = false


func _on_debug_button_pressed():
	var debug_menu = load("res://pause_menu/debug_menu.tscn").instantiate()
	debug_menu.pause_menu = self
	get_parent().add_child(debug_menu)
	
	opened_menus.append(debug_menu)
	visible = false


func _on_leader_board_pressed():
	if game.current_scene is PanelSelect or game.current_scene.name == "EndScreen":
		game.show_leaderboard()
	if game.current_scene is LeaderBoard:
		game.return_to_panel_select()
	_unpause()
		
