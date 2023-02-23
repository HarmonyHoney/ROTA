shader_type canvas_item;

uniform float fill_y : hint_range(0.0, 1.0) = 0.5;
uniform bool is_flip = false;
uniform bool is_descent = false;

void fragment(){
	vec4 c = texture(TEXTURE, UV);
	vec4 i = vec4(1.0) - c;
	float f = is_descent ? fill_y : (1.0 - fill_y);
	COLOR = mix(c, vec4(i.rgb, c.a), float(is_flip ? (UV.y > f) : (UV.y < f)));
}