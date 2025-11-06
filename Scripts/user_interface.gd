extends Control

# =============================================
# ONREADY
@onready var cannon_scene = preload("res://Scenes/Towers/cannon.tscn")
@onready var item_list: ItemList = $ItemList

# =============================================
# VARIABLES
var camera: Camera3D
var instance: Node3D
var placing: bool = false
var placement_range: float = 1000.0
var can_place: bool = false

var rotation_target_y: float = 0
var rotation_tween
var current_angle_z: float = 0
var mouse_timer: float = 0.0
var mouse_moved: bool = false
var can_angle: bool = false
const MOUSE_IDLE_RESET_TIME: float = .05
const MOUSE_IDLE_THRESHOLD: float = 0.01  

# =============================================
# READY
func _ready():
	camera = get_viewport().get_camera_3d()
	item_list.connect("item_selected", Callable(self, "_on_item_list_item_selected"))
	rotation_tween = create_tween()

# =============================================
# USER INPUT FOR PLACING
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click") or event.is_action_pressed("esc"):
		item_list.deselect_all()

		if event.is_action_pressed("left_click") and can_place and instance:
			if instance.has_method("placed"):
				instance.placed()
		elif instance:
			instance.queue_free()

		instance = null
		placing = false
		can_place = false

# =============================================
# PROCESS
func _process(_delta: float) -> void:
	if placing and instance:
		var mouse_pos = get_viewport().get_mouse_position()
		var ray_origin = camera.project_ray_origin(mouse_pos)
		var ray_end = ray_origin + camera.project_ray_normal(mouse_pos) * placement_range

		var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
		var collision = camera.get_world_3d().direct_space_state.intersect_ray(query)

		if collision.size() > 0:
			can_place = instance.check_placement()
			instance.transform.origin = collision.position


# =============================================
# INPUT
func _input(event: InputEvent) -> void:
	if placing:
		if event is InputEventMouseMotion: mouse_moved = true 
		else: mouse_moved = false

		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			placing = false

		if event is InputEventKey and event.is_action_pressed("rotate_instance"):
			if instance:
				rotation_target_y += 90
				if rotation_target_y >= 360:
					rotation_target_y = 0 

				if rotation_tween:
					rotation_tween.kill()

				rotation_tween = create_tween()
				rotation_tween.tween_property(
					instance,
					"rotation_degrees:y",
					rotation_target_y,
					0.3
				).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

# =============================================
# SELECT ITEM FROM USER INTERFACE
func _on_item_list_item_selected(index: int) -> void:
	if placing and instance:
		instance.queue_free()

	if index == 0 or index == 1:  
		instance = cannon_scene.instantiate() as Node3D
		rotation_target_y = instance.rotation_degrees.y
		placing = true
		get_parent().add_child(instance)
