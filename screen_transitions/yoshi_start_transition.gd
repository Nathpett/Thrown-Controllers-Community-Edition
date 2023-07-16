extends ScreenTransition



func _ready():
	var tween: Tween = create_tween()
	
	tween.tween_property($Control, "modulate", Color.WHITE, 0.5)
	
	await tween.finished
	
	tween = create_tween()
	
	tween.tween_property($Control/Label, "visible_ratio", 1.0, 2.0)
	$AudioStreamPlayer.play()
	
	await tween.finished
	
	tween = create_tween()
	tween.tween_interval(2)
	await tween.finished
	
	$Control/Label.visible = false
	tween = create_tween()
	
	emit_signal("finished")
	emit_signal("screen_covered")
	
	var wave_rect = $Control/WaveRect
	var solid_rect = $Control/SolidRect
	
	var trans_time = 0.5
	
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CIRC)
	tween.tween_property(wave_rect, "anchor_left", -0.01, trans_time) # overshoot to get rid o seem
	tween.tween_property(solid_rect, "anchor_right", 0.0, trans_time)
	
	await tween.finished
	
	tween = create_tween()
	
	trans_time = 0.2
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(wave_rect, "anchor_right", 0.0, trans_time)
	
	await tween.finished
	
	queue_free()
