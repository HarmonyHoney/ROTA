shader_type canvas_item;

uniform vec4 col_fill : hint_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 col_back : hint_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 col_line : hint_color = vec4(0.5, 0.5, 0.5, 1.0);
uniform float line_width : hint_range(0.0, 1.0) = 0.01;
uniform float line : hint_range(0.0, 1.0) = 0.5;

void fragment(){
	float x = abs(UV.x);
	
	if (x < line){
		COLOR = col_back;
	}
	else{
		float l = line_width * (1.0 - line);
		COLOR = mix(col_fill, col_line, float(x < line + l));
	}
	
}