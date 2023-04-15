shader_type canvas_item;

uniform vec4 col_fill : hint_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 col_back : hint_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 col_back2 : hint_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform vec4 col_line : hint_color = vec4(0.5, 0.5, 0.5, 1.0);
uniform float line_width : hint_range(0.0, 1.0) = 0.035;
uniform float line : hint_range(0.0, 1.0) = 0.5;

uniform float ring : hint_range(0.0, 1.0) = 0.5;
uniform float ring_offset : hint_range(-3.0, 3.0) = 0.0;

uniform float gem_size : hint_range(0.0, 1.0) = 0.75;
uniform float gem_line : hint_range(0.0, 1.0) = 0.667;
uniform vec2 gem_offset = vec2(0.0, -0.1);
uniform vec4 gem_col : hint_color = vec4(1.0, 1.0, 0.0, 1.0);
uniform vec4 gem_fill : hint_color = vec4(1.0, 0.866, 0.0, 1.0);
uniform vec4 knob_col : hint_color = vec4(1.0, 1.0, 0.0, 1.0);

uniform vec2 knob_offset = vec2(0.25, 0.65);
uniform float knob_size : hint_range(0.0, 0.3) = 0.075;

void fragment(){
	float x = abs(UV.x);
	float s = 1.0 - line;
	
	float new_x = (x - line)  / s;
	float sum = new_x + abs(UV.y - gem_offset.y);
	
	bool is_knob = distance(vec2(new_x, UV.y), knob_offset) < knob_size;
	
	if (x < line){
		COLOR = mix(col_back, col_back2, floor(mod((length(UV) + (TIME * ring_offset)) / ring, 2.0)) );
	}
	else if (sum < gem_size){
		COLOR = mix(gem_fill, gem_col, float(sum > gem_size * gem_line));
	}
	else if (is_knob){
		COLOR = knob_col;
	}
	else{
		COLOR = mix(col_fill, col_line, float(x < line + (line_width * s)));
	}
	
}