extends Sprite2D

@onready var rotate_speed = randf_range(-5, 5)
@onready var speed_factor = randf_range(2.0, 5.0)

func _process(delta: float) -> void:
	position += Vector2.ONE * delta * 20 * speed_factor
	rotation_degrees += rotate_speed
	if position.x > 650:
		queue_free()
	
