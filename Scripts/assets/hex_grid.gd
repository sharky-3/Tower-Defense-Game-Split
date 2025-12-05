extends Node3D

# --- Resources ---
var tile_types: Dictionary = {
	"grass": preload("uid://bqr2nia2wo1lm"),
	"water": preload("uid://c5nkt4wxc0rs6"),
}

# --- Constants / Exported Data ---
@export_range(30, 100) var grid_size: float = 25.0
@export_enum("Flat", "Hills", "Mountain", "Dunes") var terrain_type: String = "Hills"

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
var world_radius: float = grid_size / 2.0

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

	if dist > max_dist * 0.85: return true

	if dist > 5:
		var n = (hash(x * 928371 + y * 192837) % 1000) / 1000.0
		if n < 0.15: return true
	return false

# -----------------------------------------------------------
# Heightmap / Terrain Generation
# -----------------------------------------------------------

func get_land_height(
	dist: float,
	max_dist: float,
	x: float,
	y: float
) -> float:

	var norm := 1.0 - (dist / max_dist)

	match terrain_type:
		"Flat":
			center_offset = Vector3.ZERO
			return (randf() - 0.5) * 0.05

		"Hills":
			center_offset = Vector3.ZERO
			var base := norm * 1.2
			return max(base + (randf() - 0.5) * 0.25, 0.0)

		"Mountain":
			center_offset = Vector3(0, 0.2, 0)
			var base := pow(norm, 3.0) * 2
			return base + (randf() - 0.5) * 0.1

		"Dunes":
			center_offset = Vector3.ZERO
			var wave := sin(x * 0.7) * 0.8 + cos(y * 1.2) * 0.4
			return wave * norm
	return 0.0

# -----------------------------------------------------------
# Grid Generation
# -----------------------------------------------------------

func _generate_grid():
	var center := Vector2(world_radius, world_radius)
	var max_dist := world_radius

	for x in range(grid_size):
		for y in range(grid_size):

			var dist := center.distance_to(Vector2(x, y))
			if dist > max_dist: continue

			var water := is_water(x, y, center, dist, max_dist)
			var tile: Node3D = (
				tile_types["water"] if water else tile_types["grass"]
			).instantiate()

			var tile_pos := Vector3(
				x * TILE_SIZE * SPACING * cos(deg_to_rad(30)),
				0,
				y * TILE_SIZE * SPACING + (0.0 if x % 2 == 0 else (TILE_SIZE * SPACING) / 2)
			)

			tile_pos.y = WATER_LEVEL if water else get_land_height(dist, max_dist, x, y)
			tile.position = tile_pos
			add_child(tile)

			if x == int(center.x) and y == int(center.y):

				var centered := tile_pos - center_offset
				tile.position = centered

				player_tower.position = centered
				player_camera.position = centered + Vector3(0, 10, 5)
				spawn_enemy_pos.position = centered + Vector3(0, 1, 0)

	nav_region.bake_navigation_mesh()
