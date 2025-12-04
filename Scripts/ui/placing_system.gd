extends Control

# =============================================
# BUILDINGS (3D scenes)
const BUILDINGS = [
	preload("uid://cvq5oa37c1bkt"),
	preload("uid://cvq5oa37c1bkt"),
	preload("uid://cvq5oa37c1bkt"),
	preload("uid://cvq5oa37c1bkt")
]

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

# =============================================
# ONREADY BUTTONS
@onready var card1: Button = $Card1
@onready var card2: Button = $Card2
@onready var card3: Button = $Card3
@onready var card4: Button = $Card4

const TILE_SIZE: float = 1.5
const SPACING: float = 1
var TOWER_OFFSET: Vector3 = Global.Y_OFFSET

# =============================================
# VARIABLES
var current_building: Node3D = null
@onready var camera := get_viewport().get_camera_3d()

func _ready():
	card1.pressed.connect(func(): start_placing(0))
	card2.pressed.connect(func(): start_placing(1))
	card3.pressed.connect(func(): start_placing(2))
	card4.pressed.connect(func(): start_placing(3))

func start_placing(index: int):
	if current_building:
		current_building.queue_free()

	current_building = BUILDINGS[index].instantiate()
	get_tree().current_scene.add_child(current_building)

	var pos = snap_to_hex_grid(get_mouse_world_position())
	current_building.global_transform.origin = pos + TOWER_OFFSET
	
	var random_angle = deg_to_rad(rng.randf_range(0, 360))
	current_building.rotate(Vector3(0, 1, 0), random_angle)

func _process(delta):
	if current_building:
		var pos = snap_to_hex_grid(get_mouse_world_position())
		current_building.global_transform.origin = pos + TOWER_OFFSET

func _unhandled_input(event):
	if current_building and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			current_building = null

# =============================================
func get_mouse_world_position() -> Vector3:
	var mouse_pos = get_viewport().get_mouse_position()
	var origin = camera.project_ray_origin(mouse_pos)
	var direction = camera.project_ray_normal(mouse_pos)

	var t = -origin.y / direction.y
	return origin + direction * t

func snap_to_hex_grid(world_pos: Vector3) -> Vector3:
	var size = TILE_SIZE * SPACING
	var half_shift = size / 2.0
	var cos30 = cos(deg_to_rad(30))

	var q = world_pos.x / (size * cos30)
	var iq = int(round(q))
	var r = (world_pos.z - (half_shift if iq % 2 != 0 else 0.0)) / size

	var rq = iq
	var rr = int(round(r))

	var snapped = Vector3.ZERO
	snapped.x = rq * size * cos30
	snapped.z = rr * size + (half_shift if rq % 2 != 0 else 0.0)
	return snapped
