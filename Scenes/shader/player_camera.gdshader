shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;
uniform float pixel_size = 4.0;

void fragment() {
    vec2 res = vec2(textureSize(screen_texture, 0));
    vec2 uv = floor(SCREEN_UV * res / pixel_size) * pixel_size / res;
    COLOR = texture(screen_texture, uv);
}
