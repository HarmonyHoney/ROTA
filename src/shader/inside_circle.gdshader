shader_type canvas_item;

uniform float radius : hint_range(0.0, 1.0) = 0.5;
uniform float width : hint_range(0.0, 0.2) = 0.05;

uniform vec4 line_color : hint_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 outside_color : hint_color = vec4(0.0, 0.0, 0.0, 0.0);

void fragment(){
	
	float dist = distance(vec2(0.5, 0.5), UV);
	
	if (dist < radius - width){
		COLOR = texture(TEXTURE, UV);
	}
	else if (dist < radius) {
		COLOR = line_color;
	}
	else {
		COLOR = outside_color;
	}
	
}