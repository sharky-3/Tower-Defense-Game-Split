""" [[ ============================================================ ]] """
extends Node3D
""" [[ ============================================================ ]] """

""" [[ Constants / Exported Data ]] """
@export var speed: float = 1.0
@export var health: float = 100.0
@export var damage: float = 6.0
@export var size: float = 1.0
@export var reach_distance: float = 3.0

@export var rewards: Dictionary = {
	"Gold": 5,
	"Exp": 1,
}

@export var deathSound: AudioStream

""" [[ Node references ]] """
@onready var character: MeshInstance3D = $Mesh
@onready var rigid_body: RigidBody3D = $Mesh/RigidBody3D
@onready var rayCastGroup: Node = $Ray

@onready var target: Node3D = get_node_or_null("../../World/SubViewport/Map/PlayerTower")

""" [[ Stats ]] """
var rays := {}

var steer_direction: float = 0.0
var steer_timer: float = 0.0
var steer_duration: float = 2.0
var turn_speed: float = 10

""" [[ ============================================================ ]] """
""" [[ LifeCycle ]] """

func _ready() -> void:
	for ray in rayCastGroup.get_children():
		if ray is RayCast3D:
			rays[ray.name] = ray

func _process(delta: float) -> void:
	if not target: return

	var distance_sq = global_position.distance_squared_to(target.global_position)
	if distance_sq <= self.reach_distance * self.reach_distance:
		reached_target()
		return

	var obstacle_steer := get_avoidance_steer()

	if obstacle_steer != 0.0:
		steer_direction = obstacle_steer
		steer_timer = steer_duration

	if steer_timer > 0.0:
		rotation.y = lerp_angle(
			rotation.y,
			rotation.y + steer_direction,
			5.0 * delta
		)	
		steer_timer -= delta
	else: 
		look_at_tower(delta)

	var tower_alive: bool = look_at_tower(delta)
	if not tower_alive: speed = 0
	var current_speed = speed

	if steer_timer > 0.0: current_speed = speed * 0.6
	
	translate(Vector3.FORWARD * current_speed * delta)

""" [[ ============================================================ ]] """
""" [[ Initialize ]] """

func set_character(mesh: Mesh):
	self.character.mesh = mesh
	scale = Vector3( size, size, size )

func set_stats(dictionary: Dictionary):
	self.speed = dictionary.get("Speed", 1.0)
	self.health = dictionary.get("Health", 1.0)
	self.damage = dictionary.get("Attack_Damage", 1.0)
	self.size = dictionary.get("Scale", 1.0)
	
	set_character(self.character.mesh)

func set_rewards(dictionary: Dictionary):
	self.rewards["Gold"] = dictionary.get("Gold", 0.0)
	self.rewards["Exp"] = dictionary.get("Exp", 0.0)

func set_group(): self.rigid_body.add_to_group("Enemy")

func set_difficulty(multiplier: float):
	self.speed *= multiplier
	self.health *= multiplier
	self.damage *= multiplier

""" [[ ============================================================ ]] """
""" [[ Functions ]] """

func look_at_tower(delta: float) -> bool:
	if not target: return false
	var dir_to_tower = target.global_position - global_position
	dir_to_tower.y = 0
	
	if dir_to_tower.length_squared() < 0.001: return false
	var target_angle = atan2(-dir_to_tower.x, -dir_to_tower.z)
	rotation.y = lerp_angle(rotation.y, target_angle, 3.0 * delta)
	
	return true

func move_forward(delta: float) -> void:
	translate(Vector3.FORWARD * speed * delta)
	
func get_avoidance_steer() -> float:
	var steer := 0.0
	
	var right  = rays["Right"].is_colliding()
	var left   = rays["Left"].is_colliding()
	
	if right: steer = 1.0
	elif left: steer = -1.0
	
	return steer

func take_damage(value: float):
	self.health -= value
	
	if self.health <= 0: character_die()
	_global_update_player_stats("Total_Damage_Dealted", value)

func character_die():
	_global_update_player_stats("Enemies_Killed", 1)
	_global_update_player_stats("Gold", self.rewards["Gold"])
	_global_update_player_stats("Exp", self.rewards["Exp"])
	queue_free()

func reached_target(): 
	if target and target.has_method("take_attack_damage"):
		target.take_attack_damage(self.damage)
	character_die()
	
""" [[ ============================================================ ]] """
""" [[ Globals ]] """

func _global_update_player_stats(_name: String, value: float):
	Global.update_player_game_stats(_name, value)
