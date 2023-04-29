shader_type canvas_item;

uniform vec4 fill_color : hint_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 shadow_color : hint_color = vec4(0.2, 0.2, 0.2, 1.0);

uniform float shadow_dist : hint_range(0.0, 0.3) = 0.1;
uniform float shadow_angle : hint_range(-1.0, 1.0) = 0.0;
uniform float shadow_offset : hint_range(0.0, 1.0) = 0.25;
uniform vec2 uv_scale = vec2(1.0, 3.25);

uniform float samples = 1.0;

const float TAU = 6.28318530717959;

void fragment(){
	vec4 c = texture(TEXTURE, UV) * fill_color;
	
	for (float i = 1.0; i < samples + 1.0; i += 1.0){
		float ang = (shadow_angle + shadow_offset) * TAU;
		float f = (i / ceil(samples));
		vec4 s = texture(TEXTURE, UV + (vec2(sin(ang), cos(ang)) * uv_scale * shadow_dist * f));
		
		c.rgb = mix(c.rgb, shadow_color.rgb, (1.0 - s.a) * (1.0 / samples));
	}
	
	COLOR = c;
}