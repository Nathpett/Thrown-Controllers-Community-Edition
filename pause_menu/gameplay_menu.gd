extends Control

var pause_menu


@onready var fast_mode_check_button = $VBoxContainer/CenterContainer/CheckButton


func _ready():
	fast_mode_check_button.button_pressed = pause_menu.game.game_state.fast_mode


func destroy() -> void:
	if fast_mode_check_button.button_pressed != pause_menu.game.game_state.fast_mode:
		pause_menu.game.game_state.fast_mode = fast_mode_check_button.button_pressed
		pause_menu.game.game_state.refresh_cats()
	queue_free()


func _on_back_button_pressed():
	pause_menu.return_focus()
	destroy()
