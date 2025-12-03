extends Node3D
@onready var ENEMY: Node3D = $"."
@onready var rigid_body_3d: RigidBody3D = $Mesh/RigidBody3D

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var target: Node3D = $"../Map/PlayerTower"
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var mesh: MeshInstance3D = $Mesh

@export_category("Main")
@export var move_speed: float = 3.0
@export var enemie_health: float = 10.0

@export_category("Combat")
@export var attack_damage: float = 1.0
@export var attack_cooldown: float = 1.0

@export_category("Status")
@export var is_alive: bool = true
@export var is_slowed: bool = false
@export var slow_factor: float = 0.5
@export var can_fly: bool = false

@export_category("Rewards")
@export var reward_gold: int = 5
@export var reward_exp: int = 1

# Path update throttle
var path_update_timer := 0.0
const PATH_UPDATE_INTERVAL := 0.75   # update less often = faster

func _ready():
	if not target:
		_set_target()

	navigation_agent_3d.target_position = target.global_position
	navigation_agent_3d.connect("target_reached", Callable(self, "_on_target_reached"))

func _set_target():
	target = get_tree().get_first_node_in_group("PlayerTower")

func look_at_xz(pos: Vector3):
	var flat = Vector3(pos.x, global_position.y, pos.z)
	look_at(flat, Vector3.UP)

func _physics_process(delta):
	if not target:
		return

	# Throttle expensive pathfinding calls
	path_update_timer -= delta
	if path_update_timer <= 0.0:
		navigation_agent_3d.target_position = target.global_position
		path_update_timer = PATH_UPDATE_INTERVAL

	# Path movement
	var next_point = navigation_agent_3d.get_next_path_position()
	var dir = next_point - global_position

	var move_dir = dir.normalized()
	global_position += move_dir * move_speed * delta
	look_at_xz(global_position + move_dir)

	# Play walking animation only when moving
	if animation and not animation.is_playing() and dir.length_squared() > 0.0001:
		animation.play("Walking")

func _on_target_reached():
	if target and target.has_method("take_attack_damage"):
		target.take_attack_damage(attack_damage)
	queue_free()

func set_enemy_mesh(new_mesh: Mesh):
	mesh.mesh = new_mesh

func set_difficulty(multiplier: float):
	move_speed *= multiplier
	enemie_health *= multiplier
	attack_damage *= multiplier

func take_damage(damage: float):
	enemie_health -= damage
	if enemie_health <= 0:
		ENEMY.queue_free()
		
func add_group():
	rigid_body_3d.add_to_group("Enemy")
