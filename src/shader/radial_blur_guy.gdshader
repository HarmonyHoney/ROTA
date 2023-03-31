shader_type canvas_item;
render_mode blend_mix;

uniform float blur_angle : hint_range(-10, 10) = 0.0;
uniform float blur_offset : hint_range(-1.0, 1.0) = 0.0;
uniform float steps : hint_range(1.0, 30.0) = 8.0;
uniform float aspect : hint_range(0.0, 2.0) = 0.5625;

void fragment() {
    vec2 uv = SCREEN_UV;
    uv.y *= aspect;
    vec2 center = vec2(0.5, 0.5 * aspect);
    float angle = atan(uv.y - center.y, uv.x - center.x);
    float dist = distance(uv, center);
    vec3 color = vec3(0.0);
    for (float i = 0.0; i < steps; i += 1.0) {
        float _angle = angle + (blur_angle * blur_offset) + mix(-blur_angle, blur_angle, i / ceil(steps));
        vec2 tuv = vec2(cos(_angle), sin(_angle)) * dist + center;
        tuv.y /= aspect;
        color += texture(SCREEN_TEXTURE, tuv).rgb / ceil(steps);
    }
    
    COLOR.rgb = color;
}