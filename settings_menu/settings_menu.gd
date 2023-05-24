extends Control


@onready var music_h_slider = $VBoxContainer/MusicSlider/HSlider
@onready var sfx_h_slider = $VBoxContainer/SFXSlider/HSlider



func _ready():
	position.x = ProjectSettings.get("display/window/size/viewport_width") * 0.05
	position.y = ProjectSettings.get("display/window/size/viewport_height") * 0.05
	size.x = ProjectSettings.get("display/window/size/viewport_width") * 0.9
	size.y = ProjectSettings.get("display/window/size/viewport_height") * 0.9
	
	var music_bus = AudioServer.get_bus_index("music")
	music_h_slider.value = db_to_linear(AudioServer.get_bus_volume_db(music_bus))

	var sfx_bus = AudioServer.get_bus_index("sfx")
	sfx_h_slider.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus))



func _process(delta):
	pass


func _on_h_slider_value_changed(value: float):
	var _bus = AudioServer.get_bus_index("music")
	AudioServer.set_bus_volume_db(_bus, linear_to_db(value))
