shader_type canvas_item;

uniform float radius : hint_range(0.0, 0.5) = 0.5;
uniform float width : hint_range(0.0, 0.2) = 0.05;

void fragment(){
	
	float dist = distance(vec2(0.5, 0.5), UV);
	
	if (dist < radius - width){
		COLOR = texture(TEXTURE, UV);
	}
	else if (dist < radius) {
		COLOR = vec4(0.0, 0.0, 0.0, 1.0);
	}
	else {
		COLOR = vec4(0.0, 0.0, 0.0, 0.0);
	}
	
}