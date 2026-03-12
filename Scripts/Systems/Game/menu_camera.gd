extends Node3D 

var rotation_speed = 20.0 

func _process(delta: float) -> void:
	rotation.y += deg_to_rad(rotation_speed * delta)
