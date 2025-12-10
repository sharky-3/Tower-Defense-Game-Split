@tool
extends Control

# --- Constants / Exported Data ---
@export var outer_radius: int = 256
@export var inner_radius: int = 64
@export var padding: int = 2
@export var border_radius: int = 10
@export var options: Array = []

@export var hover_scale: float = 1.2
@export var hover_time: float = 0.2 

# --- Stats ---
var segment_scales: Array = []
var hovered_index: int = -1

# --------------------------------------------------------------------
# Life Cycle
# --------------------------------------------------------------------

func _ready() -> void:
	segment_scales.clear()
	for _i in range(len(options)):
		segment_scales.append(1.0)

func _process(delta: float) -> void:
	queue_redraw()
	_handle_hover()
	_update_scales(delta)

# --------------------------------------------------------------------
# Draw
# --------------------------------------------------------------------

func _draw() -> void:
	var segment_count = len(options)
	if segment_count < 1:
		return

	var segment_angle = TAU / float(segment_count)
	var padding_angle = deg_to_rad(padding)
	var steps = 20
	var radius_steps = max(2, border_radius / 2)

	for i in range(segment_count):
		var start_angle = i * segment_angle + padding_angle
		var end_angle = (i + 1) * segment_angle - padding_angle
		var scale = segment_scales[i]

		var points = []

		# Outer arc
		for s in range(steps + 1):
			var t = float(s) / float(steps)
			var angle = lerp(start_angle, end_angle, t)
			var r = outer_radius
			if s < radius_steps:
				r = outer_radius - border_radius * (1.0 - float(s) / radius_steps)
			elif s > steps - radius_steps:
				r = outer_radius - border_radius * (1.0 - float(steps - s) / radius_steps)
			points.append(Vector2(cos(angle), sin(angle)) * r * scale)
		
		# Inner arc
		for s in range(steps, -1, -1):
			var t = float(s) / float(steps)
			var angle = lerp(start_angle, end_angle, t)
			var r = inner_radius
			if s < radius_steps:
				r = inner_radius + border_radius * (1.0 - float(s) / radius_steps)
			elif s > steps - radius_steps:
				r = inner_radius + border_radius * (1.0 - float(steps - s) / radius_steps)
			points.append(Vector2(cos(angle), sin(angle)) * r * scale)

		draw_polygon(points, [options[i]])

# --------------------------------------------------------------------
# Tween
# --------------------------------------------------------------------

func _handle_hover() -> void:
	var mouse_pos = get_local_mouse_position()
	var segment_count = len(options)
	if segment_count == 0:
		return

	var segment_angle = TAU / float(segment_count)
	var found_hover = -1
	var distance = mouse_pos.length()
	var angle = atan2(mouse_pos.y, mouse_pos.x)
	if angle < 0:
		angle += TAU

	for i in range(segment_count):
		var start_angle = i * segment_angle
		var end_angle = (i + 1) * segment_angle
		if distance >= inner_radius and distance <= outer_radius and angle >= start_angle and angle < end_angle:
			found_hover = i
			break

	if found_hover != hovered_index:
		hovered_index = found_hover

func _update_scales(delta: float) -> void:
	for i in range(len(segment_scales)):
		var target = 1.0
		if i == hovered_index:
			target = hover_scale
		segment_scales[i] = lerp(segment_scales[i], target, delta / hover_time)
