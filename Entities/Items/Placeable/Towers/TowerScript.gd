""" [[ ============================================================ ]] """
extends Node3D
""" [[ ============================================================ ]] """

""" [[ Resources ]] """
const PLACE_TOWER_SOUND = preload("uid://bi7psknl1naq4")

""" [[ Node references ]] """
@onready var tower_body_mesh: MeshInstance3D = $Body
@onready var collision: CollisionShape3D = $Area3D/Collision
@onready var area_3d: Area3D = $Area3D
@onready var timer: Timer = $Timer
@onready var ray_cast: RayCast3D = $Body/RayCast3D

""" [[ Stats ]] """
var tower_is_placed: bool = true
var enemies_in_range: Array = []
var current_target: Node3D = null

var tower_range: float = 0.0
var tower_damage: float = 0.0
var rotation_speed: float = 6.0

var tower_name: String = Global.tower_name
var opened_ui: bool = false

""" [[ ============================================================
	// FUNCTIONS
]] """

""" [[ ============================================================ ]] """
""" [[ Ready ]] """
func _ready() -> void:
	_get_tower_stats()
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	timer.start()

	if not area_3d.is_connected("body_entered", Callable(self, "_on_area_3d_body_entered")):
		area_3d.body_entered.connect(Callable(self, "_on_area_3d_body_entered"))

	if not area_3d.is_connected("body_exited", Callable(self, "_on_area_3d_body_exited")):
		area_3d.body_exited.connect(Callable(self, "_on_area_3d_body_exited"))

""" [[ ============================================================ ]] """
""" [[ Process ]] """
func _process(delta):
	if not tower_is_placed: return

	_tower_alive()
	_update_range_mesh(tower_range)

	if current_target:
		var target_global_pos = current_target.global_transform.origin
		var origin = ray_cast.global_transform.origin
		var direction = target_global_pos - origin

		_set_target_position_raycast(direction)
		_rotate_toward_target(delta)


""" [[ ============================================================ ]] """
""" [[ Rotate Tower To Target ]] """
func _rotate_toward_target(delta: float):
	if current_target == null:
		return

	var tower_pos = tower_body_mesh.global_transform.origin
	var target_pos = current_target.global_transform.origin

	var direction = (target_pos - tower_pos)
	direction.y = 0

	if direction.length() < 0.01: return

	var target_rotation = direction.normalized().angle_to(Vector3.FORWARD)
	var current_rotation = tower_body_mesh.global_transform.basis.get_euler().y

	var new_y = lerp_angle(current_rotation, direction.angle_to(Vector3.FORWARD), rotation_speed * delta)
	tower_body_mesh.rotate_y(new_y - current_rotation)
	
""" [[ ============================================================ ]] """
""" [[ Tower Had Been Placed ]] """
func tower_placed():
	tower_is_placed = true
	_update_range_mesh(tower_range)

""" [[ ============================================================ ]] """
""" [[ Get Tower Stats ]] """
func _get_tower_stats():
	var stats = Global.get_tower_base_stats(tower_name)
	tower_range = stats.get("Range", 5.0)
	tower_damage = stats.get("Damage", 1.0)

""" [[ ============================================================ ]] """
""" [[ Update Tower Range ]] """
func _update_range_mesh(value: float):

	if tower_is_placed:
		area_3d.scale = Vector3(value, 2.0, value)


""" [[ ============================================================ ]] """
""" [[ Check If Tower is Alive ]] """
func _tower_alive():
	for i in range(enemies_in_range.size() - 1, -1, -1):
		if enemies_in_range[i] == null or !is_instance_valid(enemies_in_range[i]):
			enemies_in_range.remove_at(i)

	if enemies_in_range.is_empty():
		current_target = null
	elif current_target == null or !is_instance_valid(current_target):
		current_target = enemies_in_range[0]

""" [[ ============================================================ ]] """
""" [[ Shooting Timer ]] """
func _on_timer_timeout():
	if not tower_is_placed: return
	if enemies_in_range.is_empty(): return
	
	_tower_alive()
	if current_target: _shoot_enemy(current_target)

""" [[ ============================================================ ]] """
""" [[ Shoot Enemy ]] """
func _shoot_enemy(target: Node3D):
	var enemy_node := target.get_parent().get_parent()
	if enemy_node and enemy_node.has_method("take_damage"):
		enemy_node.take_damage(tower_damage)

""" [[ ============================================================ ]] """
""" [[ Get Target Position ]] """
func _set_target_position_raycast(direction_to_enemy: Vector3):

	if direction_to_enemy.length() > 0.01:

		ray_cast.target_position = direction_to_enemy.normalized() * 100

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
