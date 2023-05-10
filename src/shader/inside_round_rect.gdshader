shader_type canvas_item;

uniform float radius : hint_range(0.0, 0.5) = 0.25;
uniform vec4 inside_color : hint_color = vec4(0.0);
uniform vec4 outside_color : hint_color = vec4(1.0);

void fragment(){
	vec2 uv = abs(UV - floor(UV * 2.0));
	COLOR =  mix(inside_color, mix(outside_color, inside_color, float(distance(uv, vec2(radius)) < radius)), float(uv.x < radius && uv.y < radius));
	
}