extends CharacterBody3D

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var target: Node3D = $"../PlayerTower"

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

func _ready() -> void:
	# Make sure we have a target
	if not target:
		_set_target()
		
	# Setup NavigationAgent3D
	if target:
		navigation_agent_3d.target_position = target.global_position + Vector3.UP
		navigation_agent_3d.target_desired_distance = 2.0
		navigation_agent_3d.connect("target_reached", Callable(self, "_on_navigation_agent_3d_target_reached"))

func _set_target():
	# Attempt to find a node in group "PlayerTower"
	target = get_tree().get_first_node_in_group("PlayerTower")

func _physics_process(_delta: float) -> void:
	if not target:
		return

	# Recalculate path if needed
	if not navigation_agent_3d.is_target_reachable():
		navigation_agent_3d.set_target_position(target.global_position + Vector3.UP)

	# Move along next path point
	var next_path_pos = navigation_agent_3d.get_next_path_position()
	var dir = (next_path_pos - global_position).normalized()
	
	velocity.x = dir.x * move_speed
	velocity.z = dir.z * move_speed
	velocity.y = 0  # prevent vertical movement
	
	# Rotate horizontally towards target
	var target_pos = target.global_position
	target_pos.y = global_position.y
	look_at(target_pos, Vector3.UP)
	
	move_and_slide()

func _on_navigation_agent_3d_target_reached() -> void:
	if target and target.has_method("take_attack_damage"):
		target.take_attack_damage(attack_damage)
	queue_free()
