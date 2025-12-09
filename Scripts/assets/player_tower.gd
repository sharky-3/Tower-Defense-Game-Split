extends Node3D

# --- Constants / Exported Data ---
@export_category("Main")
@export var tower_healt: float
@export var max_health: float

@export_category("Visual/Audio")
@export var damage_effect: bool
@export var death_effect: bool
@export var hit_sound: AudioStream
@export var death_sound: AudioStream

# --- Node references ---
@onready var player_tower: Node3D = $"."

# --------------------------------------------------------------------
# Take Damage
# --------------------------------------------------------------------

func take_attack_damage(amount: float) -> void:
	_attampt_damage(amount)
		
func _attampt_damage(damage: float) -> void:
	tower_healt -= damage
	if _tower_health(tower_healt):
		player_tower.queue_free()
	_update_player_game_stats("damage_taken", damage)
	
func _tower_health(health: float):
	if health <= 0: return true
	return false

func is_tower_dead() -> bool:
	return _tower_health(tower_healt)

# --------------------------------------------------------------------
# Global Player Stats
# --------------------------------------------------------------------

func _update_player_game_stats(stat_name: String, value: float):
	Global.update_player_game_stats("stats", stat_name, value)
