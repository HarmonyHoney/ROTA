shader_type canvas_item;

uniform float offset_y : hint_range(0.0, 1.0) = 0.0;
uniform sampler2D mask;

void fragment(){
	vec4 col = texture(TEXTURE, UV - vec2(0.0, offset_y));
	//col -= texture(mask, UV);
	COLOR = col;
}