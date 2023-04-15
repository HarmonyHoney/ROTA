shader_type canvas_item;

uniform vec4 col1 : hint_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 col2 : hint_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 col3 : hint_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float line : hint_range(0.0, 1.0) = 0.5;
uniform bool is_flip = false;

uniform float ring : hint_range(0.0, 1.0) = 0.5;
uniform float ring_offset : hint_range(-3.0, 3.0) = 0.0;

void fragment(){
	COLOR = mix(col1, mix(col2, col3, floor(mod((distance(vec2(0.5), UV) + (TIME * ring_offset)) / ring, 2.0))) , float(UV.x < line == is_flip));
}