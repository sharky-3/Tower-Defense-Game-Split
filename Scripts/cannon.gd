extends Node3D

# =============================================
# ONREADY
@onready var raycasts = [$Mesh/Ray1, $Mesh/Ray2, $Mesh/Ray3, $Mesh/Ray4]
@export var meshes: Array[MeshInstance3D]
@onready var area: Area3D = $Mesh/Area3D
@onready var green_mat = preload("res://Sprites/Material/placement_green.tres")
@onready var red_mat = preload("res://Sprites/Material/placement_red.tres")

# =============================================
# PLACEMENT
func check_placement() -> bool:
	for ray in raycasts:
		ray.force_raycast_update() 
		if !ray.is_colliding():
			placement_red()
			return false
	if area.get_overlapping_areas():
		placement_red()
		return false
	placement_green()
	return true

func placed() -> void:
	for mesh in meshes:
		mesh.material_override = null
	for ray in raycasts:
		ray.queue_free()

func placement_red() -> void:
	for mesh in meshes:
		mesh.material_override = red_mat

func placement_green() -> void:
	for mesh in meshes:
		mesh.material_override = green_mat
