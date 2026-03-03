""" [[ ============================================================ ]] """
extends Node
class_name ItemPlacer
""" [[ ============================================================ ]] """

""" [[ Stats ]] """
var cursor_ray: CursorRay = null

var grid_size: float = 5
var camera: Camera3D = null

var itemScene: PackedScene = null
var itemPreview: Node3D = null
var currentScene = null

""" [[ ============================================================ ]] """
""" [[ Classes ]] """

class CursorRay:
	var camera: Camera3D = null
	var mouse_pos: Vector2 = Vector2.ZERO
	var ray_origin: Vector3 = Vector3.ZERO
	var ray_dir: Vector3 = Vector3.ZERO
	var ray_end: Vector3 = Vector3.ZERO

	func _init(cam: Camera3D):
		camera = cam
	
	func cursor_position():
		var mouse_pos: Vector2 = camera.get_viewport().get_mouse_position()
		var ray_origin: Vector3 = camera.project_ray_origin(mouse_pos)
		var ray_dir: Vector3 = camera.project_ray_normal(mouse_pos)
		var ray_end: Vector3 = ray_origin + ray_dir * 1000.0

		var space_state = camera.get_world_3d().direct_space_state

		var query = PhysicsRayQueryParameters3D.new()
		query.from = ray_origin
		query.to = ray_end
		query.collide_with_areas = true
		query.collide_with_bodies = true

		var result = space_state.intersect_ray(query)
		return result

""" [[ ============================================================ ]] """
""" [[ Functions ]] """

func _init(camera: Camera3D, scene: PackedScene, preview: Node3D, current) -> void:
	self.camera = camera
	self.itemScene = scene
	self.itemPreview = preview
	self.cursor_ray = CursorRay.new(camera)
	self.currentScene = current

func snap_to_grid(position: Vector3) -> Vector3:
	return Vector3(
		round(position.x / grid_size) * grid_size,
		position.y == 0,
		round(position.z / grid_size) * grid_size
	)

func item_preview_follow_mouse(preview: Node3D):
	if not self.itemPreview: self.itemPreview = preview
	
	var result = cursor_ray.cursor_position()
	if result.has("position"):
		self.itemPreview.global_position = snap_to_grid(result.position)

func place_item_on_ground():
	var hit_found: bool = false

	while true:
		var result = cursor_ray.cursor_position()
		if not result.has("collider"): break

		var hit_object = result["collider"]
		if hit_object.get_collision_layer() & (1 << 3): continue
		hit_found = true

		if hit_object.is_in_group("PlacingGrid") and itemPreview:
			if itemPreview.get_parent() == null: self.currentScene.add_child(itemPreview)

			if itemPreview.has_method("tower_placed") and itemPreview.has_method("can_tower_be_placed"):
				if itemPreview.can_tower_be_placed(): itemPreview.tower_placed()
				else: itemPreview.queue_free()
		else: 
			if itemPreview: itemPreview.queue_free()
			
		self.itemPreview = null; break
	return hit_found
