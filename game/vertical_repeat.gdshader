shader_type canvas_item;


void fragment(){
    vec2 uv = UV;
    uv += vec2(-1, 0) * TIME * 0.05;
    COLOR = texture(TEXTURE, uv);
}