extends ScreenTransition

@export var shutter_frame: int = 0 : set = _set_shutter_frame

@onready var texture_rect: TextureRect = $TextureRect


func _ready():
	$AnimationPlayer.play("close")
	$AudioStreamPlayer.play()
	
	await get_tree().create_timer(2).timeout
	
	emit_signal("screen_covered")
	emit_signal("finished")
	
	$AnimationPlayer.play_backwards("close")
	
	await $AnimationPlayer.animation_finished
	
	queue_free()


func _set_shutter_frame(new_value) -> void:
	if !is_instance_valid(texture_rect):
		return
	shutter_frame = new_value
	$TextureRect.visible = shutter_frame != -1
	$TextureRect.texture.region = Rect2(256 * shutter_frame, 0, 256, 192)
