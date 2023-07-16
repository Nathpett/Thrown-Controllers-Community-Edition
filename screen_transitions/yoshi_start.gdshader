shader_type canvas_item;

void fragment() {
    vec2 st = UV;
	vec4 color = texture(TEXTURE, st);
	color.a = 0.0;
	
    st.y *= 3.0;
    st = fract(st);
	
    st *= vec2(2.0);

    float f = pow(st.x, 2.);
    
    float y1 = smoothstep(0.0,1.0, st.y);
    float y2 = smoothstep(2.0, 1.0, st.y);
    f = step(y1 * 2.0, st.x);
    f += step(y2 * 2.0, st.x);
    f = 1.0 - f;
	
    color.a += f;
	color.rgb = vec3(0.125);
    COLOR = color;

}
