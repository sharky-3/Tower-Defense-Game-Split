extends Node3D

const GRASS_TILE = preload("uid://bqr2nia2wo1lm")
const WATER_TILE = preload("uid://c5nkt4wxc0rs6")

@onready var navigation_region_3d: NavigationRegion3D = $".."
@onready var player_tower: Node3D = $"../../Map/PlayerTower"
@onready var player_camera: Node3D = $"../../CameraPosition"
@onready var spawn_enemy_position: Node3D = $"../../Map/spawn_enemy_position"

const TILE_SIZE := 1.5
const SPACING := 1
var CENTER_OFFSET := Vector3(0, 0.2, 0)

@export_range(30, 100) var grid_size := 20
var radius: int = grid_size / 2 

# Terrain types
@export_enum("Flat", "Hills", "Mountain") var terrain_type: String = "Hills"

# --- NEW: global water level ---
const WATER_LEVEL := -1.1   # lower = deeper ocean

func _ready() -> void:
	randomize()
	_generate_grid()

func is_water(x: int, y: int, _center: Vector2, dist: float, max_dist: float) -> bool:
	if dist > max_dist * 0.85:
		return true
	if dist > 5:
		var n := hash(x * 928371 + y * 192837) % 1000 / 1000.0
		if n < 0.15:
			return true
	return false

func get_land_height(dist: float, max_dist: float) -> float:
	var normalized := 1.0 - (dist / max_dist)

	match terrain_type:
		"Flat":
			CENTER_OFFSET = Vector3(0, 0, 0)
			return (randf() - 0.5) * 0.05

		"Hills":
			var base := normalized * 1.2
			CENTER_OFFSET = Vector3(0, 0, 0)
			return max(base + (randf() - 0.5) * 0.25, 0.0)

		"Mountain":
			var base := pow(normalized, 3.5) * 6
			CENTER_OFFSET = Vector3(0, 0.2, 0)
			var noise := (randf() - 0.5) * 0.1
			return base + noise

	return 0.0

func _generate_grid():
	var center := Vector2(radius, radius)
	var max_dist := radius

	for x in range(grid_size):
		for y in range(grid_size):

			var dist := center.distance_to(Vector2(x, y))
			if dist > max_dist:
				continue

			var tile_is_water := is_water(x, y, center, dist, max_dist)

			var tile: Node3D
			if tile_is_water:
				tile = WATER_TILE.instantiate()
			else:
				tile = GRASS_TILE.instantiate()

			var tile_coordinates := Vector3(
				x * TILE_SIZE * SPACING * cos(deg_to_rad(30)),
				0,
				y * TILE_SIZE * SPACING + (0 if x % 2 == 0 else (TILE_SIZE * SPACING) / 2)
			)

			# --- NEW FIXED WATER LEVEL ---
			if tile_is_water:
				tile_coordinates.y = WATER_LEVEL
			else:
				tile_coordinates.y = get_land_height(dist, max_dist)

			tile.position = tile_coordinates
			add_child(tile)

			# Center placement
			if x == int(center.x) and y == int(center.y):
				tile.position = tile_coordinates - CENTER_OFFSET
				player_tower.position = tile_coordinates - CENTER_OFFSET
				player_camera.position = tile_coordinates + Vector3(0, 10, 5)
				spawn_enemy_position.position = tile_coordinates + Vector3(0, 0, -5)

	navigation_region_3d.bake_navigation_mesh()
