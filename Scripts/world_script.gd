extends Node3D

@onready var player_tower: Node3D = $Map/PlayerTower
@onready var spawn_enemy_position: Node3D = $Map/spawn_enemy_position
const Enemy = preload("res://Scenes/Characters/enemy_character.tscn")

@export var total_waves: int = 5
@export var enemies_per_wave: Array[int] = [2, 2, 2, 2, 2]
@export var time_between_waves: float = 15.0
@export var difficulty_per_wave: Array[float] = [1, 1.2, 1.5, 1.8, 2.0]
@export var spawn_radius: float = 10

const GOBLIN_1 = preload("uid://bfygdhktxcdvx")
const GOBLIN_2 = preload("uid://dgan33wtxphvc")
const GOBLIN_3 = preload("uid://bw7tyjpxy3ku8")
const GOBLIN_4 = preload("uid://dnih7xrttht20")
const SKELETON_1 = preload("uid://ddj4r3bygamt8")
const SKELETON_2 = preload("uid://u23q3r8bpqan")
const SKELETON_3 = preload("uid://conmtsecxcsp8")

@export var enemy_types: Array[Mesh] = [
	GOBLIN_1, GOBLIN_2, GOBLIN_3, GOBLIN_4,
	SKELETON_1, SKELETON_2, SKELETON_3
]

var current_wave: int = 0
var waiting_for_next_wave: bool = false
var wave_cooldown_timer: float = 0.0

func _ready() -> void:
	# Start the wave system when the scene is ready
	start_waves()

# Coroutine to handle all waves sequentially
func start_waves() -> void:
	for wave_index in range(total_waves):
		var enemy_count = enemies_per_wave[wave_index]
		var difficulty = difficulty_per_wave[wave_index] if wave_index < difficulty_per_wave.size() else 1.0

		for i in range(enemy_count):
			spawn_enemy(difficulty)
			await get_tree().create_timer(0.1).timeout  

		await get_tree().create_timer(time_between_waves).timeout

# Spawn a single enemy
func spawn_enemy(difficulty: float) -> void:
	var enemy_instance = Enemy.instantiate()
	add_child(enemy_instance)
	enemy_instance.add_enemy_to_group()

	if is_instance_valid(spawn_enemy_position):
		var min_distance = 6.0
		var max_distance = spawn_radius
		var distance = randf_range(min_distance, max_distance)
		
		var angle = randf_range(0, TAU) 
		
		var random_offset = Vector3(
			cos(angle) * distance,
			0,
			sin(angle) * distance
		)
		
		enemy_instance.global_transform.origin = spawn_enemy_position.global_transform.origin + random_offset

	enemy_instance.set_difficulty(difficulty)

	var chosen_mesh = enemy_types[randi() % enemy_types.size()]
	enemy_instance.set_enemy_mesh(chosen_mesh)
