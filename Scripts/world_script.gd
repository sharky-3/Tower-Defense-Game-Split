extends Node3D

# --- Resources ---
const Enemy = preload("res://Scenes/Characters/enemy_character.tscn")
const enemie_types := {
	"goblins": {
		1: {
			"mesh": preload("uid://bfygdhktxcdvx"),
			"stats": {"speed": 1.0, "health": 4, "attack_damage": 6},
			"rewards": {"gold": 3, "exp": 2}
		},
		2: {
			"mesh": preload("uid://dgan33wtxphvc"),
			"stats": {"speed": 1.1, "health": 5, "attack_damage": 7},
			"rewards": {"gold": 4, "exp": 3}
		},
		3: {
			"mesh": preload("uid://bw7tyjpxy3ku8"),
			"stats": {"speed": 1.2, "health": 6, "attack_damage": 8},
			"rewards": {"gold": 5, "exp": 4}
		},
		4: {
			"mesh": preload("uid://dnih7xrttht20"),
			"stats": {"speed": 1.3, "health": 7, "attack_damage": 9},
			"rewards": {"gold": 6, "exp": 5}
		}
	},
	"skeletons": {
		1: {
			"mesh": preload("uid://ddj4r3bygamt8"),
			"stats": {"speed": 0.9, "health": 5, "attack_damage": 5},
			"rewards": {"gold": 3, "exp": 2}
		},
		2: {
			"mesh": preload("uid://u23q3r8bpqan"),
			"stats": {"speed": 1.0, "health": 6, "attack_damage": 6},
			"rewards": {"gold": 4, "exp": 3}
		},
		3: {
			"mesh": preload("uid://conmtsecxcsp8"),
			"stats": {"speed": 1.1, "health": 7, "attack_damage": 7},
			"rewards": {"gold": 5, "exp": 4}
		}
	}
}

# --- Constants / Exported Data ---
@export var total_waves: int = 5
@export var enemies_per_wave: Array[int] = [2, 2, 2, 2, 2]
@export var time_between_waves: float = 15.0
@export var difficulty_per_wave: Array[float] = [1, 1.2, 1.5, 1.8, 2.0]
@export var spawn_radius: float = 10

# --- Node references ---
@onready var player_tower: Node3D = $Map/PlayerTower
@onready var spawn_enemy_position: Node3D = $Map/spawn_enemy_position

# --- Stats ---
var current_wave: int = 0
var waiting_for_next_wave: bool = false
var wave_cooldown_timer: float = 0.0

# --------------------------------------------------------------------
# Life Cycle
# --------------------------------------------------------------------

func _ready() -> void:
	_wave_system()

func _process(_delta) -> void:
	pass

# --------------------------------------------------------------------
# Round System
# --------------------------------------------------------------------

func _wave_system() -> void:
	for wave_index in range(total_waves):
		var enemy_count = enemies_per_wave[wave_index]
		var difficulty = difficulty_per_wave[wave_index] if wave_index < difficulty_per_wave.size() else 1.0

		for i in range(enemy_count):
			_spawn_enemy(difficulty)
			await get_tree().create_timer(0.1).timeout  

		await get_tree().create_timer(time_between_waves).timeout

# --------------------------------------------------------------------
# Spawn Enemy 
# --------------------------------------------------------------------

func _get_random_spawn_offset() -> Vector3:
		var min_distance = 6.0
		var max_distance = spawn_radius
		var distance = randf_range(min_distance, max_distance)
		
		var angle = randf_range(0, TAU) 
		var random_offset = Vector3( 
			cos(angle) * distance, 0, sin(angle) * distance
		)
		return random_offset

func _spawn_enemy(difficulty: float) -> void:
	var enemy_instance = Enemy.instantiate()
	add_child(enemy_instance)
	enemy_instance.add_enemy_to_group()

	# Set position
	if is_instance_valid(spawn_enemy_position):
		enemy_instance.global_transform.origin = (
			spawn_enemy_position.global_transform.origin + _get_random_spawn_offset()
		)

	enemy_instance.set_difficulty(difficulty)

	var enemy_keys = enemie_types.keys()
	var chosen_type = enemy_keys[randi() % enemy_keys.size()]
	
	var type_levels = enemie_types[chosen_type].keys()
	var chosen_level = type_levels[randi() % type_levels.size()]
	
	var chosen_mesh_data = enemie_types[chosen_type][chosen_level]
	enemy_instance.set_enemy_mesh(chosen_mesh_data["mesh"])
