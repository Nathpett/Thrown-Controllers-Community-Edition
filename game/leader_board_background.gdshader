shader_type canvas_item;


void fragment(){
    vec2 uv = UV;
    uv += vec2(-1, 1) * TIME * 0.25;
    COLOR = texture(TEXTURE, uv);
}