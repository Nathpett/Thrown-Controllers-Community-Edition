@tool
extends ScreenTransition

@export var shutter_frame: int = 0 : set = _set_shutter_frame

@onready var texture_rect: TextureRect = $TextureRect

func _ready():
	$AnimationPlayer.play("shutter")
	$AudioStreamPlayer.play()
	
	await $AnimationPlayer.animation_finished
	emit_signal("screen_covered")
	
	
	$AnimationPlayer.play_backwards("shutter")
	await $AudioStreamPlayer.finished
	
	emit_signal("finished")
	queue_free()


func _set_shutter_frame(new_value) -> void:
	if !is_instance_valid(texture_rect):
		return
	shutter_frame = new_value
	$TextureRect.visible = shutter_frame != -1
	$TextureRect.texture.region = Rect2(256 * shutter_frame, 0, 256, 244)
