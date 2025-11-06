extends Node3D

@onready var player_tower: Node3D = $PlayerTower

func _process(_delta) -> void:
	get_tree().call_group("enemy", "target_position", player_tower.global_transform.origin)
