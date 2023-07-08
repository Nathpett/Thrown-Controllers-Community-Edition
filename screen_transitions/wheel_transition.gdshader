shader_type canvas_item;

uniform int pixels = 100;

vec2 rotateUV(vec2 uv, float rotation) {
    float cosa = cos(rotation);
    float sina = sin(rotation);
	vec2 pivot = vec2(0.5);
	
    uv -= pivot;
    return vec2(
        cosa * uv.x - sina * uv.y,
        cosa * uv.y + sina * uv.x 
    ) + pivot;

    return uv;
}

void fragment() {
	vec2 uv = round(UV * float(pixels)) / float(pixels);
	uv = rotateUV(uv, TIME * -1.5);
	//uv = round(uv * float(pixels)) / float(pixels);
	
	vec4 color = texture(TEXTURE, uv);
	color.a = floor(color.a);
	
	COLOR = color;
}
