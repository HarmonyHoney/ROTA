shader_type canvas_item;
render_mode blend_mix;

uniform float size : hint_range(0.0, 1.0) = 0.5;
uniform float width : hint_range(0.0, 1.0) = 0.1;
uniform vec4 color : hint_color = vec4(1.0);
uniform float scale : hint_range(0.01, 1.0) = 1.0;
uniform bool is_half = false;

void fragment(){
	vec4 col = vec4(1.0);
	float dist = abs(0.5 - UV.x);
	
	
	float nd = (dist - (0.5 - width)) / width;
	col.a = mix(1.0, 0.0, clamp(nd, 0.0, 1.0));
	
	COLOR = col * color;
}