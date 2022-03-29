shader_type canvas_item;

uniform float fill_y : hint_range(0.0, 1.0) = 0.5;

void fragment(){
	vec4 c = texture(TEXTURE, UV);
	vec4 i = vec4(1.0) - c;
	COLOR = mix(c, vec4(i.rgb, c.a), float(UV.y > 1.0 - fill_y));
}