shader_type canvas_item;

uniform float radius : hint_range(0.0, 1.0) = 0.5;
uniform vec4 inside_color : hint_color = vec4(0.0);
uniform vec4 outside_color : hint_color = vec4(1.0);

void fragment(){
	float dist = distance(vec2(0.5, 0.5), UV);
	COLOR = mix(inside_color, outside_color, float(dist > radius));
}