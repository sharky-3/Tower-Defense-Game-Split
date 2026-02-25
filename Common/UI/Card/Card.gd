""" [[ ============================================================ ]] """
extends Button
""" [[ ============================================================ ]] """

""" [[ ============================================================
	// VARIABLES
]] """

""" [[ Card ]] """
@onready var card_texture = $CardTexture

@onready var tower_name: Label = $Stats/Name
@onready var lvl_value: Label = $Stats/Lvl/lvl_value
@onready var timer_value: Label = $Stats/Timer/timer_value
@onready var gold_value: Label = $Stats/Gold/gold_value

""" [[ Fake 3D ]] """
@export var angle_x_max: float = 15
@export var angle_y_max: float = 15

""" [[ Card Movement ]] """
var state: int = 0
var offset: Vector2 = Vector2.ZERO
var in_hand_pos: Vector2
var in_hand_rot: float

""" [[ Tween ]] """
var tween_rot: Tween

""" [[ ============================================================
	// FUNCTIONS
]] """

""" [[ ============================================================ ]] """
""" [[ Ready ]] """
func _ready() -> void:
	pass

""" [[ Process ]] """
func _process(delta: float) -> void:
	if state == 1:
		var mouse_pos: Vector2 = get_global_mouse_position()
		position = mouse_pos - offset 
		
		Global.IS_DRAGGING_CARD = true
		rotation = 0
		if Input.is_action_just_released("left_click"): 
			Global.IS_DRAGGING_CARD = false
			state = 0
			position = in_hand_pos
			rotation = in_hand_rot

""" [[ ============================================================ ]] """
""" [[ Card Interaction ]] """
func _on_gui_input(event: InputEvent) -> void:
	if state == 1: return
	if event.is_action_pressed("left_click"):
		state = 1
		offset = get_global_mouse_position() - position
		z_index = 10
	
	if not event is InputEventMouseMotion: return
	
	var mouse_pos: Vector2 = get_local_mouse_position()
	var diff: Vector2 = (position + size) - mouse_pos

	var lerp_val_x: float = remap(mouse_pos.x, 0.0, size.x, 0, 1)
	var lerp_val_y: float = remap(mouse_pos.y, 0.0, size.y, 0, 1)

	var rot_x: float = lerp(-angle_x_max, angle_x_max, lerp_val_x)
	var rot_y: float = lerp(angle_y_max, -angle_y_max, lerp_val_y)
	
	card_texture.material.set_shader_parameter("x_rot", rot_y)
	card_texture.material.set_shader_parameter("y_rot", rot_x)

""" [[ Mouse Entered ]] """
func _on_mouse_entered() -> void:
	card_is_focused(true)

""" [[ Mouse Left ]] """
func _on_mouse_exited() -> void:
	card_is_focused(false)
	
	if tween_rot and tween_rot.is_running(): tween_rot.kill()
	tween_rot = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel(true)
	tween_rot.tween_property(card_texture.material, "shader_parameter/x_rot", 0.0, 0.5)
	tween_rot.tween_property(card_texture.material, "shader_parameter/y_rot", 0.0, 0.5)

""" [[ ============================================================ ]] """
""" [[ Focus ]] """
func card_is_focused(value: bool):
	if Global.IS_DRAGGING_CARD: 
		return
	if value: 
		z_index = 10
		await tween_anim(0)
	else: 
		z_index = 0
		await tween_anim(1)

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
""" [[ Tween ]] """
func tween_anim(type: int):
	var tween: Tween = create_tween()
	match type:
		0:
			tween.tween_property(
				self, "scale", Vector2(1.2, 1.2), 0.4
			).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		1:
			tween.tween_property(
				self, "scale", Vector2.ONE, 0.55
			).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	await tween.finished
