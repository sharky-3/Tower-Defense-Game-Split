extends Node

# --------------------------------------------------------------------
# Game Data
# --------------------------------------------------------------------

var game_data: Dictionary = {
	"player": {
		"currency": { "gold": 100 },
		"progression": { "exp": 0, "level": 1, "max_level": 15, "exp_to_next_level": 50 },
		"bonuses": { "damage_multiplier": 1.0, "range_multiplier": 1.0, "attack_speed_multiplier": 1.0 },
		"stats": {
			"game_won": 0, "game_lost": 0, "waves_played": 0,
			"enemies_killed": 0, "enemies_spawn": 0, "damage_taken": 0, "damage_deald": 0,
			"towers_built": 0, "towers_upgraded": 0
		}
	},

	"towers": {
		"basic_tower": {
			"mesh": preload("uid://cvq5oa37c1bkt"),
			"stats": { "range": 5, "damage": 3 },

			"upgrades": [
				{ "mesh": preload("uid://b6v01fbf56avq"), "range": 4, "damage": 3, "price": 50 },  
				{ "mesh": preload("uid://u0rl2763vgxr"), "range": 5, "damage": 4, "price": 60 },
				{ "mesh": preload("uid://bvuqt0fd5kq1y"), "range": 7, "damage": 6, "price": 90 }
			]
		},

			"cannon_tower": {
			"mesh": preload("uid://cvq5oa37c1bkt"),
			"stats": { "range": 6, "damage": 10 },

			"upgrades": [
				{ "mesh": preload("uid://b6v01fbf56avq"), "range": 3, "damage": 5, "price": 100 }, 
				{ "mesh": preload("uid://u0rl2763vgxr"), "range": 5, "damage": 8, "price": 110 },
				{ "mesh": preload("uid://bvuqt0fd5kq1y"), "range": 6, "damage": 10, "price": 150 }
			]
		},

		"laser_tower": {
			"mesh": preload("uid://cvq5oa37c1bkt"),
			"stats": { "range": 8, "damage": 6 },

			"upgrades": [
				{ "mesh": preload("uid://b6v01fbf56avq"), "range": 4, "damage": 3, "price": 120 },  
				{ "mesh": preload("uid://u0rl2763vgxr"), "range": 6, "damage": 5, "price": 100 },
				{ "mesh": preload("uid://bvuqt0fd5kq1y"), "range": 7, "damage": 6, "price": 140 }
			]
		},

		"slow_tower": {
			"mesh": preload("uid://cvq5oa37c1bkt"),
			"stats": { "range": 7, "damage": 3 },

			"upgrades": [
				{ "mesh": preload("uid://b6v01fbf56avq"), "range": 4, "damage": 2, "price": 80 }, 
				{ "mesh": preload("uid://u0rl2763vgxr"), "range": 5, "damage": 3, "price": 70 },
				{ "mesh": preload("uid://bvuqt0fd5kq1y"), "range": 7, "damage": 4, "price": 100 }
			]
		}
	},

	"enemies": {
		"goblins": {
			1: { "mesh": preload("uid://bfygdhktxcdvx"), "stats": {"speed": 1.0, "health": 4, "attack_damage": 6, "scale": 0.4}, "rewards": {"gold": 3, "exp": 2} },
			2: { "mesh": preload("uid://dgan33wtxphvc"), "stats": {"speed": 1.1, "health": 5, "attack_damage": 7, "scale": 0.4}, "rewards": {"gold": 4, "exp": 3} },
			3: { "mesh": preload("uid://bw7tyjpxy3ku8"), "stats": {"speed": 1.2, "health": 6, "attack_damage": 8, "scale": 0.4}, "rewards": {"gold": 5, "exp": 4} },
			4: { "mesh": preload("uid://dnih7xrttht20"), "stats": {"speed": 1.3, "health": 7, "attack_damage": 9, "scale": 0.4}, "rewards": {"gold": 6, "exp": 5} }
		},
		"skeletons": {
			1: { "mesh": preload("uid://ddj4r3bygamt8"), "stats": {"speed": 0.9, "health": 5, "attack_damage": 5, "scale": 0.4}, "rewards": {"gold": 3, "exp": 2} },
			2: { "mesh": preload("uid://u23q3r8bpqan"), "stats": {"speed": 1.0, "health": 6, "attack_damage": 6, "scale": 0.4}, "rewards": {"gold": 4, "exp": 3} },
			3: { "mesh": preload("uid://conmtsecxcsp8"), "stats": {"speed": 1.1, "health": 7, "attack_damage": 7, "scale": 0.4}, "rewards": {"gold": 5, "exp": 4} }
		},
		"giants": {
			
			# --- Skeleton ---
			1: { "mesh": preload("uid://ddj4r3bygamt8"), "stats": {"speed": 1.0, "health": 15, "attack_damage": 15, "scale": 0.7}, "rewards": {"gold": 10, "exp": 8} },
			2: { "mesh": preload("uid://u23q3r8bpqan"), "stats": {"speed": 1.1, "health": 18, "attack_damage": 18, "scale": 0.7}, "rewards": {"gold": 12, "exp": 10} },
			3: { "mesh": preload("uid://conmtsecxcsp8"), "stats": {"speed": 1.2, "health": 21, "attack_damage": 21, "scale": 0.7}, "rewards": {"gold": 14, "exp": 12} },
			
			# --- Goblins ----
			4: { "mesh": preload("uid://bfygdhktxcdvx"), "stats": {"speed": 1.3, "health": 24, "attack_damage": 24, "scale": 0.7}, "rewards": {"gold": 16, "exp": 14} },
			5: { "mesh": preload("uid://dgan33wtxphvc"), "stats": {"speed": 1.4, "health": 28, "attack_damage": 28, "scale": 0.7}, "rewards": {"gold": 18, "exp": 16} },
			6: { "mesh": preload("uid://bw7tyjpxy3ku8"), "stats": {"speed": 1.5, "health": 32, "attack_damage": 32, "scale": 0.7}, "rewards": {"gold": 20, "exp": 18} },
			7: { "mesh": preload("uid://dnih7xrttht20"), "stats": {"speed": 1.6, "health": 36, "attack_damage": 36, "scale": 0.7}, "rewards": {"gold": 24, "exp": 22} }
		}

	},

	"terrain": {
		"tile_map": {},  
		"terrain_heights": {}  
	}
}

# --------------------------------------------------------------------
# Player Functions
# --------------------------------------------------------------------

func update_player_game_stats(directory_name: String, stat_name: String, value: float):
	if not game_data["player"].has(directory_name) or not game_data["player"][directory_name].has(stat_name):
		return
	game_data["player"][directory_name][stat_name] += value

func get_looking_value(directory_name: String, stat_name: String):
	if not game_data["player"].has(directory_name) or not game_data["player"][directory_name].has(stat_name):
		return null
	return game_data["player"][directory_name][stat_name]

# --------------------------------------------------------------------
# Tower Functions
# --------------------------------------------------------------------

func get_base_mesh(tower_name: String) -> PackedScene:
	if not game_data["towers"].has(tower_name): 
		return null
	return game_data["towers"][tower_name]["mesh"]

func get_tower_base_stats(tower_name: String):
	if not game_data["towers"].has(tower_name): 
		return {}
	return game_data["towers"][tower_name]["stats"]

func get_tower_upgrade(tower_name: String, level: int) -> Dictionary:
	if not game_data["towers"].has(tower_name): 
		return {}
	var upgrades = game_data["towers"][tower_name]["upgrades"]
	if level < 0 or level >= upgrades.size(): 
		return {}
	return upgrades[level]

# --------------------------------------------------------------------
# Enemy Functions
# --------------------------------------------------------------------

func get_enemies_type_array() -> Dictionary:
	return game_data["enemies"]

func get_base_enemy(enemy_name: String, level: int) -> Dictionary:
	if not game_data["enemies"].has(enemy_name) or not game_data["enemies"][enemy_name].has(level):
		return {}
	return game_data["enemies"][enemy_name][level]

func get_enemy_stats(enemy_name: String, level: int) -> Dictionary:
	if not game_data["enemies"].has(enemy_name) or not game_data["enemies"][enemy_name].has(level):
		return {}
	return game_data["enemies"][enemy_name][level]["stats"]

func get_enemy_reward(enemy_name: String, level: int) -> Dictionary:
	if not game_data["enemies"].has(enemy_name) or not game_data["enemies"][enemy_name].has(level):
		return {}
	return game_data["enemies"][enemy_name][level]["rewards"]

# --------------------------------------------------------------------
# Terrain Functions
# --------------------------------------------------------------------

func set_tile_node(x: int, z: int, tile: Node) -> void:
	var key = "%d_%d" % [x, z]
	game_data["terrain"]["tile_map"][key] = tile

func get_tile_node(x: int, z: int) -> Node:
	var key = "%d_%d" % [x, z]
	return game_data["terrain"]["tile_map"].get(key, null)

func set_tile_taken(x: int, z: int, taken: bool = true) -> void:
	var t = get_tile_node(x, z)
	if t:
		t.set_meta("is_taken", taken)

func is_tile_taken(x: int, z: int) -> bool:
	var t = get_tile_node(x, z)
	if t:
		return bool(t.get_meta("is_taken", false))
	return false

func get_tile_type(x: int, z: int) -> String:
	var t = get_tile_node(x, z)
	if t:
		return str(t.get_meta("tile_type", ""))
	return ""

func is_tile_center(x: int, z: int) -> bool:
	var t = get_tile_node(x, z)
	if t:
		return bool(t.get_meta("is_center", false))
	return false

func set_terrain_coordinates(x: int, z: int, y: float) -> void:
	var key = "%d_%d" % [x, z]
	game_data["terrain"]["terrain_heights"][key] = y

func get_terrain_height_at_hex(x: int, z: int) -> float:
	var key = "%d_%d" % [x, z]
	return game_data["terrain"]["terrain_heights"].get(key, 0.0)

# --------------------------------------------------------------------
# Animation Functions
# --------------------------------------------------------------------

func play_upgrade_animation(tower_body_mesh: MeshInstance3D, new_mesh: Mesh) -> void:
	var original_scale = tower_body_mesh.scale
	tower_body_mesh.scale = original_scale * 0.7
	tower_body_mesh.mesh = new_mesh
	var tween = create_tween()
	tween.tween_property(tower_body_mesh, "scale", original_scale, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_callback(Callable(self, "_on_upgrade_animation_complete"))

func play_placing_animation(tower_body_mesh: MeshInstance3D) -> void:
	var original_scale = tower_body_mesh.scale
	tower_body_mesh.scale = original_scale * 0.7
	var tween = create_tween()
	tween.tween_property(tower_body_mesh, "scale", original_scale, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_callback(Callable(self, "_on_placing_animation_complete"))
	
# --------------------------------------------------------------------
# User Interface
# --------------------------------------------------------------------

func open_tower_upgrade_ui(tower_name: String):
	pass
