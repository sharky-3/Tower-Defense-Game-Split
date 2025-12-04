extends Node

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

# --- Get base mesh for placement ---
func get_base_mesh(tower_name: String) -> PackedScene:
	if not tower_stats.has(tower_name): 
		return null
	return tower_stats[tower_name]["mesh"]

# --- Get tower stats ---
func get_tower_base_stats(tower_name: String):
	if not tower_stats.has(tower_name): 
		return {}
	return tower_stats[tower_name]["stats"]

# --- Utility function to get upgrade data ---
func get_tower_upgrade(tower_name: String, level: int) -> Dictionary:
	if not tower_stats.has(tower_name): 
		return {}
	
	var upgrade = tower_stats[tower_name]["upgrades"]
	if level < 0 or level >= upgrade.size(): 
		return {}
	return upgrade[level]
