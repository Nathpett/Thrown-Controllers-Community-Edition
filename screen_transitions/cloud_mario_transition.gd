extends ScreenTransition


func _ready():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property($ColorRect, "color", Color(0, 0, 0, 0), 1.44)
	tween.tween_property($Cloud, "scale", Vector2(2, 2), 1.8)
	
	await get_tree().create_timer(0.6).timeout
	var face_tween = create_tween()
	face_tween.tween_property($Cloud/Face, "position", Vector2(0, -100), 0.84)
	
	await tween.finished
	
	emit_signal("screen_covered")
	emit_signal("finished")
	
	$ColorRect2.visible = false
	
	tween = create_tween()
	tween.tween_property($Cloud, "modulate", Color.TRANSPARENT, 0.5)
	
	await tween.finished
	
	queue_free()
	
