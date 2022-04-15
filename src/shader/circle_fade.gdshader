shader_type canvas_item;
render_mode blend_add;

uniform float width : hint_range(0.0, 0.5) = 0.1;

void fragment(){
	vec4 col = vec4(1.0);
	float dist = distance(vec2(0.5), UV);
	
	float nd = (dist - (0.5 - width)) / width;
	col.a = mix(1.0, 0.0, clamp(nd, 0.0, 1.0));
	
	COLOR = col;
}