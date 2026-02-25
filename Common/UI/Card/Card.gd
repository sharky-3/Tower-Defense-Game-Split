extends Button

var state: int = 0
var offset: Vector2 = Vector2.ZERO
var in_hand_pos: Vector2
var in_hand_rot: float

func _process(delta: float) -> void:
	if state == 1:
		var mouse_pos: Vector2 = get_global_mouse_position()
		position = mouse_pos - offset 
		
		Global.IS_DRAGGING_CARD = true
		rotation = 0
		if Input.is_action_just_released("left_click"): 
			state = 0
			Global.IS_DRAGGING_CARD = false
			position = in_hand_pos
			rotation = in_hand_rot

func _on_gui_input(event: InputEvent) -> void:
	if state == 1: 
		return
	if event.is_action_pressed("left_click"):
		state = 1
		offset = get_global_mouse_position() - position
		z_index = 10

func card_is_focused(value: bool):
	if Global.IS_DRAGGING_CARD: 
		return
	if value: 
		z_index = 10
		await tween_anim(0)
	else: 
		z_index = 0
		await tween_anim(1)
	
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

func _on_mouse_entered() -> void:
	card_is_focused(true)

func _on_mouse_exited() -> void:
	card_is_focused(false)
