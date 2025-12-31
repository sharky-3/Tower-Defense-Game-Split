shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;
uniform float outline_strength = 0.8;
uniform float softness = 1.5;
uniform float noise_strength = 0.08;

float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898,78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = SCREEN_UV;
    vec2 res = vec2(textureSize(screen_texture, 0));
    vec2 px = 1.0 / res;

    vec3 col = texture(screen_texture, uv).rgb;
    float gray = dot(col, vec3(0.299, 0.587, 0.114));

    // Edge detection from color difference
    vec3 right = texture(screen_texture, uv + vec2(px.x,0)).rgb;
    vec3 up    = texture(screen_texture, uv + vec2(0,px.y)).rgb;
    float edge = length(col - right) + length(col - up);
    edge = smoothstep(0.05, 0.15, edge); // tweak thresholds

    float n = rand(uv * res);
    gray += (n - 0.5) * noise_strength;

    float final_value = gray - edge * outline_strength;
    COLOR = vec4(vec3(final_value), 1.0);
}
