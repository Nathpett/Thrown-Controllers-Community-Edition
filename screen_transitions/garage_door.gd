extends ScreenTransition


@onready var control = $Control


func _ready() -> void:
	control.position.y = -control.size.y
	await get_tree().create_timer(0.4).timeout

	var tween = create_tween()
	tween.tween_property(control, "position", Vector2.ZERO, trans_time).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	await tween.finished
	
	await get_tree().create_timer(hold_time).timeout
	
	emit_signal("screen_covered")
	
	tween.kill()
	tween = create_tween()
	tween.tween_property(control, "position", Vector2(0, -control.size.y), trans_time/2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await tween.finished
	
	queue_free()


func _set_text(new_value) -> void:
	super._set_text(new_value)
	$Control/Label.text = new_value
