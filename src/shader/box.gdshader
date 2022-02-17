shader_type canvas_item;

uniform sampler2D tread_mask;
uniform vec4 tread_color : hint_color;
uniform float time_scale : hint_range(0.0, 2.0) = 1.0;

void fragment(){
	float m = texture(tread_mask, (UV * vec2(1.0, 1.0)) + vec2(0, -TIME * time_scale)).r;
	vec4 c = texture(TEXTURE, UV);
	
	// invert color
	vec4 invert = vec4(vec3(1.0) - c.rgb, c.a);
	
	COLOR = mix(c, vec4(tread_color.rgb, c.a), m);
}