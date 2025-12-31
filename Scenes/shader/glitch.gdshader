shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;
uniform float time;
uniform float glitch_strength = 0.02; // how far the channels split
uniform float scanline_intensity = 0.2;
uniform float jitter_speed = 5.0;

void fragment() {
    vec2 uv = SCREEN_UV;

    // Chromatic offset (RGB channels split)
    float offset = sin(time * jitter_speed + uv.y * 50.0) * glitch_strength;
    vec3 col;
    col.r = texture(screen_texture, uv + vec2(offset, 0.0)).r;
    col.g = texture(screen_texture, uv).g;
    col.b = texture(screen_texture, uv - vec2(offset, 0.0)).b;

    // Scanlines
    float scanline = sin(uv.y * 800.0) * scanline_intensity;
    col -= scanline;

    COLOR = vec4(col, 1.0);
}
