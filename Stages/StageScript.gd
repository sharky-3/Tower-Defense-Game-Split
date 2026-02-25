extends Node3D

# --- Resources ---
const Enemy = preload("uid://qpx5ico661eo")

# --- Constants / Exported Data ---
@export var enemies_per_wave: Array[int] = [2, 2, 2, 2, 2]
@export var time_between_waves: float = 15.0
@export var difficulty_per_wave: Array[float] = [1, 1.2, 1.5, 1.8, 2.0]
@export var max_distance: float = 10
@export var min_distance: float = 5.0

# --- Node references ---
@onready var player_tower: Node3D = $SubViewportContainer/SubViewport/Map/PlayerTower
@onready var spawn_enemy_position: Node3D = $SubViewportContainer/SubViewport/Map/spawn_enemy_position

# --- Stats ---
var current_wave: int = 0

# --------------------------------------------------------------------
# Life Cycle
# --------------------------------------------------------------------

func _ready() -> void:
	start_wave_system()

func start_wave_system() -> void:
	async_wave_loop()

# --------------------------------------------------------------------
# Wave Loop
# --------------------------------------------------------------------

func async_wave_loop() -> void:
	while true:
		for wave_index in range(enemies_per_wave.size()):
			current_wave = wave_index + 1
			_update_player_game_stats("Waves_Played", 1)

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
	var distance = randf_range(min_distance, max_distance)
	var angle = randf_range(0, TAU)
	return Vector3(cos(angle) * distance, 0, sin(angle) * distance)

func _spawn_enemy(difficulty: float) -> void:
	if not is_instance_valid(spawn_enemy_position):
		return

	var enemy_instance = Enemy.instantiate()
	add_child(enemy_instance)
	enemy_instance.add_enemy_to_group()

	# Position
	var spawn_pos = spawn_enemy_position.global_position
	spawn_pos.y = 1
	enemy_instance.global_transform.origin = spawn_enemy_position.global_transform.origin + _get_random_spawn_offset()

	# --- Random enemy selection ---
	var enemies_array = Global.get_enemies_type_array()
	if enemies_array.size() == 0:
		return

	var type_index = randi() % enemies_array.size()
	var enemy_type_dict = enemies_array[type_index]
	var enemy_type_name = enemy_type_dict.keys()[0]

	# Random size group: Normal / Giants
	var size_index = randi() % enemy_type_dict[enemy_type_name].size()
	var size_group = enemy_type_dict[enemy_type_name][size_index]
	var size_name = size_group.keys()[0]

	# Random enemy from list
	var enemy_list = size_group[size_name]
	var enemy_index = randi() % enemy_list.size()
	var enemy_data = enemy_list[enemy_index]
	var enemy_name = enemy_data.keys()[0]
	var chosen_enemy = enemy_data[enemy_name]

	# Set mesh
	if chosen_enemy.has("Mesh"):
		enemy_instance.set_enemy_mesh(load(chosen_enemy["Mesh"]))

	# Set stats
	if chosen_enemy.has("Stats"):
		var normalized_stats = Global.normalize_enemy_stats(chosen_enemy["Stats"])
		enemy_instance.set_enemy_stats(normalized_stats)
		if chosen_enemy["Stats"].has("Rewards"):
			enemy_instance.set_enemy_rewards(chosen_enemy["Stats"]["Rewards"])

	enemy_instance.set_difficulty(difficulty)

	_update_player_game_stats("Enimies_Spawned", 1)

# --------------------------------------------------------------------
# Global Player Stats
# --------------------------------------------------------------------

func _update_player_game_stats(stat_name: String, value: int):
	Global.update_player_game_stats(stat_name, value)
