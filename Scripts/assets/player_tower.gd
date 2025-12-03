extends Node3D

@export_category("Main")
@export var health: float
@export var max_health: float
@export var is_alive: bool = true

@export_category("Visual/Audio")
@export var damage_effect: bool
@export var death_effect: bool
@export var hit_sound: AudioStream
@export var death_sound: AudioStream

func take_attack_damage(amount: int) -> void:
	health -= amount
	print("Tower took ", amount, " damage! Remaining health: ", health)
	if health <= 0:
		print("Tower destroyed!")
		is_alive = false
		#queue_free() 

func is_enemy(): return false
