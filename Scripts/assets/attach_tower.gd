extends Node3D

# --- Constants / Exported Data ---
@export var upgrade_values := {
	0: { "mesh": preload("uid://b6v01fbf56avq"), "range": 7, "damage": 5 },
	1: { "mesh": preload("uid://u0rl2763vgxr"), "range": 10, "damage": 8 },
	2: { "mesh": preload("uid://bvuqt0fd5kq1y"), "range": 13, "damage": 11 }
}

# --- Node references ---
@onready var tower_body_mesh: MeshInstance3D = $Mesh

@onready var range: MeshInstance3D = $Range
@onready var collision: CollisionShape3D = $Range/Area3D/Collision
@onready var area_3d: Area3D = $Range/Area3D

@onready var timer: Timer = $Timer
@onready var camera_ray_cast: RayCast3D = get_node("/root/World/CameraPosition/CameraRotationX/CameraZoomPivot/Camera3D/RayCast3D")
@onready var camera: Camera3D = get_node("/root/World/CameraPosition/CameraRotationX/Camera3D")

# --- State ---
var current_upgrade: int = 0
var can_upgrade: bool = false

var enemies_in_range: Array = []
var tower_range: float = 0.0
var tower_damage: float = 0.0

# --------------------------------------------------------------------
# Life Cycle
# --------------------------------------------------------------------

func _ready() -> void:
	_load_upgrade_level(0)
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	timer.start()

	area_3d.body_shape_entered.connect(Callable(self, "_on_area_3d_body_shape_entered"))
	area_3d.body_shape_exited.connect(Callable(self, "_on_area_3d_body_shape_exited"))
	_enable_upgrade_after_delay()
	
func _process(_delta) -> void:
	_update_ray_from_mouse()

# --------------------------------------------------------------------
# Ray Updating
# --------------------------------------------------------------------

func _update_ray_from_mouse():
	if not camera: return
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000
	
	camera_ray_cast.cast_to = to - camera_ray_cast.global_transform.origin
	camera_ray_cast.force_update_transform()

# --------------------------------------------------------------------
# Upgrading
# --------------------------------------------------------------------
	
func _enable_upgrade_after_delay() -> void:
	await get_tree().create_timer(2.0).timeout
	can_upgrade = true

func _load_upgrade_level(level: int) -> void:
	if not upgrade_values.has(level): return
	current_upgrade = level
	
	var data = upgrade_values[current_upgrade]

	tower_range  = data["range"]
	tower_damage = data["damage"]

	_update_range_mesh(tower_range)
	tower_body_mesh.mesh = data["mesh"]
	
func _attemp_upgrade() -> void:
	if not can_upgrade: return
	_load_upgrade_level(current_upgrade + 1)
	
func _update_range_mesh(value: float) -> void:
	range.scale = Vector3(value, .1, value)
	
# --------------------------------------------------------------------
# Combat
# --------------------------------------------------------------------

func _on_timer_timeout():
	if enemies_in_range.is_empty(): return
	
	var target = enemies_in_range[0]
	_shoot_enemy(target)

func _shoot_enemy(target: Node3D) -> void:
	var enemy_node := target.get_parent().get_parent()
	if enemy_node and enemy_node.has_method("take_damage"):
		enemy_node.take_damage(tower_damage)

# --------------------------------------------------------------------
# Detection
# --------------------------------------------------------------------

func _on_area_3d_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if body and body.is_in_group("Enemy"): 
		enemies_in_range.append(body)

func _on_area_3d_body_shape_exited(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if body and body.is_in_group("Enemy"): 
		enemies_in_range.erase(body)

# --------------------------------------------------------------------
# Input
# --------------------------------------------------------------------

func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and can_upgrade:
		_update_ray_from_mouse()
		_attemp_upgrade()
