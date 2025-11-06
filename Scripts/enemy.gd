extends CharacterBody3D

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@export var speed := 4.0
@onready var target: Node3D = $"../PlayerTower"

func _ready() -> void:
	if not target: _set_target()
	navigation_agent_3d.target_position = target.global_position 

func _set_target():
	target = get_tree().get_first_node_in_group("PlayerTower")

func _physics_process(_delta: float) -> void:
	if not target:
		return

	# recalc path if needed
	if not navigation_agent_3d.is_target_reachable():
		navigation_agent_3d.set_target_position(target.global_position)

	# move along next path point
	var next_path_pos = navigation_agent_3d.get_next_path_position()
	var dir = (next_path_pos - global_position).normalized()

	velocity.x = dir.x * speed
	velocity.z = dir.z * speed

	# rotate only horizontally
	var target_pos = target.global_position
	target_pos.y = global_position.y
	look_at(target_pos, Vector3.UP)

	move_and_slide()

func _on_navigation_agent_3d_target_reached() -> void:
	print("enemy has reached player tower!")
