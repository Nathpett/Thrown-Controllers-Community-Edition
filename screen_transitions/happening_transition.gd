extends ScreenTransition


func _ready():
	$AudioStreamPlayer.play()
	
	$AnimationPlayer.play("ani_in")
	await $AnimationPlayer.animation_finished
	
	emit_signal("screen_covered")
	
	await get_tree().create_timer(0.5).timeout
	
	$AnimationPlayer.play_backwards("ani_in")
	await $AnimationPlayer.animation_finished
	
	emit_signal("finished")
	
	await $AudioStreamPlayer.finished
	queue_free()
