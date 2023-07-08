extends ScreenTransition


func _ready() -> void:
	var tween = create_tween()
	tween.tween_interval(0.1)

	await tween.finished

	tween = create_tween()
	
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property($TextureRect, "offset_top", 0, 1.0)
	$AudioStreamPlayer.play()
	
	await tween.finished
	
	tween = create_tween()
	tween.tween_interval(3)
	
	await tween.finished
	emit_signal("screen_covered")
	emit_signal("finished")
	
	
	tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_parallel(true)
	tween.tween_property($TextureRect, "offset_top", -480, 2.0)
	tween.tween_property($TextureRect, "offset_bottom", -480, 2.0)
	tween.tween_property($AudioStreamPlayer, "volume_db", -80, 2.0)
	
	await tween.finished
	
	queue_free()
