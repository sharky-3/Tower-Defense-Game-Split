""" [[ ============================================================ ]] """
extends Control
""" [[ ============================================================ ]] """

""" [[ Constants / Exported Data ]] """
@export var spacing: float = 350
@export var bottom_margin: float = 25

""" [[ Node references ]] """
@onready var hand: Control = $Hand

""" [[ ============================================================
	// FUNCTIONS
]] """

""" [[ ============================================================ ]] """
""" [[ Ready ]] """
func _ready() -> void:
	draw_card()

""" [[ ============================================================ ]] """
""" [[ Move Card ]] """
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
	
""" [[ ============================================================ ]] """
""" [[ Create Deck ]] """
func draw_card() -> void:
	var towers = Global.get_towers_stats()
	var i = 1
	
	for t in towers:
		for tower_name in t.keys():
			var tower_data = t[tower_name]
			
			var card_scene: PackedScene = load("res://Common/UI/Card/Card.tscn")
			var card_instance: Control = card_scene.instantiate()
			hand.add_child(card_instance)
			
			if card_instance.has_method("set_up_card"):
				var cost = tower_data.get("Cost", 0)
				
				var stats = tower_data.get("Stats", {})
				var damage = stats.get("Damage", 0)
				var range = stats.get("Range", 0)
				var attack_speed = stats.get("AttackSpeed", 0)
				var can_hit_multiple = stats.get("CanHitMultipleEnemies", false)
				
				card_instance.set_up_card(i, attack_speed, tower_name, cost)
			
			if card_instance.has_method("size") and card_instance.size:
				card_instance.pivot_offset = card_instance.size / 2.0
			card_instance.set_meta("original_parent", hand)
			i += 1
	await arrange_hand()

""" [[ Arrange Deck ]] """
func arrange_hand() -> void:
	var count: int = hand.get_child_count()
	
	if count == 0: return
	
	var card_size: Vector2 = hand.get_child(0).size
	var total_width: float = spacing * (count - 1)
	var start_x: float = -total_width / 2.0 - card_size.x / 2.0
	
	var bottom_y: float = get_viewport_rect().size.y - hand.global_position.y - card_size.y - bottom_margin
	
	var tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	
	for i in range(count):
		var card: Control = hand.get_child(i)
		
		var ratio := 0.5 if count == 1 else float(i) / (count - 1)
		
		var final_position := Vector2(
			start_x + i * spacing,
			bottom_y
		)
		
		var final_rotation := lerp_angle(-0.25, 0.25, ratio)
		
		card.in_hand_pos = final_position
		card.in_hand_rot = final_rotation
		
		tween.parallel().tween_property(card, "position", final_position, 0.25)
		tween.parallel().tween_property(card, "rotation", final_rotation, 0.25)
	
	await tween.finished
