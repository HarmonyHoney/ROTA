shader_type canvas_item;

uniform vec4 col0 : hint_color = vec4(0.0, 0.38, 1.0, 1.0);
uniform vec4 col1 : hint_color = vec4(0.0, 0.92, 1.0, 1.0);
uniform vec4 col2 : hint_color = vec4(0.0, 0.92, 1.0, 1.0);
uniform vec4 col3 : hint_color = vec4(0.0, 0.38, 1.0, 1.0);

uniform float time_scale : hint_range(0.0, 1.0) = 1.0;
uniform float time = 30.0;

void fragment(){
	float f = abs((mod(TIME, time) / time) - 0.5) * 2.0;
	vec4 c1 = mix(col0, col2, f);
	vec4 c2 = mix(col1, col3, f);
	
	//mix(col0, col2, )
	COLOR = mix(c1, c2, UV.y);
}

