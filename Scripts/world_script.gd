extends Node3D

# --- Resources ---
const Enemy = preload("res://Scenes/Characters/enemy_character.tscn")

# --- Constants / Exported Data ---
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
	for wave_index in range(enemies_per_wave.size()):
		_update_player_stats("waves_played", +1)

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

	var enemy_types_array = Global.get_enemies_type_array()
	
	var enemy_keys = enemy_types_array.keys()
	var chosen_type = enemy_keys[randi() % enemy_keys.size()]
	var type_levels = enemy_types_array[chosen_type].keys()
	var chosen_level = type_levels[randi() % type_levels.size()]

	var enemy_mesh = Global.get_base_enemy(chosen_type, chosen_level)
	enemy_instance.set_enemy_mesh(enemy_mesh["mesh"])
	enemy_instance.set_enemy_stats(enemy_mesh["stats"])
	enemy_instance.set_enemy_rewards(enemy_mesh["rewards"])

	_update_player_stats("enemies_spawn", +1)

# --------------------------------------------------------------------
# Global Player Stats
# --------------------------------------------------------------------

func _update_player_stats(stat_name: String, value: int):
	Global.update_player_stats(stat_name, value)
