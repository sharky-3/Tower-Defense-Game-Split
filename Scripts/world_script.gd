extends Node3D

@onready var player_tower: Node3D = $Map/PlayerTower
@onready var spawn_enemy_position: Node3D = $Map/spawn_enemy_position
const Enemy = preload("res://scenes/characters/enemy.tscn")

var spawn_interval: float = 2.0
var spawn_timer: float = 0.0

func _process(delta: float) -> void:
	if player_tower.is_alive:
		get_tree().call_group("enemy", "target_position", player_tower.global_transform.origin)
	
	# Handle enemy spawning
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		spawn_enemy()

func spawn_enemy() -> void:
	if player_tower.is_alive:
		var enemy_instance = Enemy.instantiate()
		add_child(enemy_instance)
		if is_instance_valid(spawn_enemy_position):
			enemy_instance.global_transform.origin = spawn_enemy_position.global_transform.origin
		enemy_instance.add_to_group("enemy")
