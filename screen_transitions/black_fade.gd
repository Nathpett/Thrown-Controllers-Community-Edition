class_name BlackFadeScreenTransition
extends ScreenTransition

@onready var color_rect = $ColorRect


func _ready() -> void:
	var tween = create_tween()
	tween.tween_property(color_rect, "color", Color.BLACK, trans_time)
	#tween.start()
	
	await tween.finished
	emit_signal("screen_covered")
	
	tween = create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(color_rect, "color", Color(0, 0, 0, 0), trans_time)
	
	await tween.finished
	queue_free()
