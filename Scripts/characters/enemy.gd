extends CharacterBody3D

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var target: Node3D = $"../Map/PlayerTower"
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var mesh: MeshInstance3D = $Mesh

@export_category("Main")
@export var move_speed: float
@export var enemie_health: float

@export_category("Combat")
@export var attach_move_speed: float
@export var attack_damage: float
@export var attack_cooldown: float

@export_category("Status")
@export var is_alive: bool = true
@export var is_slowed: bool
@export var slow_factor: float = .5
@export var can_fly: bool

@export_category("Rewards")
@export var reward_gold: int
@export var reward_exp: int

@export_category("Visual/Audio")
@export var death_effect: bool
@export var hit_sound: AudioStream
@export var death_sound: AudioStream

# Optimization: throttle path updates
var path_update_timer: float = 0.5
const PATH_UPDATE_INTERVAL: float = 1.0

func _ready() -> void:
	if not target:
		_set_target()
	if target:
		navigation_agent_3d.target_position = target.global_position + Vector3.UP
		navigation_agent_3d.target_desired_distance = 2.0
		navigation_agent_3d.connect("target_reached", Callable(self, "_on_navigation_agent_3d_target_reached"))

func _set_target():
	target = get_tree().get_first_node_in_group("PlayerTower")

func look_at_xz(target_pos: Vector3) -> void:
	var flat_target = Vector3(target_pos.x, global_position.y, target_pos.z)
	look_at(flat_target, Vector3.UP)

func set_enemy_mesh(new_mesh: Mesh) -> void:
	if mesh:
		mesh.mesh = new_mesh

func _physics_process(_delta: float) -> void:
	if not target:
		return

	# Throttle navigation updates
	path_update_timer -= _delta
	if path_update_timer <= 0.0:
		if not navigation_agent_3d.is_target_reachable():
			navigation_agent_3d.set_target_position(target.global_position + Vector3.UP)
		path_update_timer = PATH_UPDATE_INTERVAL

	var next_path_pos = navigation_agent_3d.get_next_path_position()
	var dir = (next_path_pos - global_position).normalized()

	velocity.x = dir.x * move_speed
	velocity.z = dir.z * move_speed
	velocity.y = dir.y * move_speed
	
	animation.play("Walking")
	# Rotate only if necessary
	if (target.global_position - global_position).length() > 0.1:
		look_at_xz(target.global_position)

	move_and_slide()

func set_difficulty(multiplier: float) -> void:
	move_speed *= multiplier
	enemie_health *= multiplier
	attack_damage *= multiplier

func _on_navigation_agent_3d_target_reached() -> void:
	if target and target.has_method("take_attack_damage"):
		target.take_attack_damage(attack_damage)
	queue_free()
