extends Node3D

# =============================================
# ONREADY
@onready var camera_rotation_x: Node3D = $CameraRotationX
@onready var camera_zoom_pivot: Node3D = $CameraRotationX/CameraZoomPivot
@onready var camera: Camera3D = $CameraRotationX/CameraZoomPivot/Camera3D

# =============================================
# VARIABLES
var move_speed: float = .6
var move_target: Vector3
var rotate_keys_speed: float = 1.5
var rotate_keys_target: float

var mouse_sensitivity: float = 0.01
var edge_size = 5.0
var scroll_speed = .6

var zoom_speed = 3.0
var zoom_target: float
var min_zoom = -20.0
var max_zoom = 20.0

var max_distance_from_center: float = 100.0 

# new – damping speeds
var smooth_pos_lerp := 10.0
var smooth_rot_lerp := 10.0
var smooth_zoom_lerp := 12.0
var smooth_pitch_lerp := 12.0

# internal pitch target
var pitch_target := 0.0

# =============================================
# READY
func _ready() -> void:
	move_target = position
	rotate_keys_target = rotation.y
	zoom_target = camera.position.z
	pitch_target = camera_rotation_x.rotation.x

# =============================================
# MOUSE 
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_action_pressed("rotate"):
		# yaw
		rotate_keys_target -= event.relative.x * mouse_sensitivity
		
		# pitch
		pitch_target -= event.relative.y * mouse_sensitivity
		pitch_target = clamp(
			pitch_target,
			deg_to_rad(-90),
			deg_to_rad(20)
		)

# =============================================
# PROCESS
func _process(delta: float) -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	var viewport_size = get_viewport().get_visible_rect().size
	var scroll_direction = Vector3.ZERO
	
	if mouse_pos.x < edge_size: scroll_direction.x = -1
	elif mouse_pos.x > viewport_size.x - edge_size: scroll_direction.x = 1
	if mouse_pos.y < edge_size: scroll_direction.z = -1
	elif mouse_pos.y > viewport_size.y - edge_size: scroll_direction.z = 1
	move_target += transform.basis * scroll_direction * scroll_speed
	
	# input
	if Input.is_action_just_pressed("rotate"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if Input.is_action_just_released("rotate"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# movement WASD
	var input_direction = Input.get_vector("left", "right", "up", "down")
	var movement_direction = (transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	move_target += move_speed * movement_direction
	
	# clamp move_target to max distance from center (X and Z)
	move_target.x = clamp(move_target.x, -max_distance_from_center, max_distance_from_center)
	move_target.z = clamp(move_target.z, -max_distance_from_center, max_distance_from_center)

	# rotate keyboard
	var rotate_keys = Input.get_axis("rotate_right", "rotate_left")
	rotate_keys_target += rotate_keys * rotate_keys_speed * delta
	
	# zoom
	var zoom_dir = (
		int(Input.is_action_just_released("camera_zoom_out")) - 
		int(Input.is_action_just_released("camera_zoom_in"))
	)
	zoom_target += zoom_dir * zoom_speed
	zoom_target = clamp(zoom_target, min_zoom, max_zoom)

	# =============================================
	# apply smoothed damp
	position = position.lerp(move_target, clamp(smooth_pos_lerp * delta, 0, 1))
	rotation.y = lerp_angle(rotation.y, rotate_keys_target, clamp(smooth_rot_lerp * delta, 0, 1))
	camera.position.z = lerp(camera.position.z, zoom_target, clamp(smooth_zoom_lerp * delta, 0, 1))
	camera_rotation_x.rotation.x = lerp(camera_rotation_x.rotation.x, pitch_target, clamp(smooth_pitch_lerp * delta, 0, 1))
