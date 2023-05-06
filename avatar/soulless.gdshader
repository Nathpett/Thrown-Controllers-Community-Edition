shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0);
uniform vec4 outline_color : source_color;

float lum(vec3 c) {
	return (0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b)/3.0;
}


void fragment() {
	vec4 color = texture(TEXTURE, UV);
	
	float y = lum(color.rgb);
	vec4 soulless = vec4(outline_color.rgb, min(color.a, 1.0 - step(0.10, y)));
	
	COLOR = mix(color, soulless, progress);
}
