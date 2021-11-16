shader_type canvas_item;

uniform float offset_y : hint_range(-1.0, 1.0) = 0.0;

void fragment(){
	COLOR = texture(TEXTURE, UV - vec2(0.0, offset_y));
}