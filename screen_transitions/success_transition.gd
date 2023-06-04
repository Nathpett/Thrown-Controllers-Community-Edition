extends ScreenTransition


var tween: Tween


func _input(event):
	if event.is_action_pressed("progress") and $AudioStreamPlayer.playing:
		$AudioStreamPlayer.stop()
		$AudioStreamPlayer.emit_signal("finished")


func _ready() -> void:
	tween = create_tween()
	var original_color = $ColorFlash.modulate
	$ColorFlash.modulate.a = 0
	var transparent_color = $ColorFlash.modulate
	
	var flash_period = 0.25
	tween.tween_property($ColorFlash, "modulate", original_color, flash_period/2)
	tween.tween_callback(Callable($Check, "set").bind("visible", true))
	tween.tween_property($ColorFlash, "modulate", transparent_color, flash_period/2)
	
	await $AudioStreamPlayer.finished
	
	tween.kill()
	tween = create_tween()
	
	# Then just black fade haha
	tween.tween_property($ColorRect, "color", Color.BLACK, 0.4)
	tween.tween_callback(Callable(self, "emit_signal").bind("screen_covered"))
	tween.tween_callback(Callable($Check, "set").bind("visible", false))
	tween.tween_property($ColorRect, "color", Color(0, 0, 0, 0), 0.4)
	
	await tween.finished
	
	emit_signal("finished")


func _show_check() -> void:
	$Check.visible = true
