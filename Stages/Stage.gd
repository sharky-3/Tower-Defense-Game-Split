""" [[ ============================================================ ]] """
extends Node3D
""" [[ ============================================================ ]] """

""" [[ Resources ]] """
const Enemy = preload("uid://qpx5ico661eo")
const TOOL_TIP = preload("uid://xeyl6w62dtwx")

""" [[ Constants / Exported Data ]] """
@export var starting_enemies: int = 2
@export var enemy_multiplier: float = 1.25
@export var time_between_waves: float = 15.0
@export var max_distance: float = 10
@export var min_distance: float = 5.0

""" [[ Node references ]] """
@onready var player_tower: Node3D = $SubViewportContainer/SubViewport/Map/PlayerTower
@onready var spawn_enemy_position: Node3D = $SubViewportContainer/SubViewport/Map/spawn_enemy_position

@onready var subviewport: SubViewport = $SubViewportContainer/SubViewport
@onready var player_camera: Node3D = $SubViewportContainer/SubViewport/Player
@onready var camera: Camera3D = player_camera.find_child("Camera3D", true, false)

""" [[ Stats ]] """
var current_wave: int = 0
	
""" [[ ============================================================ ]] """
""" [[ LifeCycle ]] """

func _ready() -> void:
	start_wave_system()

""" [[ ============================================================ ]] """
""" [[ Functions ]] """

func get_node_height(node: Node3D) -> float:
	var mesh_instance = null
	
	for child in node.get_children():
		if child is MeshInstance3D:
			mesh_instance = child
			break
			
	if mesh_instance and mesh_instance.mesh:
		var aabb = mesh_instance.mesh.get_aabb()
		return aabb.size.y
	return 0.0

func start_wave_system() -> void:
	async_wave_loop()

func async_wave_loop() -> void:
	while true:
		current_wave += 1
		_update_player_game_stats("Waves_Played", 1)
		var enemy_count = int(starting_enemies * pow(enemy_multiplier, current_wave - 1))
		var difficulty = 1.0 + (current_wave * 0.15)
		
		print("Wave:", current_wave, "Enemies:", enemy_count)
		
		for i in range(enemy_count):
			_spawn_enemy(difficulty)
			await get_tree().create_timer(0.1).timeout
		await get_tree().create_timer(time_between_waves).timeout

func _get_random_spawn_offset() -> Vector3:
	var distance = randf_range(min_distance, max_distance)
	var angle = randf_range(0, TAU)
	return Vector3(cos(angle) * distance, 0, sin(angle) * distance)

func _spawn_enemy(difficulty: float) -> void:
	if not is_instance_valid(spawn_enemy_position): return

	var enemy_instance = Enemy.instantiate()
	add_child(enemy_instance)
	enemy_instance.set_group()

	var spawn_pos = spawn_enemy_position.global_position
	spawn_pos.y = 1
	enemy_instance.global_transform.origin = spawn_enemy_position.global_transform.origin + _get_random_spawn_offset()

	var enemies_array = Global.get_enemies_type_array()
	if enemies_array.size() == 0: return

	var type_index = randi() % enemies_array.size()
	var enemy_type_dict = enemies_array[type_index]
	var enemy_type_name = enemy_type_dict.keys()[0]

	var size_index = randi() % enemy_type_dict[enemy_type_name].size()
	var size_group = enemy_type_dict[enemy_type_name][size_index]
	var size_name = size_group.keys()[0]

	var enemy_list = size_group[size_name]
	var enemy_index = randi() % enemy_list.size()
	var enemy_data = enemy_list[enemy_index]
	var enemy_name = enemy_data.keys()[0]
	var chosen_enemy = enemy_data[enemy_name]

	if chosen_enemy.has("Mesh"):
		enemy_instance.set_character(load(chosen_enemy["Mesh"]))

	if chosen_enemy.has("Stats"):
		var normalized_stats = Global.normalize_enemy_stats(chosen_enemy["Stats"])
		enemy_instance.set_stats(normalized_stats)
		if chosen_enemy["Stats"].has("Rewards"):
			enemy_instance.set_rewards(chosen_enemy["Stats"]["Rewards"])

	enemy_instance.set_difficulty(difficulty)

	_update_player_game_stats("Enimies_Spawned", 1)

""" [[ ============================================================ ]] """
""" [[ Events ]] """

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.is_action("LEFT_MOUSE_CLICK"):
		var mouse_pos = subviewport.get_mouse_position()
		var ray_origin = camera.project_ray_origin(mouse_pos)
		var ray_dir = camera.project_ray_normal(mouse_pos)
		var world = camera.get_world_3d()
		
		if not camera or not world: return

		var query = PhysicsRayQueryParameters3D.create(
			ray_origin,
			ray_origin + ray_dir * 1000.0
		)

		var result = world.direct_space_state.intersect_ray(query); if not result: return
		var node: Node3D = result.collider
		var parent := node.get_parent().get_parent()
		if not parent.is_in_group("ToolTip"): return
		
		while node != null:
			if node.has_method("on_clicked"): 
				node.on_clicked()
				break

			var tooltip_node = node.get_node_or_null("ToolTip")
			if tooltip_node: 
				tooltip_node.queue_free()
				break

			else:
				var tooltip_instance: Node3D = TOOL_TIP.instantiate()
				var height: float = roundf(get_node_height(parent))
				
				tooltip_instance.position = Vector3(0, height * 0.8, 0)
				node.add_child(tooltip_instance)
				break
				
			node = node.get_parent()

""" [[ ============================================================ ]] """
""" [[ Globals ]] """

func _update_player_game_stats(stat_name: String, value: int):
	Global.update_player_game_stats(stat_name, value)
