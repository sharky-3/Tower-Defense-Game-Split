extends Node3D

var rng := RandomNumberGenerator.new()

# -----------------------------------------------------------
# Resources
# -----------------------------------------------------------

var tile_types := {
	"grass": preload("uid://bqr2nia2wo1lm"),
	"water": preload("uid://c5nkt4wxc0rs6"),
	"stone": preload("uid://12fnbjcnq5k4")
}

var environment := {
	"tree": preload("uid://bcuitu4oaj6xu")
}

# -----------------------------------------------------------
# Exported Data
# -----------------------------------------------------------

@export_range(10, 100) var world_map_scale := 25
@export_enum("Flat", "Hills", "Dunes") var terrain_type := "Hills"
@export_enum("Square", "Circle", "Diamond") var terrain_shape := "Circle"

# -----------------------------------------------------------
# Constants
# -----------------------------------------------------------

const TILE_SIZE := 1.5
const SPACING := 1.0
const WATER_LEVEL := -1.1
const TILE_BATCH_SIZE := 25
const TILE_BATCH_DELAY := 0.02

# -----------------------------------------------------------
# Runtime
# -----------------------------------------------------------

var world_radius_x := world_map_scale / 2.0
var world_radius_z := world_map_scale / 2.0

@onready var nav_region: NavigationRegion3D = $".."
@onready var player_tower: Node3D = $"../../Map/PlayerTower"
@onready var spawn_enemy_pos: Node3D = $"../../Map/spawn_enemy_position"

# -----------------------------------------------------------
# Lifecycle
# -----------------------------------------------------------

func _ready() -> void:
	rng.randomize()
	_generate_grid()

# -----------------------------------------------------------
# Helpers
# -----------------------------------------------------------

func _update_world_radius(new_scale: float) -> void:
	world_radius_x = new_scale / 2.0
	world_radius_z = new_scale / 2.0

func _clear_map() -> void:
	for c in get_children():
		if c is Node3D:
			c.queue_free()

func _animate_tile_placement(tile: Node3D) -> void:
	var start_scale := Vector3.ONE * 0.001
	tile.scale = start_scale

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)

	var delay := rng.randf_range(0.0, 0.15)
	tween.tween_property(tile, "scale", Vector3.ONE, 0.35).set_delay(delay)

# -----------------------------------------------------------
# Navigation (RUNS ONLY AFTER MAP IS DONE)
# -----------------------------------------------------------

func _finish_generation() -> void:
	await get_tree().process_frame
	nav_region.enabled = true
	nav_region.bake_navigation_mesh()

# -----------------------------------------------------------
# Tile Logic
# -----------------------------------------------------------

func is_water(dist: float, max_dist: float) -> bool:
	if dist > max_dist:
		return false
	return dist > max_dist * 0.85

func is_stone(x: int, z: int, dist: float, max_dist: float) -> bool:
	if dist < max_dist * 0.35:
		return (hash(x * 12891 + z * 77213) % 1000) / 1000.0 < 0.2
	return (hash(x * 99127 + z * 44111) % 1000) / 1000.0 < 0.05

# -----------------------------------------------------------
# Heightmap
# -----------------------------------------------------------

func get_land_height(dist: float, max_dist: float, x: float, z: float) -> float:
	var norm = clamp(1.0 - dist / max_dist, 0.0, 1.0)

	match terrain_type:
		"Flat":
			return (rng.randf() - 0.5) * 0.05
		"Hills":
			return max(norm * 1.2 + (rng.randf() - 0.5) * 0.25, 0.0)
		"Dunes":
			return (sin(x * 0.7) * 0.8 + cos(z * 0.8) * 0.4) * norm

	return 0.0

# -----------------------------------------------------------
# Environment
# -----------------------------------------------------------

func _generate_environment(tile: Node3D, type: String) -> void:
	if type != "grass":
		return

	if rng.randi_range(0, 10) != 2:
		return

	if environment.is_empty():
		return

	var key = environment.keys()[rng.randi() % environment.size()]
	var mesh = environment[key]

	var env := MeshInstance3D.new()
	env.mesh = mesh
	env.position = tile.position
	env.scale = Vector3.ONE * 0.2
	env.rotation.y = rng.randf_range(0, TAU)
	add_child(env)

# -----------------------------------------------------------
# Grid Generation (MAP FIRST)
# -----------------------------------------------------------

func _generate_grid() -> void:
	nav_region.enabled = false

	var max_dist = min(world_radius_x, world_radius_z)
	var batch_count := 0

	for x in range(-int(world_radius_x), int(world_radius_x) + 1):
		for z in range(-int(world_radius_z), int(world_radius_z) + 1):

			var dist := Vector2(x, z).length()

			match terrain_shape:
				"Circle":
					if dist > max_dist:
						continue
				"Diamond":
					if abs(x) + abs(z) > max_dist:
						continue

			var tile_type := "grass"

			if is_water(dist, max_dist):
				tile_type = "water"
			elif is_stone(x, z, dist, max_dist):
				tile_type = "stone"

			var tile = tile_types[tile_type].instantiate()

			var height := WATER_LEVEL if tile_type == "water" else get_land_height(dist, max_dist, x, z)

			tile.position = Vector3(
				x * TILE_SIZE * SPACING * cos(deg_to_rad(30)),
				height,
				z * TILE_SIZE * SPACING + (0.0 if x % 2 == 0 else (TILE_SIZE * SPACING) / 2.0)
			)

			add_child(tile)
			_animate_tile_placement(tile)

			Global.set_tile_node(x, z, tile)
			Global.set_terrain_coordinates(x, z, height)

			tile.set_meta("tile_type", tile_type)
			tile.set_meta("grid_coords", Vector2(x, z))
			tile.set_meta("is_taken", false)
			tile.set_meta("is_center", x == 0 and z == 0)

			if x == 0 and z == 0:
				player_tower.position = Vector3(0, height, 0)
				spawn_enemy_pos.position = Vector3(0, height + 1.0, 0)
			else:
				_generate_environment(tile, tile_type)

			batch_count += 1
			if batch_count >= TILE_BATCH_SIZE:
				batch_count = 0
				await get_tree().create_timer(TILE_BATCH_DELAY).timeout

	call_deferred("_finish_generation")

# -----------------------------------------------------------
# Public API
# -----------------------------------------------------------

func regenerate_map_with_scale(new_scale: float) -> void:
	_update_world_radius(new_scale)
	_clear_map()
	_generate_grid()
