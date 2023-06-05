extends ScreenTransition



func _ready() -> void:
	var tween = create_tween()
	$TextureRect.modulate = Color.RED
	var trans_red = Color.RED
	trans_red.a = 0.0
	
	$ColorRect.color = trans_red
	$ColorRect/Label.modulate = Color.TRANSPARENT
	
	tween.tween_property($TextureRect, "modulate", Color.RED, 0.2)
	tween.tween_property($TextureRect, "modulate", trans_red, 0.2)
	tween.tween_property($TextureRect, "modulate", Color.RED, 0.2)
	tween.tween_property($TextureRect, "modulate", trans_red, 0.2)
	tween.tween_property($TextureRect, "modulate", Color.RED, 0.2)
	#tween.start()
	
	$AudioStreamPlayer.play()
	
	await tween.finished
	
	tween = create_tween()
	tween.tween_property($ColorRect, 'color', Color.RED, 1.0)
	tween.parallel().tween_property($ColorRect/Label, 'modulate', Color.WHITE, 1.0)
	
	await tween.finished
	
	$TextureRect.visible = false
	
	tween = create_tween()
	tween.tween_interval(2.0)
	
	await tween.finished
	
	emit_signal("screen_covered")
	emit_signal("finished")
	
	tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property($ColorRect, "offset_top", 1000, 1.0)
	tween.tween_property($ColorRect, "offset_bottom", 1500, 1.0)
	
	await tween.finished
	
	$ColorRect.visible = false
	
	queue_free()
