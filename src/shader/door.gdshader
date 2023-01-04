shader_type canvas_item;

uniform vec4 col1 : hint_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 col2 : hint_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float line : hint_range(0.0, 1.0) = 0.5;
uniform bool is_flip = false;

void fragment(){
	COLOR = mix(col1, col2, float(UV.x < line == is_flip));
}