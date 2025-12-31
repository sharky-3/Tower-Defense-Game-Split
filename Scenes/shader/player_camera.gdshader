shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never;

uniform sampler2D screen_texture : hint_screen_texture;
uniform float pixel_size = 5.0;

void fragment() {
    vec2 screen_uv = SCREEN_UV;

    vec2 resolution = vec2(textureSize(screen_texture, 0));
    vec2 pixel_uv = floor(screen_uv * resolution / pixel_size) * pixel_size / resolution;

    ALBEDO = texture(screen_texture, pixel_uv).rgb;
}
