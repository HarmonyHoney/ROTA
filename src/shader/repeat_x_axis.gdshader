shader_type canvas_item;

void fragment(){
	vec2 uv = UV;
	
	uv.x = mod(uv.x, 1.0);
	uv.y = clamp(UV.y, 0.0, 1.0);
	
	
	COLOR = texture(TEXTURE, uv);
}