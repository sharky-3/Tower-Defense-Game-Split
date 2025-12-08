extends Node3D

# --- Resources ---
var tile_types: Dictionary = {
	"grass": preload("uid://bqr2nia2wo1lm"),
	"water": preload("uid://c5nkt4wxc0rs6"),
	"stone": preload("uid://12fnbjcnq5k4")
}

# --- Constants / Exported Data ---
@export_range(10, 100) var grid_size_x: int = 25
@export_range(10, 100) var grid_size_z: int = 25
@export_enum("Flat", "Hills", "Dunes", "Valleys", "Rough") var terrain_type: String = "Hills"
@export_enum("Square", "Circle", "Island", "Oval", "Ring", "Diamond") var terrain_shape: String = "Circle"

var world_radius_x: float = grid_size_x / 2.0
var world_radius_z: float = grid_size_z / 2.0

# --- Node references ---
@onready var nav_region: NavigationRegion3D = $".."
@onready var player_tower: Node3D = $"../../Map/PlayerTower"
@onready var player_camera: Node3D = $"../../CameraPosition"
@onready var spawn_enemy_pos: Node3D = $"../../Map/spawn_enemy_position"

# --- Stats ---
const TILE_SIZE := 1.5
const SPACING := 1.0
const WATER_LEVEL := -1.1

var center_offset := Vector3(0, 0.2, 0)

# -----------------------------------------------------------
# Life Cycle
# -----------------------------------------------------------

func _ready() -> void:
	randomize()
	_generate_grid()

func _process(_delta) -> void:
	pass

# -----------------------------------------------------------
# Tile Type Checks
# -----------------------------------------------------------

func is_water(
	x: int,
	y: int,
	_center: Vector2,
	dist: float,
	max_dist: float
) -> bool:

	# Water near edges for some shapes
	match terrain_shape:
		"Circle", "Island", "Oval", "Ring", "Diamond":
			if dist > max_dist * 0.85: return true

	# Random water patches
	if dist > 5:
		var n = (hash(x * 928371 + y * 192837) % 1000) / 1000.0
		if n < 0.15: return true
	return false

func is_stone(
	x: int,
	y: int,
	_center: Vector2,
	dist: float,
	max_dist: float
) -> bool:

	if dist < max_dist * 0.35:
		var n = (hash(x * 12891 + y * 77213) % 1000) / 1000.0
		if n < 0.20:
			return true

	var n2 = (hash(x * 99127 + y * 44111) % 1000) / 1000.0
	return n2 < 0.05

# -----------------------------------------------------------
# Heightmap / Terrain Generation
# -----------------------------------------------------------

func get_land_height(dist: float, max_dist: float, x: float, y: float) -> float:
	var norm := 1.0 - (dist / max_dist)

	match terrain_type:
		"Flat":
			center_offset = Vector3.ZERO
			return (randf() - 0.5) * 0.05
		"Hills":
			center_offset = Vector3.ZERO
			var base := norm * 1.2
			return max(base + (randf() - 0.5) * 0.25, 0.0)
		"Dunes":
			center_offset = Vector3.ZERO
			var wave := sin(x * 0.7) * 0.8 + cos(y * 1.2) * 0.4
			return wave * norm
		"Valleys":
			center_offset = Vector3.ZERO
			var base := pow(dist / max_dist, 1.5)
			return -(base + (randf() - 0.5) * 0.2)
		"Rough":
			center_offset = Vector3.ZERO
			return (randf() - 0.5) * 1.5
	return 0.0

# -----------------------------------------------------------
# Grid Generation with Shapes
# -----------------------------------------------------------

func _generate_grid():
	var center := Vector2(world_radius_x, world_radius_z)
	var max_dist = max(world_radius_x, world_radius_z)

	# Calculate start/end ranges so the grid expands around (0,0)
	var half_x = grid_size_x / 2.0
	var half_z = grid_size_z / 2.0

	for x_offset in range(-int(half_x), int(half_x) + 1):
		for z_offset in range(-int(half_z), int(half_z) + 1):
			var grid_x = int(center.x + x_offset)
			var grid_z = int(center.y + z_offset)

			# Distance from center
			var dist := Vector2(grid_x, grid_z).distance_to(center)

			# Skip tiles outside the shape
			match terrain_shape:
				"Circle", "Island":
					if dist > max_dist: continue
				"Oval":
					var dx = abs(grid_x - center.x) / world_radius_x
					var dz = abs(grid_z - center.y) / world_radius_z
					if dx*dx + dz*dz > 1: continue
				"Ring":
					if dist < max_dist * 0.4 or dist > max_dist: continue
				"Diamond":
					var dx = abs(grid_x - center.x)
					var dz = abs(grid_z - center.y)
					if dx + dz > max_dist: continue

			var water := is_water(grid_x, grid_z, center, dist, max_dist)
			var tile_type := "grass"
			if water: 
				tile_type = "water"
			elif is_stone(grid_x, grid_z, center, dist, max_dist):
				tile_type = "stone"

			var tile: Node3D = tile_types[tile_type].instantiate()


			var tile_pos := Vector3(
				x_offset * TILE_SIZE * SPACING * cos(deg_to_rad(30)),
				0,
				z_offset * TILE_SIZE * SPACING + (0.0 if grid_x % 2 == 0 else (TILE_SIZE * SPACING) / 2)
			)

			var height := WATER_LEVEL if water else get_land_height(dist, max_dist, grid_x, grid_z)
			_set_terrain_coordinates(x_offset, z_offset, height)

			tile_pos.y = height
			tile.position = tile_pos
			add_child(tile)

			Global.set_tile_node(x_offset, z_offset, tile)
			
			tile.set_meta("tile_type", ("water" if water else "grass"))
			tile.set_meta("is_center", x_offset == 0 and z_offset == 0)
			tile.set_meta("is_taken", false)
			tile.set_meta("grid_coords", Vector2(x_offset, z_offset))

			if x_offset == 0 and z_offset == 0:
				player_tower.position = Vector3(0, height, 0)
				spawn_enemy_pos.position = Vector3(0, height + 1, 0)

	nav_region.bake_navigation_mesh()

# --------------------------------------------------------------------
# Global Terrain
# --------------------------------------------------------------------

func _set_terrain_coordinates(x: int, z: int, y: float):
	Global.set_terrain_coordinates(x, z, y)
