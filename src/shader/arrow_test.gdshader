shader_type canvas_item;

uniform float fill_y : hint_range(0.0, 1.0) = 0.5;

void fragment(){
	COLOR = mix(vec4(1.0), vec4(vec3(0.0), 1.0), float(UV.y > fill_y));
}