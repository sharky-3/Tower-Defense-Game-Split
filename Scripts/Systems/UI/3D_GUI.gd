""" [[ ============================================================ ]] """
extends Node3D
""" [[ ============================================================ ]] """

""" [[ Node references ]] """
@onready var ui: Node3D = $"."
@onready var node_viewport = $SubViewport
@onready var node_quad = $Quad
@onready var node_area = $Quad/Area3D

""" [[ Stats ]] """
var is_mouse_inside: bool = false
var last_event_pos2D = null
var last_event_time: float = -1.0

""" [[ ============================================================
	// FUNCTIONS
]] """

""" [[ ============================================================ ]] """
""" [[ Ready ]] """
func _ready():
	node_area.mouse_entered.connect(_mouse_entered_area)
	node_area.mouse_exited.connect(_mouse_exited_area)
	node_area.input_event.connect(_mouse_input_event)

	if node_quad.get_surface_override_material(0).billboard_mode == BaseMaterial3D.BillboardMode.BILLBOARD_DISABLED:
		set_process(false)

""" [[ Process ]] """
func _process(_delta):
	rotate_area_to_billboard()

""" [[ ============================================================ ]] """
""" [[ Mouse Entered ]] """
func _mouse_entered_area():
	is_mouse_inside = true

""" [[ Mouse Left ]] """
func _mouse_exited_area():
	is_mouse_inside = false
	
#func _unhandled_input(event):
	#for mouse_event in [InputEventMouseButton, InputEventMouseMotion, InputEventScreenDrag, InputEventScreenTouch]:
		#if is_instance_of(event, mouse_event):
			#return
	#node_viewport.push_input(event)

""" [[ Mouse Event / Ineraction With UI ]] """
func _mouse_input_event(_camera: Camera3D, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int):
	var quad_mesh_size = node_quad.mesh.size
	var event_pos2D = Vector2()

	if is_mouse_inside:
		var local_pos = node_quad.global_transform.affine_inverse() * event_position

		event_pos2D.x = local_pos.x / quad_mesh_size.x + 0.5
		event_pos2D.y = -local_pos.y / quad_mesh_size.y + 0.5

		event_pos2D.x *= node_viewport.size.x
		event_pos2D.y *= node_viewport.size.y

	elif last_event_pos2D != null:
		event_pos2D = last_event_pos2D

	event.position = event_pos2D
	if event is InputEventMouse:
		event.global_position = event_pos2D

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

""" [[ ============================================================ ]] """
""" [[ Rotate BillBoard ]] """
func rotate_area_to_billboard():
	var material = node_quad.get_surface_override_material(0)
	var billboard_mode = material.billboard_mode if material else BaseMaterial3D.BILLBOARD_DISABLED
	if billboard_mode == BaseMaterial3D.BILLBOARD_DISABLED:
		return

	var camera = get_viewport().get_camera_3d()
	if camera == null:
		return 

	var look = camera.to_global(Vector3(0, 0, -100)) - camera.global_transform.origin
	look = ui.position + look

	if billboard_mode == BaseMaterial3D.BILLBOARD_FIXED_Y:
		look = Vector3(look.x, 0, look.z)

	ui.look_at(look, Vector3.UP)
	ui.rotate_object_local(Vector3.BACK, camera.rotation.z)
