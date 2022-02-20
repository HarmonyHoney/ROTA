shader_type canvas_item;

uniform vec4 color : hint_color = vec4(1.0);
uniform float radius : hint_range(0.0, 0.5) = 0.5;

void fragment(){
	vec4 c = color;
	
	c = vec4(1.0) - texture(SCREEN_TEXTURE, SCREEN_UV);
	c.a = float(distance(vec2(0.5), UV) < radius);
	COLOR = c;
}