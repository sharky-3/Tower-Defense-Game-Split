extends Control

# =============================================
# ONREADY
@onready var cannon_scene = preload("res://Scenes/Towers/cannon.tscn")
@onready var item_list: ItemList = $ItemList

# =============================================
# VARIABLES
var camera
var instance: Node3D
var placing: bool = false
var placement_range: float = 1000.0
var can_place = false

# =============================================
# READY
func _ready():
	camera = get_viewport().get_camera_3d()
	item_list.connect("item_selected", Callable(self, "_on_item_list_item_selected"))

# =============================================
# USER INPUT FOR PLACING
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click") or event.is_action_pressed("esc"):
		item_list.deselect_all()
		
		if event.is_action_pressed("left_click") and can_place:
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

		# Chance color material
		if collision.size() > 0:
			can_place = instance.check_placement()
			instance.transform.origin = collision.position

# =============================================
# INPUT
func _input(event):
	if placing and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		placing = false

# =============================================
# SELECT ITEM FROM USER INTERFACE
func _on_item_list_item_selected(index: int) -> void:
	if placing: instance.queue_free()
	if index == 0: instance = cannon_scene.instantiate() as Node3D
	elif index == 1: instance = cannon_scene.instantiate() as Node3D
	
	placing = true
	get_parent().add_child(instance)
