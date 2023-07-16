extends Node2D


func _ready():
	await get_tree().create_timer(1).timeout
	visible = false
