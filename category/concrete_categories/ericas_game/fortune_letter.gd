extends Control

var char: String: set = _set_char
var is_blue: bool = false: set = _set_is_blue


func reveal() -> void:
	$TextureRect.visible = true # TODO MAYBE, CAN ANIMATE BLUE TO MAKE SMOOTHER?
	self.is_blue = false


func _set_char(new_char: String) -> void:
	var atlas_idx = "abcdefghijklmnopqrstuvwxyz?-'!".find(new_char)
	if atlas_idx == -1:
		return
	
	if "?-'!".find(new_char) != -1:
		$TextureRect.visible = true
	
	
	$ColorRect.color = Color.WHITE_SMOKE
	
	$ColorRect.visible = true
	
	var col_ct = 8
	var row = atlas_idx % col_ct
	var col = atlas_idx / col_ct
	$TextureRect.texture.region = Rect2(Vector2(4, 4) + Vector2(row * 24, col * 24), Vector2(18, 18))


func _set_is_blue(new_value: bool) -> void:
	is_blue = new_value
	if is_blue:
		$ColorRect.color = Color.BLUE
	else:
		$ColorRect.color = Color.WHITE_SMOKE
