extends Node3D

# --- Node references ---
@onready var camera_rotation_x: Node3D = $CameraRotationX
@onready var camera_zoom_pivot: Node3D = $CameraRotationX/CameraZoomPivot
@onready var camera: Camera3D = $CameraRotationX/CameraZoomPivot/Camera3D

# --- Constants / Exported Data ---
@export var max_distance_from_center: float = 25
@export var center_point: Vector3 = Vector3(0,0,0)

# --- State ---
const EDGE_SIZE: float = 5.0

var move_speed := 0.6
var move_target := Vector3.ZERO

var rotate_keys_speed := 1.5
var rotate_keys_target := 0.0
var mouse_sensitivity := 0.01

var zoom_speed := 4.0
var zoom_target := 0.0
var min_zoom := -20.0
var max_zoom := 20.0

var smooth_pos_lerp := 10.0
var smooth_rot_lerp := 10.0
var smooth_zoom_lerp := 12.0
var smooth_pitch_lerp := 12.0

var pitch_target := 0.0

# --------------------------------------------------------------------
# Life Cycle
# --------------------------------------------------------------------

func _ready():
	move_target = position
	rotate_keys_target = rotation.y
	zoom_target = camera.position.z
	pitch_target = camera_rotation_x.rotation.x

func _process(delta):
	handle_edge_pan()
	handle_rotate_keys(delta)
	handle_wasd_movement()
	handle_zoom()

	clamp_to_bounds()
	apply_smoothing(delta)

func _unhandled_input(event):
	handle_mouse_rotation(event)

# --------------------------------------------------------------------
# Input Handlers
# --------------------------------------------------------------------

func handle_wasd_movement():
	var input_dir := Input.get_vector("left", "right", "up", "down")
	if input_dir != Vector2.ZERO:
		var move_vec := transform.basis * Vector3(input_dir.x, 0, input_dir.y)
		move_target += move_vec.normalized() * move_speed

func handle_edge_pan():
	var mouse_pos := get_viewport().get_mouse_position()
	var view := get_viewport().get_visible_rect().size
	var pan := Vector3.ZERO

	if mouse_pos.x < EDGE_SIZE:
		pan.x = -1
	elif mouse_pos.x > view.x - EDGE_SIZE:
		pan.x = 1

	if mouse_pos.y < EDGE_SIZE:
		pan.z = -1
	elif mouse_pos.y > view.y - EDGE_SIZE:
		pan.z = 1

	if pan.length_squared() > 0:
		move_target += transform.basis * pan * move_speed

func handle_rotate_keys(delta):
	var axis := Input.get_axis("rotate_right", "rotate_left")
	if axis != 0:
		rotate_keys_target += axis * rotate_keys_speed * delta

func handle_zoom():
	var zoom_dir := (
		int(Input.is_action_just_released("camera_zoom_out")) -
		int(Input.is_action_just_released("camera_zoom_in"))
	)
	if zoom_dir != 0:
		zoom_target = clamp(zoom_target + zoom_dir * zoom_speed, min_zoom, max_zoom)

func handle_mouse_rotation(event):
	if event is InputEventMouseMotion and Input.is_action_pressed("rotate"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		rotate_keys_target -= event.relative.x * mouse_sensitivity

		pitch_target -= event.relative.y * mouse_sensitivity
		pitch_target = clamp(pitch_target, deg_to_rad(-90), deg_to_rad(20))

	elif event is InputEventMouseButton and event.is_released():
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# --------------------------------------------------------------------
# Utility
# --------------------------------------------------------------------

func clamp_to_bounds():
	move_target.x = clamp(
		move_target.x,
		center_point.x - max_distance_from_center,
		center_point.x + max_distance_from_center
	)

	move_target.z = clamp(
		move_target.z,
		center_point.z - max_distance_from_center,
		center_point.z + max_distance_from_center
	)

func apply_smoothing(delta):
	var p_lerp = clamp(smooth_pos_lerp * delta, 0, 1)
	var r_lerp = clamp(smooth_rot_lerp * delta, 0, 1)
	var z_lerp = clamp(smooth_zoom_lerp * delta, 0, 1)
	var pitch_lerp = clamp(smooth_pitch_lerp * delta, 0, 1)

	position = position.lerp(move_target, p_lerp)
	rotation.y = lerp_angle(rotation.y, rotate_keys_target, r_lerp)
	camera.position.z = lerp(camera.position.z, zoom_target, z_lerp)
	camera_rotation_x.rotation.x = lerp(camera_rotation_x.rotation.x, pitch_target, pitch_lerp)
