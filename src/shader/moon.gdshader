shader_type canvas_item;
render_mode blend_mix;

uniform vec2 point = vec2(0, 0.5);
uniform float radius : hint_range(0.0, 1.0) = 0.5;

uniform vec4 outside_color : hint_color = vec4(1.0);
uniform vec4 inside_color : hint_color = vec4(0.0);
uniform vec4 sun_color : hint_color = vec4(1.0, 1.0, 0.0, 1.0);
uniform vec4 col1 : hint_color = vec4(1.0);
uniform vec4 col2 : hint_color = vec4(0.0);

uniform float sun_frac : hint_range(0.0, 1.0) = 0.0;
uniform float time_scale : hint_range(0.0, 0.05) = 1.0;

vec3 blendAddy(vec3 base, vec3 blend) {
	return min(base+blend,vec3(1.0));
}

vec3 blendAdd(vec3 base, vec3 blend, float opacity) {
	return (blendAddy(base, blend) * opacity + base * (1.0 - opacity));
}

void fragment(){
	vec4 c = mix(col2, col1, SCREEN_UV.y);
	float f = mod(TIME * time_scale, 2.0) - 0.5;
	vec4 nc = mix(outside_color, inside_color, float(distance(vec2(f, 0.5), UV) < radius));
	
	COLOR = mix(vec4(blendAdd(c.rgb, nc.rgb, nc.a), 1.0), sun_color, sun_frac);
}