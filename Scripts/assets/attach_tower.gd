extends Node3D

@onready var range: MeshInstance3D = $Range
@onready var collision: CollisionShape3D = $Range/Area3D/Collision
@onready var area_3d: Area3D = $Range/Area3D
@onready var timer: Timer = $Timer

@export var RANGE_VALUE: float = 5
@export var TOWER_DAMAGE: float = 5

var enemies_in_range: Array = []

func _ready() -> void:
	timer.connect("timeout", Callable(self, "_on_Timer_timeout"))
	timer.start()
	_update_range(RANGE_VALUE)

	area_3d.body_shape_entered.connect(Callable(self, "_on_area_3d_body_shape_entered"))
	area_3d.body_shape_exited.connect(Callable(self, "_on_area_3d_body_shape_exited"))

func _on_Timer_timeout():
	if enemies_in_range.size() > 0:
		var target = enemies_in_range[0]
		shoot(target)

func _update_range(value: float) -> void:
	range.scale = Vector3(value, 0.1, value)

func shoot(target):
	var enemy_node = target.get_parent().get_parent()
	if enemy_node:
		enemy_node.take_damage(TOWER_DAMAGE)

func _on_area_3d_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if body and body.is_in_group("Enemy"): 
		enemies_in_range.append(body)

func _on_area_3d_body_shape_exited(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if body and body.is_in_group("Enemy"): 
		enemies_in_range.erase(body)
