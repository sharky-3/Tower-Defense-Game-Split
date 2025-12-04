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
	print("damage", amount)
	_attampt_damage(amount)
		
func _attampt_damage(damage: float) -> void:
	var health: float = tower_healt - damage
	print("Tower health:", health)
	if _tower_health(health):
		print("Tower is destroyed")
		player_tower.queue_free()
	
func _tower_health(health: float):
	if health <= 0: return true
	return false
