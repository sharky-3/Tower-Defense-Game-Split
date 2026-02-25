extends Control

@onready var hand: Control = $Hand

func _ready() -> void:
	draw_card(5, null)

func move_card(card: Button, start_position: Vector2, target_position: Vector2, duration: float) -> void:
	card.position = start_position
	
	var tween: Tween = create_tween()
	tween.tween_property(
		card,
		"position",
		target_position,
		duration
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	await tween.finished

func arrange_hand() -> void:
	var offset: int = 700
	var final_position: Vector2
	var final_rotation: float

	var tween: Tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

	for card in hand.get_children():
		var hand_ratio: float = 0.5
		
		if hand.get_child_count() > 1:
			hand_ratio = float(card.get_index()) / (float(hand.get_child_count()) - 1.0)
			final_position = Vector2(hand_ratio * offset, 0)
			final_rotation = lerp_angle(-0.2, 0.2, hand_ratio)
		else:
			final_rotation = 0
			final_position = Vector2(50, 0)
		
		tween.parallel().tween_property(
			card, "position", final_position, 0.03 + (card.get_index() * 0.075)
		)
		tween.parallel().tween_property(
			card, "rotation", final_rotation, 0.2 + (card.get_index() * 0.075)
		)

	await tween.finished

func draw_card(amount: int, card_data) -> void:
	var spacing: float = 300
	var center_offset: float = (amount - 1) / 2.0
	var start_pos: Vector2 = Vector2(500, 0)
	
	for i in range(amount):
		var card_scene: Button = load("res://Common/UI/Card/Card.tscn").instantiate()
		hand.add_child(card_scene)
		
		card_scene.pivot_offset = card_scene.size / 2
		
		var target_x: float = (i - center_offset) * spacing - card_scene.size.x / 2
		var target_y: float = hand.get_size().y / 2  
		var target_pos: Vector2 = Vector2(target_x, target_y)
		
		#await move_card(card_scene, start_pos, target_pos, 0.5)

	await arrange_hand()
