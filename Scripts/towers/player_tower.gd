extends Node3D
@export var health := 100
@export var is_alive : bool = true

func take_damage(amount: int) -> void:
	health -= amount
	print("Tower took ", amount, " damage! Remaining health: ", health)
	if health <= 0:
		print("Tower destroyed!")
		is_alive = false
		#queue_free() 
