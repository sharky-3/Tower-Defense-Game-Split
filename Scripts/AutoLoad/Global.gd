""" [[ ============================================================ ]] """
extends Node
""" [[ ============================================================ ]] """

""" [[ Stats ]] """
var tower_name: String = "Basic"
var IS_DRAGGING_CARD: bool = false
var placing_meshes: Array[MeshInstance3D] = []

""" [[ Game Data ]] """
var GAME_DATA = {
	"PlayerStats": [
		{ "Name": "Gold", "Value": 0, "Parent": "leaderstats" },
		{ "Name": "Exp", "Value": 0, "Parent": "leaderstats" },
		{ "Name": "Lvl", "Value": 1, "Parent": "leaderstats" },
		
		{ "Name": "Games_Won", "Value": 0, "Parent": "Stats" },
		{ "Name": "Games_Lost", "Value": 0, "Parent": "Stats" },
		{ "Name": "Total_Games", "Value": 0, "Parent": "Stats" },
		{ "Name": "Win_Rate", "Value": 0, "Parent": "Stats" },
		{ "Name": "Win_Rate", "Value": 0, "Parent": "Stats" },

		{ "Name": "Highest_Wave_Reached", "Value": 0, "Parent": "Stats" },
		
		{ "Name": "Waves_Played", "Value": 0, "Parent": "Stats" },
		{ "Name": "Enemies_Killed", "Value": 0, "Parent": "Stats" },
		{ "Name": "Enimies_Spawned", "Value": 0, "Parent": "Stats" },

		{ "Name": "Total_Damage_Taken", "Value": 0, "Parent": "Stats" },
		{ "Name": "Total_Damage_Dealed", "Value": 0, "Parent": "Stats" },
		{ "Name": "Total_Towers_Placed", "Value": 0, "Parent": "Stats" }
	],
	
	"GameStats": [
		{ "Progression": { "MaxLvl": 15, "ExpToNextLvl": 50 } },
		{ "Difficulty": { "WaveMultiplier": 1.2, "EnemySpawnRate": 1.5 } },
		{ "Bonuses": { "DamageMultiplier": 1.0, "RangeMultiplier": 1.0, "AttackSpeedMultiplier": 1.0 } }
	],
	
	"Towers": [
		{ "Basic": { "Mesh": "uid://cvq5oa37c1bkt", "Cost": 100, "Stats": { "Range": 15, "Damage": 10, "AttackSpeed": 1.0, "CanHitMultipleEnemies": false }, 
			 "Upgrades": [
				{ "Upgrade_1": { "Mesh": "uid://cvq5oa37c1bkt", "Cost": 150, "Stats": { "Range": 26, "Damage": 10 } } },
				{ "Upgrade_2": { "Mesh": "uid://cvq5oa37c1bkt", "Cost": 200, "Stats": { "Range": 32, "Damage": 6 } } }
			],
			"Description": "Starter tower."
		} },

		{ "Turret": { "Mesh": "uid://c4lillreyucf4", "Cost": 150, "Stats": { "Range": 18, "Damage": 10, "AttackSpeed": 0.8, "CanHitMultipleEnemies": true }, 
			"Upgrades": [
				{ "Upgrade_1": { "Mesh": "uid://c4lillreyucf4", "Cost": 200, "Stats": { "Range": 20, "Damage": 6 } } },
				{ "Upgrade_2": { "Mesh": "uid://c4lillreyucf4", "Cost": 250, "Stats": { "Range": 30, "Damage": 8 } } }
			],
			"Description": "Hits multiple enemies."
		} },

		{ "Cannon": { "Mesh": "uid://c4lillreyucf4", "Cost": 200, "Stats": { "Range": 20, "Damage": 25, "AttackSpeed": 2.5, "CanHitMultipleEnemies": false }, 
			"Upgrades": [
				{ "Upgrade_1": { "Mesh": "uid://c4lillreyucf4", "Cost": 250, "Stats": { "Range": 30, "Damage": 8 } } },
				{ "Upgrade_2": { "Mesh": "uid://c4lillreyucf4", "Cost": 300, "Stats": { "Range": 42, "Damage": 10 } } }
			],
			"Description": "Slow but powerful."
		} }
	],
	
	"Enemy": [
		{ "Goblins": [
			{ "Normal": [
				{ "Scrapper Goblin": { "Mesh": "uid://bnc5o7d66ecl2", "Stats": { "Scale": 3, "Speed": 1.0, "Health": 5, "Attack_Damage": 6, "Rewards": { "Gold": 3, "Exp": 2 } } } },
				{ "Iron Goblin": { "Mesh": "uid://ujvqmayejrnf", "Stats": { "Scale": 3, "Speed": 1.1, "Health": 5, "Attack_Damage": 7, "Rewards": { "Gold": 4, "Exp": 3 } } } },
				{ "Ironclad Goblin": { "Mesh": "uid://nigrfyigt3f", "Stats": { "Scale": 3, "Speed": 1.2, "Health": 5, "Attack_Damage": 8, "Rewards": { "Gold": 5, "Exp": 4 } } } },
				{ "Armored Juggernaut": { "Mesh": "uid://b5ik3k6qomfg1", "Stats": { "Scale": 3, "Speed": 1.3, "Health": 5, "Attack_Damage": 9, "Rewards": { "Gold": 6, "Exp": 5 } } } }
			] },
			
			{ "Giants": [
				{ "Scrapper Goblin": { "Mesh": "uid://bnc5o7d66ecl2", "Stats": { "Scale": 4, "Speed": 2.3, "Health": 24, "Attack_Damage": 24, "Rewards": { "Gold": 3, "Exp": 2 } } } },
				{ "Iron Goblin": { "Mesh": "uid://ujvqmayejrnf", "Stats": { "Scale": 4, "Speed": 2.4, "Health": 28, "Attack_Damage": 28, "Rewards": { "Gold": 4, "Exp": 3 } } } },
				{ "Ironclad Goblin": { "Mesh": "uid://nigrfyigt3f", "Stats": { "Scale": 4, "Speed": 2.5, "Health": 32, "Attack_Damage": 32, "Rewards": { "Gold": 5, "Exp": 4 } } } },
				{ "Armored Juggernaut": { "Mesh": "uid://b5ik3k6qomfg1", "Stats": { "Scale": 4, "Speed": 2.6, "Health": 36, "Attack_Damage": 36, "Rewards": { "Gold": 6, "Exp": 5 } } } }
			] }
		] },

		{ "Skeletons": [
			{  "Normal": [
				{ "Bone Grunt": { "Mesh": "uid://buvy0pwnlka7o", "Stats": { "Scale": 2, "Speed": 0.9, "Health": 5, "Attack_Damage": 5, "Rewards": { "Gold": 3, "Exp": 2 } } } },
				{ "Bone Guard": { "Mesh": "uid://dlie226iuvyhf", "Stats": { "Scale": 2, "Speed": 1.0, "Health": 6, "Attack_Damage": 6, "Rewards": { "Gold": 4, "Exp": 3 } } } },
				{ "Bone Warden": { "Mesh": "uid://dck10wdwme0i3", "Stats": { "Scale": 2, "Speed": 1.1, "Health": 7, "Attack_Damage": 7, "Rewards": { "Gold": 5, "Exp": 4 } } } }
			] },
			
			{ "Giants": [
				{ "Bone Grunt": { "Mesh": "uid://buvy0pwnlka7o", "Stats": { "Scale": 3, "Speed": 2.0, "Health": 15, "Attack_Damage": 15, "Rewards": { "Gold": 10, "Exp": 8 } } } },
				{ "Bone Guard": { "Mesh": "uid://dlie226iuvyhf", "Stats": { "Scale": 3, "Speed": 2.1, "Health": 18, "Attack_Damage": 18, "Rewards": { "Gold": 12, "Exp": 10 } } } },
				{ "Bone Warden": { "Mesh": "uid://dck10wdwme0i3", "Stats": { "Scale": 3, "Speed": 2.2, "Health": 21, "Attack_Damage": 21, "Rewards": { "Gold": 14, "Exp": 12 } } } }
			] }
		] }
	]
}

""" [[ ============================================================
	// FUNCTIONS
]] """

""" [[ ============================================================ ]] """
""" [[ Update Player Stats ]] """
func update_player_game_stats(stat_name: String, value: float) -> void:
	var stats = GAME_DATA["PlayerStats"]
	for item in stats:
		if item.get("Name", "") == stat_name:
			item["Value"] += value
			return

""" [[ Get Looking Value ]] """
func get_looking_value(stat_name: String) -> float:
	var stats = GAME_DATA["PlayerStats"]
	for item in stats:
		if item.get("Name", "") == stat_name:
			return item["Value"]
	return 0.0

""" [[ ============================================================ ]] """
""" [[ Get Towers ]] """
func get_towers_stats():
	var towers = GAME_DATA["Towers"]
	return towers

""" [[ Set Tower Name ]] """
func set_new_tower_name(new_name: String) -> void:
	tower_name = new_name

""" [[ Get Base Tower Mesh ]] """
func get_base_mesh(_name: String) -> PackedScene:
	var towers = GAME_DATA["Towers"]
	for t in towers:
		if t.has(_name):
			return load(t[_name]["Mesh"])
	return null

""" [[ Get Base Tower Stats ]] """
func get_tower_base_stats(_name: String) -> Dictionary:
	var towers = GAME_DATA["Towers"]
	for t in towers:
		if t.has(_name):
			return t[_name]["Stats"]
	return {}

""" [[ ============================================================ ]] """
""" [[ Get All Enemies ]] """
func get_enemies_type_array() -> Array:
	return GAME_DATA["Enemy"]
	
""" [[ Normalize Enemy ]] """
func normalize_enemy_stats(stats: Dictionary) -> Dictionary:
	return {
		"speed": stats.get("Speed", 1.0),
		"health": stats.get("Health", 5.0),
		"attack_damage": stats.get("Attack_Damage", 1.0),
		"scale": stats.get("Scale", 1.0),
	}

""" [[ Get Base Enemy ]] """
func get_base_enemy(enemy_type: String, enemy_size: String, enemy_name: String) -> Dictionary:
	var enemies = GAME_DATA["Enemy"]
	for e in enemies:
		if e.has(enemy_type):
			for size_group in e[enemy_type]:
				if size_group.has(enemy_size):
					for enemy in size_group[enemy_size]:
						if enemy.has(enemy_name):
							return enemy[enemy_name]
	return {}

""" [[ Get Enemy Stats ]] """
func get_enemy_stats(enemy_type: String, enemy_size: String, enemy_name: String) -> Dictionary:
	var base = get_base_enemy(enemy_type, enemy_size, enemy_name)
	return base.get("Stats", {})

""" [[ Get Enemy Rewards ]] """
func get_enemy_reward(enemy_type: String, enemy_size: String, enemy_name: String) -> Dictionary:
	var stats = get_base_enemy(enemy_type, enemy_size, enemy_name)
	return stats.get("Stats", {}).get("Rewards", {})

""" [[ ============================================================ ]] """
""" [[ Placing Grid Positions ]] """
func cache_placing_positions(placing_position: Node3D):
	for child in placing_position.get_children():
		if child is StaticBody3D and child.is_in_group("PlacingGrid"):
			var mesh: MeshInstance3D = child.get_node_or_null("MeshInstance3D")
			if mesh: placing_meshes.append(mesh)
