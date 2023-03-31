shader_type canvas_item;
render_mode blend_mix;

uniform float blur : hint_range(-1.0, 1.0) = 0.0;
uniform float step_dist = 0.005;
uniform float steps : hint_range(1.0, 30.0) = 8.0;
uniform float aspect : hint_range(0.0, 5.0) = 0.5625;

void fragment() {
    float angle = atan(SCREEN_UV.y - 0.5, (SCREEN_UV.x - 0.5));
    float dist = distance(SCREEN_UV, vec2(0.5));
    vec3 color = vec3(0.0);
    for (float i = 0.0; i < steps; i += 1.0) {
        float _angle = angle + i * (step_dist * blur);
        vec2 uv = vec2(cos(_angle), sin(_angle)) * dist + vec2(0.5);
        color += texture(SCREEN_TEXTURE, uv).rgb / ceil(steps);
    }
    
    COLOR.rgb = color;
}