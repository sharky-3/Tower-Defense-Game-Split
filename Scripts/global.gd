extends Node

# --------------------------------------------------------------------
# Player
# --------------------------------------------------------------------

# --- Stats ---
var player_stats: Dictionary = {
	"currency": {
		"gold": 0,
		"gems": 0
	},

	"progression": {
		"exp": 0,
		"level": 1,
		"max_level": 15,
		"exp_to_next_level": 50
	},

	"bonuses": {
		"damage_multiplier": 1.0,
		"range_multiplier": 1.0,
		"attack_speed_multiplier": 1.0
	},

	"stats": {
		"game_won": 0,
		"game_lost": 0,
		"waves_played": 0,

		"enemies_killed": 0,
		"enemies_spawn": 0,
		"damage_taken": 0,
		"damage_deald": 0,
		
		"towers_built": 0,
		"towers_upgraded": 0,
	}
}

# --- Functions ---

func get_player_currency() -> Dictionary:
	return player_stats["currency"]

func get_player_progression() -> Dictionary:
	return player_stats["progression"]

func get_player_bonuses() -> Dictionary:
	return player_stats["bonuses"]

func get_player_stats() -> Dictionary:
	return player_stats["stats"]

func update_player_stats(stat_name: String, value: float):
	if not player_stats["stats"].has(stat_name): return

	var data = player_stats["stats"]
	data[stat_name] += value

# --------------------------------------------------------------------
# Tower
# --------------------------------------------------------------------

# --- Tower stats and upgrades ---
const tower_stats: Dictionary = {
	"basic_tower": {
		"mesh": preload("uid://cvq5oa37c1bkt"),
		"stats": { "range": 5, "damage": 3 },
		"upgrades": [
			{ "mesh": preload("uid://b6v01fbf56avq"), "range": 4, "damage": 3 },
			{ "mesh": preload("uid://u0rl2763vgxr"), "range": 5, "damage": 4 },
			{ "mesh": preload("uid://bvuqt0fd5kq1y"), "range": 7, "damage": 6 }
		]
	},
	"cannon_tower": {
		"mesh": preload("uid://cvq5oa37c1bkt"),
		"stats": { "range": 6, "damage": 10 },
		"upgrades": [
			{ "mesh": preload("uid://b6v01fbf56avq"), "range": 3, "damage": 5 },
			{ "mesh": preload("uid://u0rl2763vgxr"), "range": 5, "damage": 8 },
			{ "mesh": preload("uid://bvuqt0fd5kq1y"), "range": 6, "damage": 10 }
		]
	},
	"laser_tower": {
		"mesh": preload("uid://cvq5oa37c1bkt"),
		"stats": { "range": 8, "damage": 6 },
		"upgrades": [
			{ "mesh": preload("uid://b6v01fbf56avq"), "range": 4, "damage": 3 },
			{ "mesh": preload("uid://u0rl2763vgxr"), "range": 6, "damage": 5 },
			{ "mesh": preload("uid://bvuqt0fd5kq1y"), "range": 7, "damage": 6 }
		]
	},
	"slow_tower": {
		"mesh": preload("uid://cvq5oa37c1bkt"),
		"stats": { "range": 7, "damage": 3 },
		"upgrades": [
			{ "mesh": preload("uid://b6v01fbf56avq"), "range": 4, "damage": 2 },
			{ "mesh": preload("uid://u0rl2763vgxr"), "range": 5, "damage": 3 },
			{ "mesh": preload("uid://bvuqt0fd5kq1y"), "range": 7, "damage": 4 }
		]
	}
}

# --- Functions ---

func get_base_mesh(tower_name: String) -> PackedScene:
	if not tower_stats.has(tower_name): 
		return null
	return tower_stats[tower_name]["mesh"]

func get_tower_base_stats(tower_name: String):
	if not tower_stats.has(tower_name): 
		return {}
	return tower_stats[tower_name]["stats"]

func get_tower_upgrade(tower_name: String, level: int) -> Dictionary:
	if not tower_stats.has(tower_name): 
		return {}
	
	var upgrade = tower_stats[tower_name]["upgrades"]
	if level < 0 or level >= upgrade.size(): 
		return {}
	return upgrade[level]

# --------------------------------------------------------------------
# Enemies
# --------------------------------------------------------------------

const enemie_types: Dictionary = {
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

# --- Functions ---

func get_enemies_type_array() -> Dictionary:
	return enemie_types

func get_base_enemy(enemy_name: String, level: int) -> Dictionary:
	if not enemie_types.has(enemy_name) and (level < 0 or level >= enemie_types[enemy_name].size()):
		return {}
	return enemie_types[enemy_name][level]

func get_enemy_stats(enemy_name: String, level: int) -> Dictionary:
	if not enemie_types.has(enemy_name) and (level < 0 or level >= enemie_types[enemy_name].size()):
		return {}
	return enemie_types[enemy_name][level]["stats"]

func get_enemy_reward(enemy_name: String, level: int) -> Dictionary:
	if not enemie_types.has(enemy_name) and (level < 0 or level >= enemie_types[enemy_name].size()):
		return {}
	return enemie_types[enemy_name][level]["rewards"]

# --------------------------------------------------------------------
# Terrain
# --------------------------------------------------------------------

# --- Data ---
var terrain_heights: Dictionary = {}  

# --- Functions ---
func set_terrain_coordinates(x: int, z: int, y: float) -> void:
	var key = "%d_%d" % [x, z]
	terrain_heights[key] = y

func get_terrain_height_at_hex(x: int, z: int) -> float:
	var key = "%d_%d" % [x, z]
	return terrain_heights.get(key, 0.0)
