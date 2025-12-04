extends Node3D

# --- Resources ---
const DAMAGE_FLASH_MAT = preload("uid://dlnxbyrt6u5g1")

# --- Node references ---
@onready var enemy: Node3D = self
@onready var rigid_body: RigidBody3D = $Mesh/RigidBody3D
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var target: Node3D = $"../Map/PlayerTower"
@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var mesh: MeshInstance3D = $Mesh

# --- Settings ---
@export var move_speed: float = 3.0
@export var enemy_health: float = 10.0
@export var attack_damage: float = 1.0

@export var reward_gold: int = 5
@export var reward_exp: int = 1

# --- Pathfinding ---
var path_update_timer := 0.0
const PATH_UPDATE_INTERVAL := 0.75


# --------------------------------------------------------------------
# Ready
# --------------------------------------------------------------------

func _ready():
	_find_target()
	if not target: return
	if target.has_method("is_tower_dead") and target.is_tower_dead(): return

	nav_agent.target_position = target.global_position
	nav_agent.connect("target_reached", Callable(self, "_on_target_reached"))
	enemy.add_to_group("Enemy")

# --------------------------------------------------------------------
# Target Handling
# --------------------------------------------------------------------

func _find_target():
	if not target:
		target = get_tree().get_first_node_in_group("PlayerTower")

# --------------------------------------------------------------------
# Movement & Physics
# --------------------------------------------------------------------

func _physics_process(delta):
	if not target: return

	_update_path_target(delta)
	_move_along_path(delta)

func _update_path_target(delta):
	path_update_timer -= delta
	if path_update_timer <= 0.0:
		nav_agent.target_position = target.global_position
		path_update_timer = PATH_UPDATE_INTERVAL

func _move_along_path(delta):
	var next_point = nav_agent.get_next_path_position()
	var dir = next_point - global_position

	if dir.length_squared() < 0.00001: return

	var move_dir = dir.normalized()
	global_position += move_dir * move_speed * delta
	_rotate_towards(move_dir)

	# Play walking animation only when actually moving
	if animator and not animator.is_playing():
		animator.play("Walking")

func _rotate_towards(move_dir: Vector3):
	var look_pos = global_position + move_dir
	look_at(Vector3(look_pos.x, global_position.y, look_pos.z), Vector3.UP)

# --------------------------------------------------------------------
# Attack
# --------------------------------------------------------------------

func _on_target_reached():
	if target and target.has_method("take_attack_damage"):
		target.take_attack_damage(attack_damage)
	_die()

# --------------------------------------------------------------------
# Damage & Death
# --------------------------------------------------------------------

func take_damage(amount: float):
	enemy_health -= amount
	_flash_damage()

	if enemy_health <= 0: _die()

func _die():
	enemy.queue_free()

func _flash_damage():
	if not mesh: return
	mesh.material_overlay = DAMAGE_FLASH_MAT

	var timer = get_tree().create_timer(0.1)
	timer.timeout.connect(func():
		if mesh:
			mesh.material_overlay = null
	)

# --------------------------------------------------------------------
# Cosmetic / Utility
# --------------------------------------------------------------------

func set_enemy_mesh(new_mesh: Mesh):
	mesh.mesh = new_mesh

func set_difficulty(multiplier: float):
	move_speed *= multiplier
	enemy_health *= multiplier
	attack_damage *= multiplier

func add_enemy_to_group():
	rigid_body.add_to_group("Enemy")
