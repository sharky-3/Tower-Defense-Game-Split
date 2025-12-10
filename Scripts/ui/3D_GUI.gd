extends Node3D

# Used for checking if the mouse is inside the Area3D.
var is_mouse_inside = false
# The last processed input touch/mouse event. To calculate relative movement.
var last_event_pos2D = null
# The time of the last event in seconds since engine start.
var last_event_time: float = -1.0
@onready var ui: Node3D = $"."

@onready var node_viewport = $SubViewport
@onready var node_quad = $Quad
@onready var node_area = $Quad/Area3D

func _ready():
	node_area.mouse_entered.connect(_mouse_entered_area)
	node_area.mouse_exited.connect(_mouse_exited_area)
	node_area.input_event.connect(_mouse_input_event)

	# If the material is NOT set to use billboard settings, then avoid running billboard specific code
	if node_quad.get_surface_override_material(0).billboard_mode == BaseMaterial3D.BillboardMode.BILLBOARD_DISABLED:
		set_process(false)


func _process(_delta):
	# NOTE: Remove this function if you don't plan on using billboard settings.
	rotate_area_to_billboard()


func _mouse_entered_area():
	is_mouse_inside = true


func _mouse_exited_area():
	is_mouse_inside = false


func _unhandled_input(event):
	# Check if the event is a non-mouse/non-touch event
	for mouse_event in [InputEventMouseButton, InputEventMouseMotion, InputEventScreenDrag, InputEventScreenTouch]:
		if is_instance_of(event, mouse_event):
			# If the event is a mouse/touch event, then we can ignore it here, because it will be
			# handled via Physics Picking.
			return
	node_viewport.push_input(event)


func _mouse_input_event(_camera: Camera3D, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int):
	var quad_mesh_size = node_quad.mesh.size
	var event_pos2D = Vector2()

	if is_mouse_inside:
		# Convert global event position to local quad space
		var local_pos = node_quad.global_transform.affine_inverse() * event_position

		# Map quad local coordinates to 0->1 range
		event_pos2D.x = local_pos.x / quad_mesh_size.x + 0.5
		event_pos2D.y = -local_pos.y / quad_mesh_size.y + 0.5 # invert Y to match viewport

		# Convert to viewport coordinates
		event_pos2D.x *= node_viewport.size.x
		event_pos2D.y *= node_viewport.size.y

	elif last_event_pos2D != null:
		event_pos2D = last_event_pos2D

	# Update event positions
	event.position = event_pos2D
	if event is InputEventMouse:
		event.global_position = event_pos2D

	# Handle relative motion
	var now = Time.get_ticks_msec() / 1000.0
	if event is InputEventMouseMotion or event is InputEventScreenDrag:
		if last_event_pos2D == null:
			event.relative = Vector2.ZERO
		else:
			event.relative = event_pos2D - last_event_pos2D
			event.velocity = event.relative / (now - last_event_time)

	last_event_pos2D = event_pos2D
	last_event_time = now

	node_viewport.push_input(event)



func rotate_area_to_billboard():
	var material = node_quad.get_surface_override_material(0)
	var billboard_mode = material.billboard_mode if material else BaseMaterial3D.BILLBOARD_DISABLED
	if billboard_mode == BaseMaterial3D.BILLBOARD_DISABLED:
		return

	var camera = get_viewport().get_camera_3d()
	if camera == null:
		return # Avoid null instance errors

	var look = camera.to_global(Vector3(0, 0, -100)) - camera.global_transform.origin
	look = ui.position + look

	if billboard_mode == BaseMaterial3D.BILLBOARD_FIXED_Y:
		look = Vector3(look.x, 0, look.z)

	ui.look_at(look, Vector3.UP)
	ui.rotate_object_local(Vector3.BACK, camera.rotation.z)
