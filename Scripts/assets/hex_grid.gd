extends Node3D

@onready var navigation_region_3d: NavigationRegion3D = $".."
const GRASS_TILE = preload("uid://bqr2nia2wo1lm")
const WATER_TILE = preload("uid://c5nkt4wxc0rs6")
@onready var player_tower: Node3D = $"../../Map/PlayerTower"

const TILE_SIZE := 1.5
const SPACING := 1.1

@export_range(30, 30) var grid_size := 20
var radius: int = grid_size / 2 

func _ready() -> void:
	randomize()
	_generate_grid()

func is_water(x: int, y: int, _center: Vector2, dist: float, max_dist: float) -> bool:
	# --- OCEAN RING (outer 10%) ---
	if dist > max_dist * 0.85: return true

	# --- LAKES: large blobs, only beyond 5 tiles ---
	if dist > 5:
		var n := hash(x * 928371 + y * 192837) % 1000 / 1000.0
		if n < 0.15: return true
	return false

func _generate_grid():
	var center := Vector2(radius, radius)
	var max_dist := radius

	for x in range(grid_size):
		for y in range(grid_size):

			# Compute circular mask
			var dist := center.distance_to(Vector2(x, y))
			if dist > max_dist: continue

			# Pick tile type
			var tile: Node3D
			if is_water(x, y, center, dist, max_dist):
				tile = WATER_TILE.instantiate()
				tile.position.y -= 0.25
			else:
				tile = GRASS_TILE.instantiate()

			# --- HEX COORDINATES ---
			var tile_coordinates := Vector3.ZERO
			tile_coordinates.x = x * TILE_SIZE * SPACING * cos(deg_to_rad(30))
			tile_coordinates.z = y * TILE_SIZE * SPACING + (0.0 if x % 2 == 0 else (TILE_SIZE * SPACING) / 2)
			tile_coordinates.y += 0.05 

			tile.translate(tile_coordinates)
			add_child(tile)

			# --- Center tile: place player tower ---
			if x == int(center.x) and y == int(center.y):
				player_tower.position = tile_coordinates
				player_tower.position.y += 1.15

	navigation_region_3d.bake_navigation_mesh()
