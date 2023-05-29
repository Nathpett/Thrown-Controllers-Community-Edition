extends Control


@onready var music_h_slider = $VBoxContainer/MusicSlider/HSlider
@onready var sfx_h_slider = $VBoxContainer/SFXSlider/HSlider
@onready var fullscreen_checkbutton = $VBoxContainer/CenterContainer/CheckButton

var pause_menu

func _ready():
	var music_bus = AudioServer.get_bus_index("music")
	music_h_slider.value = db_to_linear(AudioServer.get_bus_volume_db(music_bus))
	
	var sfx_bus = AudioServer.get_bus_index("sfx")
	sfx_h_slider.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus))
	
	var window_mode = DisplayServer.window_get_mode()
	fullscreen_checkbutton.button_pressed = window_mode == DisplayServer.WINDOW_MODE_FULLSCREEN
	
	music_h_slider.grab_focus()


func _process(delta):
	pass


func destroy():
	queue_free()


func _on_music_h_slider_changed(value):
	var _bus = AudioServer.get_bus_index("music")
	AudioServer.set_bus_volume_db(_bus, linear_to_db(value))


func _on_sfx_h_slider_changed(value):
	var _bus = AudioServer.get_bus_index("sfx")
	AudioServer.set_bus_volume_db(_bus, linear_to_db(value))
	
	$Bloop.play()


func _on_fullscreen_toggle_toggled(button_pressed):
	var new_mode = DisplayServer.WINDOW_MODE_FULLSCREEN if button_pressed else DisplayServer.WINDOW_MODE_WINDOWED 
	DisplayServer.window_set_mode(new_mode)


func _on_back_button_pressed():
	pause_menu.return_focus()
	queue_free()
