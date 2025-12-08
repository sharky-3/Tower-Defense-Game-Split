extends Node3D

# --- Node references ---
@onready var tower_body_mesh: MeshInstance3D = $Mesh

@onready var collision: CollisionShape3D = $Range/Area3D/Collision
@onready var area_3d: Area3D = $Area3D

@onready var timer: Timer = $Timer

# --- State ---
var current_upgrade: int = 0
var can_upgrade: bool = false
var tower_is_placed: bool = false

var enemies_in_range: Array = []
var tower_range: float = 0.0
var tower_damage: float = 0.0

var tower_name: String = "basic_tower"

# --------------------------------------------------------------------
# Life Cycle
# --------------------------------------------------------------------

func _ready() -> void:
	_get_tower_stats()
	_load_upgrade_level(0)
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	timer.start()

	area_3d.body_shape_entered.connect(Callable(self, "_on_area_3d_body_shape_entered"))
	area_3d.body_shape_exited.connect(Callable(self, "_on_area_3d_body_shape_exited"))
	
func _process(_delta) -> void:
	pass

# --------------------------------------------------------------------
# Upgrading
# --------------------------------------------------------------------

func tower_can_be_upgraded():
	can_upgrade = true
	tower_is_placed = true
	_update_range_mesh(tower_range)
	_placing_tower_animation(tower_body_mesh)
	
func _get_tower_stats():
	var stats = Global.get_tower_base_stats(tower_name)
	tower_range = stats["range"]
	tower_damage = stats["damage"]

func _load_upgrade_level(level: int) -> void:
	if not Global.get_tower_upgrade(tower_name, level): 
		return
	current_upgrade = level
	
	var data = Global.get_tower_upgrade(tower_name, current_upgrade)
	tower_range += data["range"]
	tower_damage += data["damage"]

	_update_range_mesh(tower_range)
	_upgrade_tower_animation(tower_body_mesh, data["mesh"])
	tower_body_mesh.mesh = data["mesh"]

	_update_player_stats("towers_upgraded", +1)

func _attemp_upgrade() -> void:
	if not can_upgrade: return
	_load_upgrade_level(current_upgrade + 1)
	
func _update_range_mesh(value: float) -> void:
	if tower_is_placed:
		area_3d.scale = Vector3(value, 2.0, value)
	
# --------------------------------------------------------------------
# Combat
# --------------------------------------------------------------------

func _on_timer_timeout():
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
		print(body)
		enemies_in_range.append(body)
		
func _on_area_3d_body_exited(body: Node3D) -> void:
	if body and body.is_in_group("Enemy"): 
		enemies_in_range.erase(body)
	
# --------------------------------------------------------------------s
# Input
# --------------------------------------------------------------------

#func _input(event):
	#if event is InputEventMouseButton and event.is_pressed() and can_upgrade:
		#_attemp_upgrade()

func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event and InputEventMouseButton:
		if event.is_action_pressed("LEFT_MOUSE_CLICK") and event.is_pressed() and can_upgrade:
			_attemp_upgrade()
			
# --------------------------------------------------------------------
# Global Player Stats
# --------------------------------------------------------------------

func _update_player_stats(stat_name: String, value: int):
	Global.update_player_stats(stat_name, value)

func _upgrade_tower_animation(tower_mesh: MeshInstance3D, new_mesh: Mesh) -> void:
	Global.play_upgrade_animation(tower_mesh, new_mesh)

func _placing_tower_animation(tower_mesh: MeshInstance3D) -> void:
	Global.play_placing_animation(tower_mesh)
