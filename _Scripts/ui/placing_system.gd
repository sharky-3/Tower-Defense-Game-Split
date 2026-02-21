extends Control

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

# --- Node references ---
@onready var card1: Button = $Card1
@onready var card2: Button = $Card2
@onready var card3: Button = $Card3
@onready var card4: Button = $Card4

@onready var camera := get_viewport().get_camera_3d()

# --- Stats ---
const TILE_SIZE: float = 1.5
const SPACING: float = 1
var TOWER_OFFSET: Vector3 = Vector3(0, 0.6, 0)
var tower_name: String = "basic_tower"

var current_building: Node3D = null

# --------------------------------------------------------------------
# Life Cycle
# --------------------------------------------------------------------

func _ready():
	card1.pressed.connect(func(): start_placing(0))
	card2.pressed.connect(func(): start_placing(1))
	card3.pressed.connect(func(): start_placing(2))
	card4.pressed.connect(func(): start_placing(3))

func _process(_delta) -> void:
	if current_building:
		var pos = snap_to_hex_grid(get_mouse_world_position())
		current_building.global_transform.origin = pos

# --------------------------------------------------------------------
# Tower placing system
# --------------------------------------------------------------------

func start_placing(_card_id: int):
	if current_building: current_building.queue_free()

	current_building = Global.get_base_mesh(tower_name).instantiate()
	get_tree().current_scene.add_child(current_building)

	var pos = snap_to_hex_grid(get_mouse_world_position())
	current_building.global_transform.origin = pos
	
	var random_angle = deg_to_rad(rng.randf_range(0, 360))
	current_building.rotate(Vector3(0, 1, 0), random_angle)
	
	_update_player_stats("towers_built", +1)

func get_mouse_world_position() -> Vector3:
	var mouse_pos = get_viewport().get_mouse_position()
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

	var _snapped = Vector3.ZERO
	_snapped.x = rq * tile_size * cos30
	_snapped.z = rr * tile_size + (half_shift if rq % 2 != 0 else 0.0)
	
	# Get terrain height and add tower offset
	var terrain_height = Global.get_terrain_height_at_hex(rq, rr)
	_snapped.y = terrain_height + TOWER_OFFSET.y
	
	return _snapped

# --------------------------------------------------------------------
# Input
# --------------------------------------------------------------------

func _unhandled_input(event):
	if current_building and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			current_building = null

# --------------------------------------------------------------------
# Global Player Stats
# --------------------------------------------------------------------

func _update_player_stats(stat_name: String, value: int):
	Global.update_player_stats(stat_name, value)

func _get_tile_height(x: int, z: int):
	return Global.get_terrain_height_at_hex(x, z)
