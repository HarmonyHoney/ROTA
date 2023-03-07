shader_type canvas_item;
render_mode blend_mix;

uniform vec2 point = vec2(0, 0.5);
uniform float radius : hint_range(0.0, 1.0) = 0.5;

uniform vec4 outside_color : hint_color = vec4(1.0);
uniform vec4 inside_color : hint_color = vec4(0.0);

uniform float time_scale : hint_range(0.0, 0.05) = 1.0;

void fragment(){
	
	float f = mod(TIME * time_scale, 2.0) - 0.5;
	
	COLOR = mix(outside_color, inside_color, float(distance(vec2(f, 0.5), UV) < radius));
}