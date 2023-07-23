shader_type canvas_item;

uniform float progress: hint_range(0.0, 1.0);
uniform bool inverted = false;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

vec2 scale(vec2 uv, vec2 scl)
{
	mat2 scale = mat2(vec2(scl.x, 0.0), vec2(0.0, scl.y));
	
	uv -= 0.5;
	uv = uv * scale;
	uv += 0.5;
	return uv;
}

void fragment() {	
	vec2 uv = scale(UV, vec2(mix(0.05, 50.0, 1.0 - progress)));
	uv.x = clamp(uv.x, 0.0, 1.0);
	uv.y = clamp(uv.y, 0.0, 1.0);
	
	
	//vec4 s_col = textureLod(screen_texture, SCREEN_UV, 0.0);
	vec4 s_col = texture(TEXTURE, uv);
	
	if (inverted) {
		COLOR = vec4(1.0 - s_col);
	} else {
		COLOR = vec4(s_col);
	}
}