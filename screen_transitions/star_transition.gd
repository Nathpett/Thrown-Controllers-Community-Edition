extends ScreenTransition

# Man I should have just made a class that this and other ones like shutter inherit from

@export var frame: int = 0 : set = _set_frame


@onready var texture_rect = $TextureRect


func _ready():
	$AnimationPlayer.play("go")
	$AudioStreamPlayer.play()
	
	await $AnimationPlayer.animation_finished
	emit_signal("screen_covered")
	
	var tween = create_tween()
	
	tween.tween_interval(0.5)
	await tween.finished
	
	tween = create_tween()
	
	tween.tween_property($TextureRect, "modulate:a", 0.0, 0.5)
	await tween.finished
	
	emit_signal("finished")
	queue_free()


func _set_frame(new_value) -> void:
	if !is_instance_valid(texture_rect):
		return
	frame = new_value
	$TextureRect.visible = frame != -1
	$TextureRect.texture.region = Rect2(240 * frame, 0, 240, 160)
