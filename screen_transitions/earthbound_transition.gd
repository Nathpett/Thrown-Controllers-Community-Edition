extends ScreenTransition

var buffer = 8
var dims: Vector2 = Vector2(256, 224)
var h_frames = 5


@export var frame = 0: set = _set_frame
@export_enum("boss:1258", "enemy:53") var cur_ini_buffer_1

@onready var texture_rect: TextureRect = $TextureRect


func _ready():
	await get_tree().create_timer(0.4).timeout
	
	$AnimationPlayer.play("go")
	
	var tween_time
	
	if cur_ini_buffer_1 == 53:
		$AudioStreamPlayer.stream = load("res://assets/sound/music/39 Oncoming Foe.mp3")
		$TextureRect.modulate = Color.GREEN
		$TextureRect.modulate.a = 0.4
		tween_time = 2.0
	else:
		$AudioStreamPlayer.stream = load("res://assets/sound/music/52 Oncoming Boss.mp3")
		$TextureRect.modulate = Color.DARK_RED
		$TextureRect.modulate.a = 0.4
		tween_time = 1.0
	$AudioStreamPlayer.play()
	
	await $AnimationPlayer.animation_finished
	
	var tween = create_tween()
	tween.tween_property($TextureRect, "modulate:a", 1.0, tween_time)
	await tween.finished
	
	emit_signal("screen_covered")
	emit_signal("finished")
	
	tween = create_tween()
	tween.tween_property($TextureRect, "modulate:a", 0.0, tween_time)
	await tween.finished
	
	queue_free()


func _set_frame(new_value) -> void:
	if !is_instance_valid(texture_rect):
		return
	frame = new_value
	var h_frame = frame % h_frames
	var v_frame = floor(frame / h_frames)
	$TextureRect.texture.region = Rect2((256 + buffer) * h_frame, cur_ini_buffer_1 + (224 + buffer) * v_frame, 256, 244)
