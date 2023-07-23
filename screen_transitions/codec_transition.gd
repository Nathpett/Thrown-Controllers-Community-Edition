extends ScreenTransition


func _ready() -> void:
	await get_tree().create_timer(1).timeout
	
	$TextureRect.visible = true
	$AudioStreamPlayer.play()
	
	var blink_duration: float = 0.2
	var tween = create_tween()
	tween.tween_interval(blink_duration)
	await tween.finished
	$TextureRect.visible = true
	
	tween = create_tween()
	tween.tween_interval(blink_duration)
	await tween.finished
	$TextureRect.visible = false
	
	tween = create_tween()
	tween.tween_interval(blink_duration)
	await tween.finished
	$TextureRect.visible = true
	
	tween = create_tween()
	tween.tween_interval(blink_duration)
	await tween.finished
	
	await get_tree().create_timer(0.5).timeout
	$TextureRect.visible = false
	$ColorRect.visible = false
	
	emit_signal("screen_covered")
	
	tween = create_tween()
	$ShaderRect.visible = true
	tween.tween_property($ShaderRect.material, "shader_parameter/progress", 1.0, 0.5)
	
	await tween.finished
	emit_signal("finished")
	
	queue_free()
