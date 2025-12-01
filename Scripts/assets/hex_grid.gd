extends Node3D

const TILE = preload("uid://bqr2nia2wo1lm")
const TILE_SIZE := 1.5
const SPACING := 1.125

@export_range(3, 20) var grid_size := 10

func _ready() -> void:
	_generate_grid()

func _generate_grid():
	for x in range(grid_size):
		for y in range(grid_size):
			var tile = TILE.instantiate()
			add_child(tile)

			var tile_coordinates = Vector3.ZERO
			tile_coordinates.x = x * TILE_SIZE * SPACING * cos(deg_to_rad(30))
			tile_coordinates.z = y * TILE_SIZE * SPACING + (0 if x % 2 == 0 else (TILE_SIZE * SPACING) / 2)

			tile.translate(tile_coordinates)
