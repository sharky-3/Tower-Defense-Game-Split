""" [[ ============================================================ ]] """
extends Node3D
""" [[ ============================================================ ]] """

""" [[ Node references ]] """
@onready var rayCastGroup: Node = $Ray
@onready var player_tower: Node3D = $"../Map/PlayerTower"

""" [[ Stats ]] """
var rays := {}
var speed: float = 5.0
var turn_speed: float = 2.5

""" [[ ============================================================ ]] """
""" [[ LifeCycle ]] """

func _ready() -> void:
	for ray in rayCastGroup.get_children():
		if ray is RayCast3D:
			rays[ray.name] = ray

func _process(delta: float) -> void:
	var steer := get_avoidance_steer()
	
	if steer != 0.0: rotate_y(steer * turn_speed * delta)
	look_at_tower(delta)
	
	var current_speed = speed
	if abs(steer) > 0.1:
		current_speed = 2.5
	
	translate(Vector3.FORWARD * current_speed * delta)

""" [[ ============================================================ ]] """
""" [[ Functions ]] """

func move_forward(delta: float) -> void:
	translate(Vector3.FORWARD * speed * delta)

func look_at_tower(delta: float) -> void:
	var dir_to_tower = player_tower.global_position - global_position
	dir_to_tower.y = 0
	
	if dir_to_tower.length_squared() < 0.001:
		return
	
	var target_angle = atan2(-dir_to_tower.x, -dir_to_tower.z)
	rotation.y = lerp_angle(rotation.y, target_angle, 3.0 * delta)
	
func get_avoidance_steer() -> float:
	var steer := 0.0
	
	var right  = rays["Right"].is_colliding()
	var left   = rays["Left"].is_colliding()
	
	if right: steer = 3.0
	elif left: steer = -3.0
	
	return steer
