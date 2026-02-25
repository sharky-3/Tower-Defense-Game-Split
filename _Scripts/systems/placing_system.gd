extends Control

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

# --- Node references ---
@onready var camera: Camera3D = get_viewport().get_camera_3d()

# --- Stats ---
const TILE_SIZE: float = 1.5
const SPACING: float = 1
var TOWER_OFFSET: Vector3 = Vector3(0, 0.6, 0)
var tower_name: String = Global.tower_name

var current_building: Node3D = null
var current_target_coords: Vector2 = Vector2.ZERO

const ATTACK_TOWERS = ["basic_tower", "turret_tower", "cannon_tower", "slow_tower"]

# --------------------------------------------------------------------
# Life Cycle
# --------------------------------------------------------------------

func _ready():
	pass

func _process(_delta) -> void:
	if current_building:
		var pos = snap_to_hex_grid(get_mouse_world_position())
		current_building.global_transform.origin = pos

		current_target_coords = _world_to_grid(pos)

# --------------------------------------------------------------------
# Tower placing system
# --------------------------------------------------------------------

func _tower_can_be_placed():
	if current_building.has_method("tower_placed"):
		current_building.tower_placed()

func start_placing(_card_id: String):
	if current_building: 
		current_building.queue_free()
	
	var player_gold = _get_looking_value("Gold")
	var data = _get_tower_base_stats(_card_id)
	
	if player_gold >= data.get("Cost", 0):
		current_building = load(data["Mesh"]).instantiate()
		get_tree().current_scene.add_child(current_building)

		var pos = snap_to_hex_grid(get_mouse_world_position())
		current_building.global_transform.origin = pos
		
		var random_angle = deg_to_rad(rng.randf_range(0, 360))
		current_building.rotate(Vector3.UP, random_angle)
		
		_update_player_game_stats("Total_Towers_Placed", 1)

func get_mouse_world_position() -> Vector3:
	if camera == null:
		push_error("Camera is NULL")
		return Vector3.ZERO

	var mouse_pos = camera.get_viewport().get_mouse_position()
	var origin = camera.project_ray_origin(mouse_pos)
	var direction = camera.project_ray_normal(mouse_pos)
	var t = -origin.y / direction.y
	return origin + direction * t

func snap_to_hex_grid(world_pos: Vector3) -> Vector3:
	var tile_size = TILE_SIZE * SPACING
	var half_shift = tile_size / 2.0
	var cos30 = cos(deg_to_rad(30))

	var q = world_pos.x / (tile_size * cos30)
	var iq = int(round(q))
	var r = (world_pos.z - (half_shift if iq % 2 != 0 else 0.0)) / tile_size

	var rq = iq
	var rr = int(round(r))

	var snapped = Vector3.ZERO
	snapped.x = rq * tile_size * cos30
	snapped.z = rr * tile_size + (half_shift if rq % 2 != 0 else 0.0)
	snapped.y = Global.get_terrain_height_at_hex(rq, rr) + TOWER_OFFSET.y
	
	return snapped

func _world_to_grid(world_pos: Vector3) -> Vector2:
	var tile_size = TILE_SIZE * SPACING
	var half_shift = tile_size / 2.0
	var cos30 = cos(deg_to_rad(30))

	var q = world_pos.x / (tile_size * cos30)
	var iq = int(round(q))
	var r = (world_pos.z - (half_shift if iq % 2 != 0 else 0.0)) / tile_size

	return Vector2(iq, int(round(r)))

func _can_place_at(x: int, z: int, _tower_name: String) -> bool:
	var tile_node = Global.get_tile_node(x, z)
	if not tile_node: return false

	if _is_tile_taken(x, z): return false
	if _is_tile_center(x, z): return false

	var tile_type = _get_tile_type(x, z)
	if tile_type == "water" or tile_type == "grass":
		return false

	if _tower_name in ATTACK_TOWERS:
		if tile_type != "stone":
			return false
	return true

# --------------------------------------------------------------------
# Input
# --------------------------------------------------------------------

func _unhandled_input(event):
	if current_building and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var rq = int(current_target_coords.x)
			var rr = int(current_target_coords.y)
			
			if _can_place_at(rq, rr, tower_name):
				Global.set_tile_taken(rq, rr, true)
				_tower_can_be_placed()
				current_building = null
			else:
				push_warning("Cannot place tower here")

# --------------------------------------------------------------------
# Get Placing Tower
# --------------------------------------------------------------------

func chosen_placing_tower(_index: int):
	if current_building: 
		current_building.queue_free()
	
	var tower_id = ATTACK_TOWERS[_index]
	var data = _get_tower_base_stats(tower_id)
	var player_gold = _get_looking_value("Gold")
	
	Global.set_new_tower_name(tower_id)
	tower_name = Global.tower_name
	
	if player_gold >= data.get("Cost", 0):
		current_building = load(data["Mesh"]).instantiate()
		get_tree().current_scene.add_child(current_building)

		var pos = snap_to_hex_grid(get_mouse_world_position())
		current_building.global_transform.origin = pos
		
		var random_angle = deg_to_rad(rng.randf_range(0, 360))
		current_building.rotate(Vector3.UP, random_angle)
		
		_update_player_game_stats("Total_Towers_Placed", 1)

# --------------------------------------------------------------------
# Global Player Stats
# --------------------------------------------------------------------

func _update_player_game_stats(stat_name: String, value: int):
	Global.update_player_game_stats(stat_name, value)

func _get_looking_value(stat_name: String) -> int:
	return Global.get_looking_value(stat_name)
	
func _get_tower_base_stats(tower_name: String) -> Dictionary:
	return Global.get_tower_base_stats(tower_name)
	
func _get_tile_height(x: int, z: int) -> float:
	return Global.get_terrain_height_at_hex(x, z)

func _get_tile_type(x: int, z: int) -> String:
	return Global.get_tile_type(x, z)

func _is_tile_taken(x: int, z: int) -> bool:
	return Global.is_tile_taken(x, z)

func _is_tile_center(x: int, z: int) -> bool:
	return Global.is_tile_center(x, z)
