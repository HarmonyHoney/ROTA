shader_type canvas_item;

uniform vec4 col1 : hint_color = vec4(0.0, 0.38, 1.0, 1.0);
uniform vec4 col2 : hint_color = vec4(0.0, 0.92, 1.0, 1.0);

void fragment(){
	COLOR = mix(col1, col2, 1.0 -SCREEN_UV.y);
}