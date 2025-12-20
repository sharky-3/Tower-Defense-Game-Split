extends Node3D

@onready var camera_3d: Camera3D = $Camera3D
@onready var map_design: Button = $UserInterface/MapDesign

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

var is_spectating := false

func _ready() -> void:
	camera_transform["position"]["original"] = camera_3d.position
	camera_transform["rotation"]["original"] = camera_3d.rotation_degrees

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
