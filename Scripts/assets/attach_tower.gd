extends Node3D
@onready var TOWER: Node3D = $"."
@onready var tower_mesh: MeshInstance3D = $Mesh

@onready var range: MeshInstance3D = $Range
@onready var collision: CollisionShape3D = $Range/Area3D/Collision
@onready var area_3d: Area3D = $Range/Area3D
@onready var timer: Timer = $Timer
@onready var camera_ray_cast: RayCast3D = get_node("/root/World/CameraPosition/CameraRotationX/CameraZoomPivot/Camera3D/RayCast3D")
@onready var camera: Camera3D = get_node("/root/World/CameraPosition/CameraRotationX/Camera3D")

@export var upgrade_values := {
	0: {
		"mesh": preload("uid://b6v01fbf56avq"),
		"range": 7,
		"damage": 5
	},
	1: {
		"mesh": preload("uid://u0rl2763vgxr"),
		"range": 10,
		"damage": 8
	},
	2: {
		"mesh": preload("uid://bvuqt0fd5kq1y"),
		"range": 13,
		"damage": 11
	}
}
var RANGE_VALUE: float = upgrade_values[0]["range"]
var TOWER_DAMAGE: float = upgrade_values[0]["damage"]

var enemies_in_range: Array = []
var can_upgrade: bool = false
var CURRENT_UPGRADE: int = 0

func _process(delta):
	_update_ray_from_mouse()

func _update_ray_from_mouse():
	if not camera: return
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000
	camera_ray_cast.cast_to = to - camera_ray_cast.global_transform.origin
	camera_ray_cast.force_update_transform()


func _ready() -> void:
	timer.connect("timeout", Callable(self, "_on_Timer_timeout"))
	timer.start()
	_update_range(RANGE_VALUE)

	area_3d.body_shape_entered.connect(Callable(self, "_on_area_3d_body_shape_entered"))
	area_3d.body_shape_exited.connect(Callable(self, "_on_area_3d_body_shape_exited"))
	_enable_upgrade_after_delay()
	
func _enable_upgrade_after_delay() -> void:
	await get_tree().create_timer(2.0).timeout
	can_upgrade = true

func _on_Timer_timeout():
	if enemies_in_range.size() > 0:
		var target = enemies_in_range[0]
		shoot(target)

func _update_range(value: float) -> void:
	RANGE_VALUE = value
	range.scale = Vector3(value, .1, value)

func shoot(target):
	var enemy_node = target.get_parent().get_parent()
	if enemy_node: enemy_node.take_damage(TOWER_DAMAGE)
		
func upgrade_tower(data):
	var new_mesh = data["mesh"]
	var new_range = data["range"]
	var new_damage = data["damage"]
	
	_update_range(new_range)
	TOWER_DAMAGE = new_damage
	tower_mesh.mesh = new_mesh
	
func _on_area_3d_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if body and body.is_in_group("Enemy"): 
		enemies_in_range.append(body)

func _on_area_3d_body_shape_exited(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if body and body.is_in_group("Enemy"): 
		enemies_in_range.erase(body)

func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and can_upgrade:
		_update_ray_from_mouse()
		
		if camera_ray_cast and camera_ray_cast.is_colliding():
			var collider = camera_ray_cast.get_collider()
			print(collider)
			if collider == TOWER:
				CURRENT_UPGRADE += 1
				if not upgrade_values.has(CURRENT_UPGRADE): return
				upgrade_tower(upgrade_values[CURRENT_UPGRADE])
