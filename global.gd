extends Node


var available_reigon_vectors: PackedVector2Array


func _ready() -> void:
	randomize()
	# using dims of NPC sheet, initialize available reigon vectors for avatars to draw from.
	var npc_sheet:Texture2D = load("res://assets/sprite_sheets/SNES - EarthBound Mother 2 - NPCs People.png")
	for j in (npc_sheet.get_height() / 50):
		for i in (npc_sheet.get_width() / 68):
			available_reigon_vectors.append(Vector2(i, j))


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ext"):
		get_tree().quit()
