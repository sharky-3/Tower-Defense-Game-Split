""" [[ ============================================================ ]] """
extends Node3D
""" [[ ============================================================ ]] """

""" [[ Constants / Exported Data ]] """
@export var smooth_speed: float = 6.0
@export var max_yaw: float = 10.0      
@export var max_pitch: float = 7.0  

""" [[ Node references ]] """
@onready var camera_3d: Camera3D = $SubViewportContainer/SubViewport/Camera3D

""" [[ Stats ]] """
var screen_center: Vector2
var is_spectating := false
var camera_transform := {
	"position": {
		"original": Vector3.ZERO,
		"spectating": Vector3(-20, 15, 10),
	},
	"rotation": {
		"original": Vector3.ZERO,
		"spectating": Vector3(-50, -50, 0),
	}
}

""" [[ ============================================================ ]] """
""" [[ LifeCycle ]] """

func _ready() -> void:
	camera_transform["position"]["original"] = camera_3d.position
	camera_transform["rotation"]["original"] = camera_3d.rotation_degrees

	screen_center = get_viewport().get_visible_rect().size / 2

func _process(delta: float) -> void:
	var mouse_pos = get_viewport().get_mouse_position()

	var dir = (mouse_pos - screen_center) / screen_center
	dir = dir.clamp(Vector2(-1, -1), Vector2(1, 1))

	var rotation_offset := Vector3(
		-dir.y * max_pitch, 
		-dir.x * max_yaw, 
		0
	)

	var base_rotation: Vector3 = (
		camera_transform["rotation"]["spectating"]
		if is_spectating
		else camera_transform["rotation"]["original"]
	)

	# Apply smooth rotation
	var target_rotation := base_rotation + rotation_offset
	camera_3d.rotation_degrees = camera_3d.rotation_degrees.lerp(
		target_rotation,
		smooth_speed * delta
	)

""" [[ ============================================================ ]] """
""" [[ Functions ]] """

func _on_map_design_pressed() -> void:
	var tween := create_tween()
	tween.set_parallel(true)

	var target_position: Vector3
	var target_rotation: Vector3

	if not is_spectating:
		target_position = camera_transform["position"]["spectating"]
		target_rotation = camera_transform["rotation"]["spectating"]
	else:
		target_position = camera_transform["position"]["original"]
		target_rotation = camera_transform["rotation"]["original"]

	tween.tween_property(
		camera_3d,
		"position",
		target_position,
		0.6
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		camera_3d,
		"rotation_degrees",
		target_rotation,
		0.6
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	is_spectating = !is_spectating
