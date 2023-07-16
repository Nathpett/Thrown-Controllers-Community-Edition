shader_type canvas_item;

void fragment() {
	
	float original_a = texture(TEXTURE, UV).a;
	COLOR.a = min(original_a, 1.0 - distance(1.0, UV.x));
	
}
