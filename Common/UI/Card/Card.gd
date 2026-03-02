""" [[ ============================================================ ]] """
extends Button
""" [[ ============================================================ ]] """

""" [[ Constants / Exported Data ]] """
@export var drag_opacity: float = 0.5

@export var angle_x_max: float = 15
@export var angle_y_max: float = 15
@export var max_offset_shadow: float = 50.0

@export var spring: float = 150.0
@export var damp: float = 10.0
@export var velocity_multiplier: float = 2.0

""" [[ Node references ]] """
@onready var card_texture = $CardTexture
@onready var shadow: TextureRect = $Shadow
@onready var collision_shape: CollisionShape2D = $DestroyArea/CollisionShape2D

@onready var tower_name: Label = $Stats/Name
@onready var lvl_value: Label = $Stats/Lvl/lvl_value
@onready var timer_value: Label = $Stats/Timer/timer_value
@onready var gold_value: Label = $Stats/Gold/gold_value

""" [[ Stats ]] """
var state: int = 0
var offset: Vector2 = Vector2.ZERO
var in_hand_pos: Vector2
var in_hand_rot: float

var tween_rot: Tween
var drag_tween: Tween 
var tween_hover: Tween
var tween_destroy: Tween
var tween_handle: Tween

var displacement: float = 0.0
var oscillator_velocity: float = 0.0

var last_mouse_pos: Vector2
var mouse_velocity: Vector2
var following_mouse: bool = false
var last_pos: Vector2
var velocity: Vector2

var original_position: Vector2

""" [[ ============================================================
	// FUNCTIONS
]] """

""" [[ ============================================================ ]] """
""" [[ Ready ]] """
func _ready() -> void:
	angle_x_max = deg_to_rad(angle_x_max)
	angle_y_max = deg_to_rad(angle_y_max)
	collision_shape.set_deferred("disabled", true)


""" [[ Process ]] """
func _process(delta: float) -> void:
	rotate_velocity(delta)
	handle_shadow(delta)
	follow_mouse(delta)
	#pick_up_card()

""" [[ ============================================================ ]] """
""" [[ Place ]] """
func spawn_cube_at_mouse():
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera == null: return

	var mouse_pos: Vector2 = get_viewport().get_mouse_position()

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

	if result.has("position"):
		var cube = MeshInstance3D.new()
		cube.mesh = BoxMesh.new()
		get_tree().current_scene.add_child(cube)
		cube.global_position = result.position
			
""" [[ ============================================================ ]] """
""" [[ Pick up ]] """
func pick_up_card():
	if state == 1:
		var mouse_pos: Vector2 = get_global_mouse_position()
		position = mouse_pos - offset 
		
		Global.IS_DRAGGING_CARD = true
		rotation = 0
		if Input.is_action_just_released("left_click"): 
			Global.IS_DRAGGING_CARD = false
			
			set_drag_visuals(false)
			spawn_cube_at_mouse()
			
			state = 0
			position = in_hand_pos
			rotation = in_hand_rot

""" [[ Rotate ]] """
func rotate_velocity(delta: float) -> void:
	if not following_mouse: return
	var center_pos: Vector2 = global_position - (size/2)
	velocity = (position - last_pos) / delta
	last_pos = position
	
	oscillator_velocity += velocity.normalized().x * velocity_multiplier
	
	var force = -spring * displacement - damp * oscillator_velocity
	oscillator_velocity += force * delta
	displacement += oscillator_velocity * delta
	
	rotation = displacement

""" [[ Shadow ]] """	
func handle_shadow(delta: float) -> void:
	var center: Vector2 = get_viewport_rect().size / 2.0
	var distance: float = global_position.x - center.x
	shadow.position.x = lerp(0.0, -sign(distance) * max_offset_shadow, abs(distance/(center.x)))

""" [[ Drag ]] """
func set_drag_visuals(is_dragging: bool) -> void:
	if drag_tween and drag_tween.is_running(): drag_tween.kill()
	drag_tween = create_tween().set_parallel(true)

	var target_alpha = drag_opacity if is_dragging else 1.0
	var target_scale = Vector2(0.8, 0.8) if is_dragging else Vector2.ONE

	drag_tween.tween_property(self, "scale", target_scale, 0.15)
	drag_tween.tween_property(self, "modulate:a", target_alpha, 0.15)
	drag_tween.tween_property(card_texture, "modulate:a", target_alpha, 0.15)

""" [[ Fallow Mouse ]] """
func follow_mouse(delta: float) -> void:
	if not following_mouse: return
	var mouse_pos: Vector2 = get_global_mouse_position()
	global_position = mouse_pos - (size/2.0)

""" [[ Handle Mouse Click ]] """
func handle_mouse_click(event: InputEvent) -> void:
	if not event is InputEventMouseButton: return
	if event.button_index != MOUSE_BUTTON_LEFT: return
	
	if event.is_pressed():
		# Start dragging
		original_position = global_position
		following_mouse = true
		offset = get_global_mouse_position() - global_position
		
		# Enable drag visuals
		set_drag_visuals(true)
		
		# Reset wiggle
		last_pos = global_position
		displacement = 0.0
		oscillator_velocity = 0.0
	else:
		# Mouse released
		Global.IS_DRAGGING_CARD = false
		set_drag_visuals(false)
		following_mouse = false
		
		# Spawn cube if released over world
		var cube_spawned = spawn_cube_at_mouse()
		
		# Tween card back to hand if not placed
		if tween_handle and tween_handle.is_running():
			tween_handle.kill()
		tween_handle = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		if cube_spawned:
			# Reset wiggle but keep in hand position
			tween_handle.tween_property(self, "position", in_hand_pos, 0.3)
			tween_handle.tween_property(self, "rotation", in_hand_rot, 0.3)
		else:
			# Return to original hand slot
			tween_handle.tween_property(self, "position", in_hand_pos, 0.3)
			tween_handle.tween_property(self, "rotation", in_hand_rot, 0.3)
		
		# Reset wiggle values
		displacement = 0.0
		oscillator_velocity = 0.0

""" [[ Card Interaction ]] """
func _on_gui_input(event: InputEvent) -> void:
	handle_mouse_click(event)
	if following_mouse: return
	if not event is InputEventMouseMotion: return
	
	var mouse_pos: Vector2 = get_local_mouse_position()
	var diff: Vector2 = (position + size) - mouse_pos

	var lerp_val_x: float = remap(mouse_pos.x, 0.0, size.x, 0, 1)
	var lerp_val_y: float = remap(mouse_pos.y, 0.0, size.y, 0, 1)

	var rot_x: float = rad_to_deg(lerp_angle(-angle_x_max, angle_x_max, lerp_val_x))
	var rot_y: float = rad_to_deg(lerp_angle(angle_y_max, -angle_y_max, lerp_val_y))
	
	card_texture.material.set_shader_parameter("x_rot", rot_y)
	card_texture.material.set_shader_parameter("y_rot", rot_x)

""" [[ Mouse Entered ]] """
func _on_mouse_entered() -> void:
	if tween_hover and tween_hover.is_running():
		tween_hover.kill()
	tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_hover.tween_property(self, "scale", Vector2(1.2, 1.2), 0.5)
	#card_is_focused(true)

""" [[ Mouse Left ]] """
func _on_mouse_exited() -> void:
	if tween_rot and tween_rot.is_running():
		tween_rot.kill()
	tween_rot = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel(true)
	tween_rot.tween_property(card_texture.material, "shader_parameter/x_rot", 0.0, 0.5)
	tween_rot.tween_property(card_texture.material, "shader_parameter/y_rot", 0.0, 0.5)
	
	if tween_hover and tween_hover.is_running():
		tween_hover.kill()
	tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_hover.tween_property(self, "scale", Vector2.ONE, 0.55)

	#card_is_focused(false)
	#
	#if tween_rot and tween_rot.is_running(): tween_rot.kill()
	#tween_rot = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel(true)
	#tween_rot.tween_property(card_texture.material, "shader_parameter/x_rot", 0.0, 0.5)
	#tween_rot.tween_property(card_texture.material, "shader_parameter/y_rot", 0.0, 0.5)

""" [[ ============================================================ ]] """
""" [[ Focus ]] """
func card_is_focused(value: bool):
	if Global.IS_DRAGGING_CARD or state == 1:  return
	if value:  z_index = 10
	else: z_index = 0

""" [[ ============================================================ ]] """
""" [[ Set Up Card ]] """
func set_up_card(
	lvl: int = 1, 
	timer: float = 1.5,
	towerName: String = "Name",
	gold: int = 100
):
	tower_name.text = towerName
	lvl_value.text = str(lvl)
	timer_value.text = str(timer)
	gold_value.text = "$%d" % gold
	
""" [[ ============================================================ ]] """
""" [[ Interaction ]] """
func on_card_clicked(name: String) -> void:
	print("Clicked: ", name)
