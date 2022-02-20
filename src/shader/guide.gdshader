shader_type canvas_item;

uniform float height : hint_range(0.0, 5.0) = 3.0;
uniform float fade_height : hint_range(0.0, 5.0) = 3.0;
uniform float scale_x : hint_range(0.0, 1.0) = 1.0;
uniform float scale_y : hint_range(0.0, 1.0) = 1.0;
uniform float time_scale : hint_range(0.0, 2.0) = 1.0;

uniform sampler2D tread_mask;
uniform sampler2D box_mask;

void fragment(){
	vec4 c = texture(SCREEN_TEXTURE, SCREEN_UV);
	// invert color
	c = vec4(vec3(1.0) - c.rgb, 1.0);
	// gradient fade out
	c.a *= smoothstep(1.0, 0.0, (UV.y - (height * scale_y) + fade_height) / fade_height);
	// tread_mask
	c.a *= texture(tread_mask, UV + vec2(0, -TIME * time_scale)).r;
	// box_mask
	c.a *= 1.0 - texture(box_mask, UV - vec2(0.0, 0.5)).a * float(UV.y < 0.5);
	
	COLOR = c;
}