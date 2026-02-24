extends Node

# --------------------------------------------------------------------
# Game Data
# --------------------------------------------------------------------
var NORMAL_SIZE: float = 2.0
var GIAN_SIZE: float = 3.0

var GameData = {}
const GAME_DATA_FILE = "res://Scripts/Data/GameData.json"

func _ready() -> void:
	var file = FileAccess.open(GAME_DATA_FILE, FileAccess.READ)
	var json = JSON.parse_string(file.get_as_text())
	GameData = json
	
func game_data_search(target_name: String, data = GameData):
	if typeof(data) == TYPE_DICTIONARY:
		for key in data.keys():
			if key == target_name: return data[key]
			var result = game_data_search(target_name, data[key])
			if result != null: return result
	
	elif typeof(data) == TYPE_ARRAY:
		for item in data:
			var result = game_data_search(target_name, item)
			if result != null: return result
	
	return null

var game_data: Dictionary = {
	
	# --------------------------------------------------------------------
	# --- Player stats ---
	"player": {
		"currency": { 
			"gold": 1000 
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
			"game_won": 0, "game_lost": 0, "waves_played": 0,
			"enemies_killed": 0, "enemies_spawn": 0, "damage_taken": 0, "damage_deald": 0,
			"towers_built": 0
		}
	},
	
	# --------------------------------------------------------------------
	# --- Towers ---
	"towers": {
		# --- Basic tower
		"basic_tower": {
			"mesh": preload("uid://cvq5oa37c1bkt"),
			"stats": { "range": 5, "damage": 3 },
		},

		# --- Turret tower
		"turret_tower": {
			"mesh": preload("uid://c4lillreyucf4"),
			"stats": { "range": 6, "damage": 10 },
		},

		# --- Cannon tower ---
		"cannon_tower": {
			"mesh": preload("uid://cvq5oa37c1bkt"),
			"stats": { "range": 8, "damage": 6 },
		},
		
		# --- Slow tower ---
		"slow_tower": {
			"mesh": preload("uid://cvq5oa37c1bkt"),
			"stats": { "range": 7, "damage": 3 },
		}
	},

	# --------------------------------------------------------------------
	# --- Enemies ---
	"enemies": {
		
		# --------------------------------------------------------------------
		# --- Normal Enemies ---
		
		# --- Goblins ---
		"goblins": {
			1: { "mesh": preload("uid://bnc5o7d66ecl2"), "stats": {"speed": 1.0, "health": 4, "attack_damage": 6, "scale": NORMAL_SIZE}, "rewards": {"gold": 3, "exp": 2} },
			2: { "mesh": preload("uid://ujvqmayejrnf"), "stats": {"speed": 1.1, "health": 5, "attack_damage": 7, "scale": NORMAL_SIZE}, "rewards": {"gold": 4, "exp": 3} },
			3: { "mesh": preload("uid://nigrfyigt3f"), "stats": {"speed": 1.2, "health": 6, "attack_damage": 8, "scale": NORMAL_SIZE}, "rewards": {"gold": 5, "exp": 4} },
			4: { "mesh": preload("uid://b5ik3k6qomfg1"), "stats": {"speed": 1.3, "health": 7, "attack_damage": 9, "scale": NORMAL_SIZE}, "rewards": {"gold": 6, "exp": 5} }
		},
		
		# --- Skeleton ---
		"skeletons": {
			1: { "mesh": preload("uid://buvy0pwnlka7o"), "stats": {"speed": 0.9, "health": 5, "attack_damage": 5, "scale": NORMAL_SIZE}, "rewards": {"gold": 3, "exp": 2} },
			2: { "mesh": preload("uid://dlie226iuvyhf"), "stats": {"speed": 1.0, "health": 6, "attack_damage": 6, "scale": NORMAL_SIZE}, "rewards": {"gold": 4, "exp": 3} },
			3: { "mesh": preload("uid://dck10wdwme0i3"), "stats": {"speed": 1.1, "health": 7, "attack_damage": 7, "scale": NORMAL_SIZE}, "rewards": {"gold": 5, "exp": 4} }
		},
		
		# --------------------------------------------------------------------
		# --- Giants ---
		"giants": {
			
			# --- Skeleton ---
			1: { "mesh": preload("uid://buvy0pwnlka7o"), "stats": {"speed": 2.0, "health": 15, "attack_damage": 15, "scale": GIAN_SIZE}, "rewards": {"gold": 10, "exp": 8} },
			2: { "mesh": preload("uid://dlie226iuvyhf"), "stats": {"speed": 2.1, "health": 18, "attack_damage": 18, "scale": GIAN_SIZE}, "rewards": {"gold": 12, "exp": 10} },
			3: { "mesh": preload("uid://dck10wdwme0i3"), "stats": {"speed": 2.2, "health": 21, "attack_damage": 21, "scale": GIAN_SIZE}, "rewards": {"gold": 14, "exp": 12} },
			
			# --- Goblins ----
			4: { "mesh": preload("uid://bnc5o7d66ecl2"), "stats": {"speed": 2.3, "health": 24, "attack_damage": 24, "scale": GIAN_SIZE}, "rewards": {"gold": 16, "exp": 14} },
			5: { "mesh": preload("uid://ujvqmayejrnf"), "stats": {"speed": 2.4, "health": 28, "attack_damage": 28, "scale": GIAN_SIZE}, "rewards": {"gold": 18, "exp": 16} },
			6: { "mesh": preload("uid://nigrfyigt3f"), "stats": {"speed": 2.5, "health": 32, "attack_damage": 32, "scale": GIAN_SIZE}, "rewards": {"gold": 20, "exp": 18} },
			7: { "mesh": preload("uid://b5ik3k6qomfg1"), "stats": {"speed": 2.6, "health": 36, "attack_damage": 36, "scale": GIAN_SIZE}, "rewards": {"gold": 24, "exp": 22} }
		}
	},
}

""" [[ ============================================================
	// FUNCTIONS
]] """

""" [[ ============================================================ ]] """
""" [[ Update Player Stats ]] """
func update_player_game_stats(directory_name: String, stat_name: String, value: float):
	if not game_data["player"].has(directory_name) or not game_data["player"][directory_name].has(stat_name):
		return
	game_data["player"][directory_name][stat_name] += value

""" [[ Get Looking Value ]] """
func get_looking_value(directory_name: String, stat_name: String):
	if not game_data["player"].has(directory_name) or not game_data["player"][directory_name].has(stat_name):
		return null
	return game_data["player"][directory_name][stat_name]

""" [[ ============================================================ ]] """
""" [[ Enemies ]] """
var tower_name = "basic_tower"

func set_new_tower_name(new_name: String):
	tower_name = new_name
	
func get_base_mesh(_name: String) -> PackedScene:
	if not game_data["towers"].has(_name): 
		return null
	return game_data["towers"][_name]["mesh"]

func get_tower_base_stats(_name: String):
	if not game_data["towers"].has(_name): 
		return {}
	return game_data["towers"][_name]["stats"]
 
""" [[ ============================================================
	// ENTITIES
]] """

""" [[ ============================================================ ]] """
""" [[ Enemies ]] """
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
