@tool
extends Control

@export var outer_radius: int = 256
@export var inner_radius: int = 64
@export var padding: int = 2
@export var border_radius: int = 10
@export var options: Array = []

func _draw() -> void:
	var segment_count = len(options)
	if segment_count < 1:
		return

	var segment_angle = TAU / float(segment_count)
	var center = Vector2.ZERO
	var padding_angle = deg_to_rad(padding)
	var steps = 20
	var radius_steps = max(2, border_radius / 2)

	for i in range(segment_count):
		var start_angle = i * segment_angle + padding_angle
		var end_angle = (i + 1) * segment_angle - padding_angle
		
		var current_color: Color
		if i < len(options):
			current_color = options[i]
		else:
			current_color = Color.WHITE

		var points = []

		for s in range(steps + 1):
			var t = float(s) / float(steps)
			var angle = lerp(start_angle, end_angle, t)
			var r = outer_radius
			if s < radius_steps:
				r = outer_radius - border_radius * (1.0 - float(s) / radius_steps)
			elif s > steps - radius_steps:
				r = outer_radius - border_radius * (1.0 - float(steps - s) / radius_steps)
			points.append(Vector2(cos(angle), sin(angle)) * r)
		
		for s in range(steps, -1, -1):
			var t = float(s) / float(steps)
			var angle = lerp(start_angle, end_angle, t)
			var r = inner_radius
			if s < radius_steps:
				r = inner_radius + border_radius * (1.0 - float(s) / radius_steps)
			elif s > steps - radius_steps:
				r = inner_radius + border_radius * (1.0 - float(steps - s) / radius_steps)
			points.append(Vector2(cos(angle), sin(angle)) * r)
		
		draw_polygon(points, [current_color])

func _process(_delta: float) -> void:
	queue_redraw()
