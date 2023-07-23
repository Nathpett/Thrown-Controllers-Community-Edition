shader_type canvas_item;

uniform float progress: hint_range(0.0, 1.0);
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	vec2 suv = SCREEN_UV;
    vec2 scaledUV = vec2(
        SCREEN_UV.x,
        (SCREEN_UV.y - 0.5f) / (progress) + 0.5f
    );
    
	
    COLOR = textureLod(screen_texture, scaledUV, 0.0);
}