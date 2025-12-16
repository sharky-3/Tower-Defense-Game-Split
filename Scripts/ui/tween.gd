extends Node

class_name UIAnimations

static var hover_scale: float = 1.2
static var stiffness: float = 300.0
static var damping: float = 10.0
static var mass: float = 2.0
static var image_base_scale: float = 0.6
	
static func update_segment_hover_physics(
	delta: float,
	segment_nodes: Array,
	image_nodes: Array,
	segment_scales: Array,
	segment_velocities: Array,
	hovered_index: int,
	base_color: Color,
	hover_color: Color,
	inner_radius: float,
	outer_radius: float,
) -> void:

	for i in range(segment_nodes.size()):
		var target := 1.0
		if i == hovered_index:
			target = hover_scale
			segment_nodes[i].modulate = hover_color
		else:
			segment_nodes[i].modulate = base_color

		var x = segment_scales[i] - target
		var force = -stiffness * x - damping * segment_velocities[i]
		var acceleration = force / mass

		segment_velocities[i] += acceleration * delta
		segment_scales[i] += segment_velocities[i] * delta

		var scale_vec = Vector2.ONE * segment_scales[i]
		segment_nodes[i].scale = scale_vec
		image_nodes[i].scale = scale_vec * image_base_scale

		var mid_angle := atan2(image_nodes[i].position.y, image_nodes[i].position.x)
		var mid_radius := (inner_radius + outer_radius) * 0.5
		var hover_offset = (segment_scales[i] - 1.0) * -3.0 * mid_radius

		if i == hovered_index:
			image_nodes[i].position = Vector2(cos(mid_angle), sin(mid_angle)) * (mid_radius - hover_offset)
			image_nodes[i].scale *= 1.3
		else:
			image_nodes[i].position = Vector2(cos(mid_angle), sin(mid_angle)) * mid_radius
