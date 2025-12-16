@tool
extends Control

@onready var selection_wheel: Control = $"."

# --- Constants / Exported Data ---
@export var outer_radius: int = 256
@export var inner_radius: int = 64
@export var padding: int = 2
@export var border_radius: int = 10

@export var base_color: Color = Color(1.0, 1.0, 1.0, 1.0)
@export var hover_color: Color = Color(0.267, 0.685, 0.55, 1.0)
@export var options: Array[Texture2D] 

# --- Stats ---
var segment_nodes: Array = []
var image_nodes: Array = []
var segment_velocities: Array = []
var segment_scales: Array = []
var hovered_index: int = -1

# --------------------------------------------------------------------
# Life Cycle
# --------------------------------------------------------------------

func _ready() -> void:
	_create_segments()

func _process(delta: float) -> void:
	_handle_hover()
	_global_hover_animation(delta)

# --------------------------------------------------------------------
# Create UI
# --------------------------------------------------------------------

func _create_segments() -> void:
	for node in segment_nodes:
		if is_instance_valid(node):
			node.queue_free()
	for node in image_nodes:
		if is_instance_valid(node):
			node.queue_free()

	segment_nodes.clear()
	image_nodes.clear()
	segment_scales.clear()
	segment_velocities.clear()

	var segment_count = len(options)
	if segment_count == 0:
		return

	for i in range(segment_count):
		var polygon = Polygon2D.new()
		polygon.z_index = -10
		polygon.modulate = base_color
		add_child(polygon)
		segment_nodes.append(polygon)
		segment_scales.append(1.0)
		segment_velocities.append(0.0)

		var sprite = Sprite2D.new()
		if options[i]:
			sprite.texture = options[i]
			sprite.centered = true
		add_child(sprite)
		image_nodes.append(sprite)

	_update_segments_points()

# --------------------------------------------------------------------
# Buttons
# --------------------------------------------------------------------

func _update_segments_points() -> void:
	var segment_count = len(segment_nodes)
	if segment_count == 0:
		return

	var segment_angle = TAU / float(segment_count)
	var padding_angle = deg_to_rad(padding)
	var steps = 20
	var radius_steps = max(2, border_radius / 2)

	for i in range(segment_count):
		var start_angle = i * segment_angle + padding_angle
		var end_angle = (i + 1) * segment_angle - padding_angle
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
			points.append(Vector2(cos(angle), sin(angle)) * r)

		# Inner arc
		for s in range(steps, -1, -1):
			var t = float(s) / float(steps)
			var angle = lerp(start_angle, end_angle, t)
			var r = inner_radius
			if s < radius_steps:
				r = inner_radius + border_radius * (1.0 - float(s) / radius_steps)
			elif s > steps - radius_steps:
				r = inner_radius + border_radius * (1.0 - float(steps - s) / radius_steps)
			points.append(Vector2(cos(angle), sin(angle)) * r)

		segment_nodes[i].polygon = points
		segment_nodes[i].position = Vector2.ZERO

		var mid_angle = (start_angle + end_angle) / 2
		var mid_radius = (inner_radius + outer_radius) / 2
		image_nodes[i].position = Vector2(cos(mid_angle), sin(mid_angle)) * mid_radius

# --------------------------------------------------------------------
# Interact
# --------------------------------------------------------------------

func _handle_hover() -> void:
	var mouse_pos = get_local_mouse_position()
	var segment_count = len(segment_nodes)
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
		
func _input(event: InputEvent):
	if event and InputEventMouseButton and event.is_action_pressed("LEFT_MOUSE_CLICK") and event.is_pressed():
		var get_control_group = selection_wheel.get_groups()[0]
		
		if hovered_index >= 0 and get_control_group == "placing_tower":
			PlacingSystem.chosen_placing_tower(hovered_index)
			
		elif hovered_index >= 0 and get_control_group == "tower_upgrade":
			var tower = get_meta("tower_ref")
			if tower and is_instance_valid(tower):
				tower._attemp_upgrade(hovered_index)
				Global.close_ui(selection_wheel)
			
# --------------------------------------------------------------------
# Animation
# --------------------------------------------------------------------

func _global_hover_animation(_delta: float) -> void:
	UIAnimations.update_segment_hover_physics(
		_delta,
		segment_nodes,
		image_nodes,
		segment_scales,
		segment_velocities,
		hovered_index,
		base_color,
		hover_color,
		inner_radius,
		outer_radius,
	)
