shader_type canvas_item;

uniform vec4 inside : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 line : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 outside : source_color = vec4(1.0, 1.0, 1.0, 1.0);

uniform float scale : hint_range(0.0, 20.0) = 1.0;
uniform vec2 offset  = vec2(0.0);
uniform vec2 start_offset  = vec2(0.5);

uniform float radius : hint_range(0.0, 1.0) = 0.5;
uniform float width : hint_range(0.0, 1.0) = 0.05;

void fragment(){
	float dist = distance(start_offset, mod(UV / scale - offset, 1.0));
	
	if (dist < radius - width){
		COLOR = inside;
	}
	else if (dist < radius) {
		COLOR = line;
	}
	else {
		COLOR = outside;
	}
}