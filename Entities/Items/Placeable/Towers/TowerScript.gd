""" [[ ============================================================ ]] """
extends Node3D
""" [[ ============================================================ ]] """

""" [[ Resources ]] """
const PLACE_TOWER_SOUND = preload("uid://bi7psknl1naq4")

""" [[ Constants / Exported Data ]] """
@export var apply_head_tilt: bool = false

""" [[ Node references ]] """
@onready var body: MeshInstance3D = $Body
@onready var head = $Head

@onready var collision: CollisionShape3D = $Area3D/Collision
@onready var area_3d: Area3D = $Area3D
@onready var timer: Timer = $Timer
@onready var ray_cast: RayCast3D = $Head/RayCast3D

@onready var front_raycast: RayCast3D = $Body/Front
@onready var left_raycast: RayCast3D = $Body/Left
@onready var back_raycast: RayCast3D = $Body/Back
@onready var right_raycast: RayCast3D = $Body/Right

""" [[ Stats ]] """
var tower_is_placed: bool = false
var enemies_in_range: Array = []
var current_target: Node3D = null

var tower_range: float = 0.0
var tower_damage: float = 0.0
var rotation_speed: float = 6.0

var tower_name: String = Global.tower_name

""" [[ ============================================================
	// FUNCTIONS
]] """

""" [[ ============================================================ ]] """
""" [[ Ready ]] """
func _ready() -> void:
	load_stats()
	timer.connect("timeout", Callable(self, "on_shoot_timer_timeout"))
	timer.start()

	if not area_3d.is_connected("body_entered", Callable(self, "_on_area_3d_body_entered")):
		area_3d.body_entered.connect(Callable(self, "_on_area_3d_body_entered"))

	if not area_3d.is_connected("body_exited", Callable(self, "_on_area_3d_body_exited")):
		area_3d.body_exited.connect(Callable(self, "_on_area_3d_body_exited"))

""" [[ ============================================================ ]] """
""" [[ Process ]] """
func _process(delta):
	if not tower_is_placed: return
	clean_tower()
	update_range(tower_range)
	if current_target: aim_at_target(delta)

""" [[ ============================================================ ]] """
""" [[ Rotate Tower To Target ]] """
func aim_at_target(delta: float):
	if current_target == null: return

	var enemy_height = 1.0
	var target_pos = current_target.global_transform.origin
	target_pos.y += enemy_height * 0.5

	var direction = (target_pos - head.global_transform.origin).normalized()

	var target_yaw = atan2(direction.x, direction.z) - deg_to_rad(270)
	var horizontal_distance = sqrt(direction.x * direction.x + direction.z * direction.z)
	var target_pitch = atan2(-direction.y, horizontal_distance)

	head.rotation.y = lerp_angle(head.rotation.y, target_yaw, rotation_speed * delta)
	head.rotation.x = lerp_angle(head.rotation.x, target_pitch, rotation_speed * delta) if apply_head_tilt else 0
	head.rotation.z = lerp_angle(head.rotation.z, target_pitch, rotation_speed * delta) if apply_head_tilt else 0

	update_raycast(target_pos)
	
""" [[ Get Target Position ]] """
func update_raycast(target_global_pos: Vector3):
	if not ray_cast or current_target == null: return

	var local_target = head.to_local(target_global_pos)
	ray_cast.target_position = local_target
	ray_cast.enabled = true

""" [[ ============================================================ ]] """
""" [[ Check if you can place tower ]] """
func can_tower_be_placed() -> bool:
	if front_raycast.is_colliding() or left_raycast.is_colliding() or left_raycast.is_colliding() or right_raycast.is_colliding():
		return false
	return true
	
""" [[ Tower Had Been Placed ]] """
func tower_placed():
	var can_place: bool = can_tower_be_placed()
	if can_place:
		tower_is_placed = true
		update_range(tower_range)

""" [[ ============================================================ ]] """
""" [[ Get Tower Stats ]] """
func load_stats():
	var stats = Global.get_tower_base_stats(tower_name)
	tower_range = stats.get("Range", 5.0)
	tower_damage = stats.get("Damage", 1.0)

""" [[ Update Tower Range ]] """
func update_range(value: float):
	if tower_is_placed:
		area_3d.scale = Vector3(value,2,value)

""" [[ ============================================================ ]] """
""" [[ Check If Tower is Alive ]] """
func clean_tower():
	for i in range(enemies_in_range.size() - 1, -1, -1):
		if enemies_in_range[i] == null or !is_instance_valid(enemies_in_range[i]):
			enemies_in_range.remove_at(i)

	if enemies_in_range.is_empty():
		current_target = null
	elif current_target == null or !is_instance_valid(current_target):
		current_target = enemies_in_range[0]

""" [[ ============================================================ ]] """
""" [[ Shooting Timer ]] """
func on_shoot_timer_timeout():
	if not tower_is_placed: return
	if enemies_in_range.is_empty(): return
	
	clean_tower()
	if current_target: shoot_enemy(current_target)

""" [[ Shoot Enemy ]] """
func shoot_enemy(target: Node3D):
	var enemy_node: Node3D = target.get_parent().get_parent()
	var posX = enemy_node.position.x
	var posZ = enemy_node.position.z
	
	if enemy_node and enemy_node.has_method("take_damage"):
		enemy_node.take_damage(tower_damage)
		
""" [[ ============================================================
	// SIGNAL FUNCTIONS
]] """

""" [[ ============================================================ ]] """
""" [[ Body Entered ]] """
func _on_area_3d_body_entered(body: Node3D):
	if body and body.is_in_group("Enemy"):
		enemies_in_range.append(body)
		if current_target == null: current_target = body

""" [[ Body Left ]] """
func _on_area_3d_body_exited(body: Node3D):
	if body and body.is_in_group("Enemy"):
		enemies_in_range.erase(body)
		if current_target == body:
			if enemies_in_range.is_empty(): current_target = null
			else: current_target = enemies_in_range[0]
