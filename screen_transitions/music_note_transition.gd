extends ScreenTransition


func _ready():
	$AnimationPlayer.play("note_in")
	await $AnimationPlayer.animation_finished
	
	emit_signal("screen_covered")
	
	$TextureRect.material.set_shader_parameter("progress", 0.0)
	$TextureRect.material.set_shader_parameter("inverted", true)
	
	$AnimationPlayer.play("note_in")
	await $AnimationPlayer.animation_finished
	
	emit_signal("finished")
	
	await $AudioStreamPlayer.finished
	queue_free()
