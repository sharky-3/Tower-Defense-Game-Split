shader_type canvas_item;

#define USE_CIRCUMRADIUS

uniform float progress: hint_range(0.0, 1.0) = 0.5;
uniform vec2 center = vec2(0.5);

uniform float amplitude: hint_range(0.0, 1.0) = 0.1;
uniform float period: hint_range(0.0, 256.0, 1.0) = 5.0;
uniform float base_rotation: hint_range(0.0, 1.0) = 0.0;
uniform float add_rotation = 0.4;

uniform sampler2D screen: hint_screen_texture, filter_nearest;

#ifndef USE_CIRCUMRADIUS
uniform float radius = 0.5;
#endif

float calc_angle(vec2 diff) {
	float angle = atan(-diff.y, diff.x);
	if (angle < 0.0) angle += 2.0 * PI;
	return angle;
}

void fragment() {
	float aspect_ratio = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;

	vec2 ar_uv = vec2(aspect_ratio * UV.x, UV.y);
	vec2 ar_center = vec2(aspect_ratio * center.x, center.y);

	vec2 mask = ar_uv - ar_center;

	#ifdef USE_CIRCUMRADIUS
	float d1 = distance(ar_center, vec2(0.0, 0.0));
	float d2 = distance(ar_center, vec2(0.0, 1.0 + amplitude));
	float d3 = distance(ar_center, vec2(aspect_ratio * (1.0 + amplitude), 0.0));
	float d4 = distance(ar_center, vec2(aspect_ratio * (1.0 + amplitude), 1.0 + amplitude));
	float radius = max(max(d1, d2), max(d3, d4));
	#endif

	float angle = calc_angle(mask);

	float offset = amplitude * sin(PI * base_rotation + period * (angle - progress * add_rotation * PI));
	COLOR.a = step(length(mask) + offset * progress, progress * radius);

	vec3 albedo = texture(screen, SCREEN_UV * 0.6 + vec2(0.15)).rgb;
	COLOR.rgb = vec3(albedo.r * 0.25, albedo.g * 0.5, albedo.b);
}