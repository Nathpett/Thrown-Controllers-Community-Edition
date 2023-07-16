extends ScreenTransition


func _ready():
	$AnimationPlayer.play("fog_in")
	$AudioStreamPlayer.play()
	
	await $AnimationPlayer.animation_finished
	
	$AnimationPlayer.speed_scale = 4.0
	$AnimationPlayer.play_backwards("fog_in")
	emit_signal("screen_covered")
	emit_signal("finished")
	
	await $AnimationPlayer.animation_finished
	
	queue_free()
