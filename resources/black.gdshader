shader_type canvas_item;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	color.rgb = vec3(0.0);
	COLOR = color;
}
