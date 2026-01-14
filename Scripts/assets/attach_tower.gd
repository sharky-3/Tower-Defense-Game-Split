extends Node3D

# --- Imports ---
const PLACE_TOWER_SOUND: AudioStream = preload("uid://c8ac13k1jtjbe")

# --- Node references ---
@onready var head: MeshInstance3D = $Head
@onready var tower_body_mesh: MeshInstance3D = $Body
@onready var collision: CollisionShape3D = $Area3D/Collision
@onready var area_3d: Area3D = $Area3D
@onready var timer: Timer = $Timer
@onready var ray_cast: RayCast3D = $Body/RayCast3D
@onready var target_check_timer: Timer = $TargetCheckTimer

@onready var quad: MeshInstance3D = $UI/Quad
@onready var selection_wheel: Control = $UI/SubViewport/SelectionWheel

# --- State ---
var current_upgrade: int = 0
var can_upgrade: bool = false
var tower_is_placed: bool = false

var enemies_in_range: Array = []
var current_target: Node3D = null
var tower_range: float = 0.0
var tower_damage: float = 0.0
var rotation_speed: float = 6.0

var tower_name: String = Global.tower_name
var opened_ui: bool = true

# --------------------------------------------------------------------
# Life Cycle
# --------------------------------------------------------------------

func _ready() -> void:
	_get_tower_stats()
	_load_upgrade_level(0)
	
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	timer.start()

	area_3d.body_entered.connect(Callable(self, "_on_area_3d_body_entered"))
	area_3d.body_exited.connect(Callable(self, "_on_area_3d_body_exited"))
	
func _process(_delta):
	_tower_alive()
	_update_range_mesh(tower_range)
	
	if current_target:
		#_rotate_towards_target(_delta)
		
		var target_global_pos = current_target.global_transform.origin
		var origin = ray_cast.global_transform.origin
		var direction = (target_global_pos - origin)

		_set_target_position_raycast(direction)
	
func _tower_alive() -> void:
	for i in range(enemies_in_range.size() - 1, -1, -1):
		if enemies_in_range[i] == null or !is_instance_valid(enemies_in_range[i]):
			enemies_in_range.remove_at(i)
	
	if current_target == null or !is_instance_valid(current_target):
		current_target = enemies_in_range[0] if enemies_in_range.size() > 0 else null
	elif current_target not in enemies_in_range:
		current_target = enemies_in_range[0] if enemies_in_range.size() > 0 else null
		
# --------------------------------------------------------------------
# RayCast
# --------------------------------------------------------------------

func _set_target_position_raycast(enemy_position: Vector3):
	var direction_to_enemy: Vector3 = enemy_position
	if direction_to_enemy.length() > 0.01:
		var local_target_offset: Vector3 = direction_to_enemy.normalized() * 100
		ray_cast.target_position = local_target_offset
		
# --------------------------------------------------------------------
# Upgrading
# --------------------------------------------------------------------

func tower_can_be_upgraded():
	tower_is_placed = true
	_update_range_mesh(tower_range)
	_placing_tower_animation(tower_body_mesh)
	
	_play_audio(PLACE_TOWER_SOUND, 0.7)
	timer.start(0.5)
	
func _get_tower_stats():
	var stats = Global.get_tower_base_stats(tower_name)
	tower_range = stats["range"]
	tower_damage = stats["damage"]

func _load_upgrade_level(level: int) -> void:	
	if not _get_tower_upgrade(tower_name, level): 
		return
	
	var player_gold = _get_looking_value("currency", "gold")
	var data = _get_tower_upgrade(tower_name, level)
	var tower_price = data["price"]
	
	if player_gold >= tower_price:
		tower_range = data["range"]
		tower_damage = data["damage"] 
		current_upgrade = level
		
		_update_player_game_stats("currency", "gold", -tower_price)
	
		_update_range_mesh(tower_range)
		_upgrade_tower_animation(tower_body_mesh, data["mesh"])
		tower_body_mesh.mesh = data["mesh"]

		_update_player_game_stats("stats", "towers_upgraded", +1)
		_play_audio(PLACE_TOWER_SOUND, 0.7)

func _attemp_upgrade(index) -> void:
	if not can_upgrade: return
	current_upgrade = index
	_load_upgrade_level(current_upgrade)
	
func _update_range_mesh(value: float) -> void:
	if tower_is_placed:
		area_3d.scale = Vector3(value, 2.0, value)
	
# --------------------------------------------------------------------
# Combat
# --------------------------------------------------------------------

func _rotate_towards_target(delta: float) -> void:
	if not current_target and not head: return

	var tower_pos: Vector3 = head.global_transform.origin
	var target_pos: Vector3 = current_target.global_transform.origin

	var direction: Vector3 = target_pos - tower_pos
	direction.y = 0.0

	if direction.length() < 0.01: return
	direction = direction.normalized()

	var target_yaw: float = atan2(direction.x, direction.z)

	var current_rot: Vector3 = head.rotation
	current_rot.y = -lerp_angle(current_rot.y, target_yaw, delta * rotation_speed)
	head.rotation = -current_rot

func _on_timer_timeout():
	if not tower_is_placed: return
	if not can_upgrade:
		can_upgrade = true
		return
	if enemies_in_range.is_empty(): return
	
	_tower_alive()
	if enemies_in_range.is_empty(): return
	
	var target = enemies_in_range[0]
	_shoot_enemy(target)

func _shoot_enemy(target: Node3D) -> void:
	var enemy_node := target.get_parent().get_parent()
	if enemy_node and enemy_node.has_method("take_damage"):
		enemy_node.take_damage(tower_damage)

# --------------------------------------------------------------------
# Detection
# --------------------------------------------------------------------

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body and body.is_in_group("Enemy"):
		enemies_in_range.append(body)
		if current_target == null:
			current_target = body

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body and body.is_in_group("Enemy"):
		enemies_in_range.erase(body)

		if current_target == body:
			if enemies_in_range.is_empty(): current_target = null
			else: current_target = enemies_in_range[0]

# --------------------------------------------------------------------
# Input
# --------------------------------------------------------------------

func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event and InputEventMouseButton:
		if event.is_action_pressed("LEFT_MOUSE_CLICK") and event.is_pressed() and can_upgrade:
			_attamp_show_ui()
			
# --------------------------------------------------------------------
# Audio
# --------------------------------------------------------------------

func _play_audio(stream: AudioStream, starting_time: float):
	$AudioStreamPlayer3D.stream = stream
	$AudioStreamPlayer3D.play(starting_time)

# --------------------------------------------------------------------
# User Interface
# --------------------------------------------------------------------
	
func _attamp_show_ui():
	
	var tower_pos: Vector3 = tower_body_mesh.global_transform.origin
	var offset: Vector3 = Vector3(5, 0, 5)
	
	if not opened_ui:
		Global.open_ui(selection_wheel)
		selection_wheel.set_meta("tower_ref", self)
		selection_wheel.add_to_group("tower_upgrade")
		
		opened_ui = true
	else:
		Global.close_ui(selection_wheel)
		opened_ui = false

# --------------------------------------------------------------------
# Global Player Stats
# --------------------------------------------------------------------

func _update_player_game_stats(dictionary_name: String ,stat_name: String, value: int):
	Global.update_player_game_stats(dictionary_name, stat_name, value)
	
func _get_looking_value(directory_name: String, stat_name: String):
	return Global.get_looking_value(directory_name, stat_name)
	
func _get_tower_upgrade(stat_name: String, level: int):
	return Global.get_tower_upgrade(stat_name, level)

func _upgrade_tower_animation(tower_mesh: MeshInstance3D, new_mesh: Mesh) -> void:
	Global.play_upgrade_animation(tower_mesh, new_mesh)

func _placing_tower_animation(tower_mesh: MeshInstance3D) -> void:
	Global.play_placing_animation(tower_mesh)
