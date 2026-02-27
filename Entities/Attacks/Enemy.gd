""" [[ ============================================================ ]] """
extends Node3D
""" [[ ============================================================ ]] """

""" [[ Constants / Exported Data ]] """
@export var move_speed: float = 1.0
@export var enemy_health: float = 4.0
@export var attack_damage: float = 6.0
@export var character_scale: float = 0.4

@export var reward_gold: int = 5
@export var reward_exp: int = 1

@export var death_sound: AudioStream

""" [[ Node references ]] """
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var rigid_body: RigidBody3D = $Mesh/RigidBody3D
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var target: Node3D = $"../SubViewportContainer/SubViewport/Map/PlayerTower"
@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var mesh: MeshInstance3D = $Mesh

""" [[ Stats ]] """
var path_update_timer := 0.0
const PATH_UPDATE_INTERVAL := 0.75

""" [[ ============================================================
	// FUNCTIONS
]] """

""" [[ ============================================================ ]] """
""" [[ Ready ]] """
func _ready():
	if not target:
		_find_target()
	if not target: return
	if target.has_method("is_tower_dead") and target.is_tower_dead(): return

	nav_agent.target_position = target.global_position
	nav_agent.connect("target_reached", Callable(self, "_on_target_reached"))
	add_to_group("Enemy")

""" [[ ============================================================ ]] """
""" [[ Find Target ]] """
func _find_target():
	if not target:
		target = get_tree().get_first_node_in_group("PlayerTower")

""" [[ ============================================================ ]] """
""" [[ Physics ]] """
func _physics_process(delta):
	if not target: return
	_update_path_target(delta)
	_move_along_path(delta)
	if nav_agent.is_navigation_finished():
		_on_target_reached()

""" [[ Update Path To Target ]] """
func _update_path_target(delta):
	path_update_timer -= delta
	if path_update_timer <= 0.0:
		nav_agent.target_position = target.global_position
		path_update_timer = PATH_UPDATE_INTERVAL

""" [[ Movement ]] """
func _move_along_path(delta):
	var next_point = nav_agent.get_next_path_position()
	var dir = next_point - global_position
	if dir.length_squared() < 0.00001: return

	var move_dir = dir.normalized()
	global_position += move_dir * move_speed * delta
	_rotate_towards(move_dir)

	if animator and not animator.is_playing():
		animator.play("Walking")

""" [[ Look Towards Target ]] """
func _rotate_towards(move_dir: Vector3):
	var flat_dir = Vector3(move_dir.x, 0.0, move_dir.z)
	if flat_dir.length_squared() < 0.000001: return
	look_at(global_position + flat_dir, Vector3.UP)

""" [[ ============================================================ ]] """
""" [[ Attack ]] """
func _on_target_reached():
	if target and target.has_method("take_attack_damage"):
		target.take_attack_damage(attack_damage)
	_die()

""" [[ Take Damage ]] """
func take_damage(amount: float):
	enemy_health -= amount
	if enemy_health <= 0: 
		_die()
	_update_player_game_stats("Total_Damage_Dealed", amount)

""" [[ Die ]] """
func _die():
	_update_player_game_stats("Enemies_Killed", 1)
	_update_player_game_stats("Exp", reward_exp)
	_update_player_game_stats("Gold", reward_gold)
	queue_free()

""" [[ ============================================================ ]] """
""" [[ Set Enemy Mesh ]] """
func set_enemy_mesh(new_mesh: Mesh):
	mesh.mesh = new_mesh
	scale = Vector3(character_scale, character_scale, character_scale)

""" [[ Set Enemy Stats ]] """
func set_enemy_stats(enemy_stats: Dictionary):
	move_speed = enemy_stats.get("speed", 1.0)
	enemy_health = enemy_stats.get("health", 4.0)
	attack_damage = enemy_stats.get("attack_damage", 6.0)
	character_scale = enemy_stats.get("scale", 3)
	set_enemy_mesh(mesh.mesh)
	
""" [[ Set Enemy Rewards ]] """
func set_enemy_rewards(enemy_rewards: Dictionary):
	reward_gold = enemy_rewards.get("Gold", 0)
	reward_exp = enemy_rewards.get("Exp", 0)

""" [[ Set Difficulty ]] """
func set_difficulty(multiplier: float):
	move_speed *= multiplier
	enemy_health *= multiplier
	attack_damage *= multiplier

""" [[ Add To Group ]] """
func add_enemy_to_group():
	rigid_body.add_to_group("Enemy")

""" [[ ============================================================ ]] """
""" [[ Interaction Test ]] """
func on_clicked():
	print("Clicked enemy")
	
""" [[ ============================================================
	// GLOBAL
]] """

""" [[ Update Player Stats ]] """
func _update_player_game_stats(stat_name: String, value: float):
	Global.update_player_game_stats(stat_name, value)
