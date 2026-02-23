extends Node3D

# --- Constants / Exported Data ---
@export var move_speed: float = 1.0
@export var enemy_health: float = 4.0
@export var attack_damage: float = 6.0
@export var character_scale: float = 0.4

@export var reward_gold: int = 5
@export var reward_exp: int = 1

# --- Node references ---
@onready var enemy: Node3D = self
@onready var rigid_body: RigidBody3D = $Mesh/RigidBody3D
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var target: Node3D = $"../SubViewportContainer/SubViewport/Map/PlayerTower"
@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var mesh: MeshInstance3D = $Mesh

# --- Stats ---
var path_update_timer := 0.0
const PATH_UPDATE_INTERVAL := 0.75

# --------------------------------------------------------------------
# Life Cycle
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

	if animator and not animator.is_playing():
		animator.play("Walking")

func _rotate_towards(move_dir: Vector3):
	var flat_dir = Vector3(move_dir.x, 0.0, move_dir.z)
	
	if flat_dir.length_squared() < 0.000001: return
	var look_pos = global_position + flat_dir
	if global_position.is_equal_approx(look_pos): return
	
	look_at(look_pos, Vector3.UP)

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

	if enemy_health <= 0: _die()
	_update_player_game_stats("stats", "damage_deald", amount)

func _die():
	enemy.queue_free()
	_update_player_game_stats("stats", "enemies_killed", +1)
	_update_player_game_stats("progression", "exp", reward_exp)
	_update_player_game_stats("currency", "gold", reward_gold)

# --------------------------------------------------------------------
# Cosmetic / Utility
# --------------------------------------------------------------------

func set_enemy_mesh(new_mesh: Mesh):
	mesh.mesh = new_mesh
	self.scale = Vector3(character_scale, character_scale, character_scale)

func set_enemy_stats(enemy_stats: Dictionary):
	move_speed = enemy_stats["speed"]
	enemy_health = enemy_stats["health"]
	attack_damage = enemy_stats["attack_damage"]
	character_scale = enemy_stats["scale"]
	
	set_enemy_mesh(mesh.mesh)  

func set_enemy_rewards(enemy_rewards):
	reward_gold = enemy_rewards["gold"]
	reward_exp = enemy_rewards["exp"]

func set_difficulty(multiplier: float):
	move_speed *= multiplier
	enemy_health *= multiplier
	attack_damage *= multiplier

func add_enemy_to_group():
	rigid_body.add_to_group("Enemy")

# --------------------------------------------------------------------
# Global Player Stats
# --------------------------------------------------------------------
	
func _update_player_game_stats(disctionary_name: String, stat_name: String, value: float):
	Global.update_player_game_stats(disctionary_name, stat_name, value)
