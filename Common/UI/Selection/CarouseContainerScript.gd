extends Node2D
class_name CarouselContainer

# --- Constants / Exported Data ---
@export var spacing: float = 20.0

@export var wraparound_enabled: bool = false
@export var wraparound_radius: float = 300.0
@export var wraparound_height: float = 50.0

@export_range(0.0, 1.0) var opacity_strength: float = 0.35
@export_range(0.0, 1.0) var scale_strength: float = 0.25
@export_range(0.01, 0.99, 0.01) var scale_min: float = 0.1

@export var smoothing_speed: float = 6.5
@export var selected_index: int = 0
@export var follow_button_focus: bool = false

@export var images: Array[Texture2D] = []
@export var image_stretch_mode := TextureRect.STRETCH_KEEP_ASPECT_CENTERED

@export var position_offset_node: Control

# --- Stats ---
var item_scales: Array = []
var item_velocities: Array = []
var original_colors: Array = []

# --- Click Tracking ---
var clicked_towers: Array = []
var max_selected_towers: int = 4

# --------------------------------------------------------------------
# Life Cycle
# --------------------------------------------------------------------

func _ready():
	_setup_child_images()

func _process(delta: float) -> void:
	if position_offset_node == null:
		return

	var children := position_offset_node.get_children()
	if children.is_empty():
		return

	selected_index = clamp(selected_index, 0, children.size() - 1)

	for i in range(children.size()):
		var child := children[i]
		if not child is Control:
			continue
		child.pivot_offset = child.size * 0.5

		# ---------------- POSITION ----------------
		var target_position: Vector2
		if wraparound_enabled:
			var max_range = max(1.0, (children.size() - 1) / 2.0)
			var angle = clamp((i - selected_index) / max_range, -1.0, 1.0) * PI

			var x := sin(angle) * wraparound_radius
			var y := cos(angle) * wraparound_height

			target_position = Vector2(
				x - child.size.x * 0.5,
				y - wraparound_height - child.size.y * 0.5
			)
		else:
			var x := 0.0
			if i > 0:
				var prev := children[i - 1] as Control
				x = prev.position.x + prev.size.x + spacing

			target_position = Vector2(
				x,
				-child.size.y * 0.5
			)

		child.position = child.position.lerp(target_position, smoothing_speed * delta)

		# ---------------- OPACITY + CLICK COLOR ----------------
		var target_alpha = 1.0 - opacity_strength * abs(i - selected_index)
		target_alpha = clamp(target_alpha, 0.0, 1.0)

		var mod = child.modulate

		if clicked_towers != null and clicked_towers.has(i):
			mod.r = 0.7
			mod.g = 1.0
			mod.b = 0.7
		else:
			mod.r = 1.0
			mod.g = 1.0
			mod.b = 1.0

		mod.a = lerp(mod.a, target_alpha, smoothing_speed * delta)
		child.modulate = mod

		# ---------------- Z-ORDER ----------------
		child.z_index = -abs(i - selected_index)
		if i == selected_index:
			child.z_index = 1

		# ---------------- FOCUS FOLLOW ----------------
		if follow_button_focus and child.has_focus():
			selected_index = i

	# ---------------- SCALE (SPRING-BASED) ----------------
	_update_selected_item_physics(delta)

	# ---------------- CONTAINER OFFSET ----------------
	if wraparound_enabled:
		position_offset_node.position.x = lerp(position_offset_node.position.x, 0.0, smoothing_speed * delta)
	else:
		var selected := children[selected_index] as Control
		var target_x := -(selected.position.x + selected.size.x * 0.5)
		position_offset_node.position.x = lerp(position_offset_node.position.x, target_x, smoothing_speed * delta)

# --------------------------------------------------------------------
# Set Up Images
# --------------------------------------------------------------------

func _setup_child_images() -> void:
	if position_offset_node == null:
		return

	var children := position_offset_node.get_children()

	item_scales.clear()
	item_velocities.clear()

	for i in range(children.size()):
		var child := children[i]
		if not child is Control:
			continue

		child.connect("gui_input", Callable(self, "_on_child_gui_input").bind(i))

		item_scales.append(1.0)
		item_velocities.append(0.0)

		# --- Add / Configure TextureRect ---
		var tex_rect: TextureRect = null
		for c in child.get_children():
			if c is TextureRect:
				tex_rect = c
				break

		if tex_rect == null:
			tex_rect = TextureRect.new()
			tex_rect.name = "CarouselImage"
			tex_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

			tex_rect.anchor_left = 0.0
			tex_rect.anchor_top = 0.0
			tex_rect.anchor_right = -0.25
			tex_rect.anchor_bottom = -0.25

			tex_rect.offset_left = 0
			tex_rect.offset_top = 0
			tex_rect.offset_right = 0
			tex_rect.offset_bottom = 0

			tex_rect.position = Vector2.ZERO
			tex_rect.size = child.size * 1.5

			tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tex_rect.expand = true
			child.add_child(tex_rect)

		tex_rect.stretch_mode = image_stretch_mode

		if i < images.size():
			tex_rect.texture = images[i]

# --------------------------------------------------------------------
# Spring Physics for Selected Item
# --------------------------------------------------------------------

func _update_selected_item_physics(delta: float) -> void:
	if position_offset_node == null:
		return

	var children := position_offset_node.get_children()
	if children.is_empty():
		return

	for i in range(children.size()):
		var child := children[i]
		if not child is Control:
			continue

		var base_scale = 1.0 - scale_strength * abs(i - selected_index)
		base_scale = clamp(base_scale, scale_min, 1.0)

		var target_scale = base_scale
		if i == selected_index:
			target_scale = UIAnimations.hover_scale

		var x = item_scales[i] - target_scale
		var force = -UIAnimations.stiffness * x - UIAnimations.damping * item_velocities[i]
		var acceleration = force / UIAnimations.mass

		item_velocities[i] += acceleration * delta
		item_scales[i] += item_velocities[i] * delta

		child.scale = Vector2.ONE * item_scales[i]

		var tex_rect: TextureRect = null
		for c in child.get_children():
			if c is TextureRect:
				tex_rect = c
				break

		if tex_rect:
			if i == selected_index:
				var image_offset_y = -100.0
				tex_rect.position.y = lerp(tex_rect.position.y, image_offset_y, smoothing_speed * delta)
			else:
				tex_rect.position.y = lerp(tex_rect.position.y, 0.0, smoothing_speed * delta)

# --------------------------------------------------------------------
# Inputs
# --------------------------------------------------------------------

func _on_child_gui_input(event: InputEvent, index: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if clicked_towers.has(index):
			clicked_towers.erase(index)
		elif clicked_towers.size() < max_selected_towers:
			clicked_towers.append(index)
		else:
			return

func move_left() -> void:
	selected_index = max(selected_index - 1, 0)

func move_right() -> void:
	if position_offset_node == null:
		return

	var max_index = position_offset_node.get_child_count() - 1
	if selected_index < max_index:
		selected_index += 1
