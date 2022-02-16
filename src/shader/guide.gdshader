shader_type canvas_item;

uniform float height : hint_range(0.0, 5.0) = 3.0;
uniform float fade_height : hint_range(0.0, 5.0) = 3.0;
uniform float scale_y : hint_range(0.0, 1.0) = 1.0;
uniform sampler2D mask;

void fragment(){
	vec4 c = texture(SCREEN_TEXTURE, SCREEN_UV);
	// invert color
	c = vec4(vec3(1.0) - c.rgb, c.a);
	// gradient fade out
	c.a = smoothstep(1.0, 0.0, (UV.y - (height * scale_y) + fade_height) / fade_height);
	// mask
	c.a *= texture(mask, UV + vec2(0, -TIME)).r;
	
	COLOR = c;
}