shader_type canvas_item;

uniform float offset_y : hint_range(-1.0, 1.0) = 0.0;
uniform vec4 add_color : hint_color = vec4(0.0, 0.0, 0.0, 0.0);

void fragment(){
	COLOR = texture(TEXTURE, UV - vec2(0.0, offset_y)) + vec4(add_color.rgb, 0.0);
}