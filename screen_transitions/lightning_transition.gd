extends ScreenTransition

var ship_progress: float = 0


func _ready() -> void:
	var tween = create_tween()
	tween.tween_property($ColorRect, "color", Color(0, 0, 0, 0), 1.0)
	await tween.finished
	
	$AudioStreamPlayer.play(12.0)
	
	await get_tree().create_timer(0.5).timeout
	
	lightning_bolt($Lightning1)
	
	await get_tree().create_timer(1.5).timeout
	
	lightning_bolt($Lightning2)
	
	await get_tree().create_timer(2.0).timeout
	
	lightning_bolt($LightningLong, true)
	
	await get_tree().create_timer(1.5).timeout
	
	$LinksShip.visible = false
	$TextureRect.visible = false
	$LightningLong.visible = false
	
	emit_signal("screen_covered")
	emit_signal("finished")
	
	tween = create_tween()
	tween.tween_property($ColorRect, "color", Color.TRANSPARENT, 1.0)
	
	await tween.finished
	queue_free()


func _process(delta):
	ship_progress += delta * 3
	$LinksShip.position.y += 0.1 * sin(ship_progress) # haha this is fine I swear, but I imagine the ship would drift after enough time


func lightning_bolt(l_sprite: Sprite2D, obscure: bool = false) -> void:
	$Thunder.play()
	l_sprite.visible = true
	await get_tree().create_timer(0.1).timeout
	l_sprite.visible = false
	await get_tree().create_timer(0.1).timeout
	l_sprite.visible = true
	
	var tween = create_tween()
	if obscure:
		tween.tween_property($ColorRect, "color", Color.WHITE, 1.75)
	else:
		$ColorRect.color = Color(1, 1, 1, 0.25)
		tween.tween_property($ColorRect, "color", Color.TRANSPARENT, 1.0)
	await tween.finished
	
	l_sprite.visible = false
