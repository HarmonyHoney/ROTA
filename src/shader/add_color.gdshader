shader_type canvas_item;

uniform vec4 add_color : hint_color = vec4(1.0, 0.0, 0.0, 1.0);

void fragment(){
	COLOR = texture(TEXTURE, UV) + vec4(add_color.rgb, 0.0);
}