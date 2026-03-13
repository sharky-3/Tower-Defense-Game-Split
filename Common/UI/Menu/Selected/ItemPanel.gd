""" [[ ============================================================ ]] """
@tool
extends HBoxContainer
class_name UiSelectedItem
""" [[ ============================================================ ]] """

""" [[ Resources ]] """
const UI_TEXT_RIPPLES = preload("uid://dubel6ylnu5lm")

""" [[ Constants / Exported Data ]] """
@export var base_color: Color = Color.WHITE :
	set(v):
		base_color = v

@export_category("Selected Index")
@export var hovered_color: Color = Color("dab227")

@export_category("Scale Effects")
@export var use_item_scale_effect: bool = false
@export var use_text_scale_effect: bool = true

@export var scale_up_text: float = 1.2
@export var duration: float = 0.1

enum ScaleDirection { CENTER, LEFT, RIGHT }
@export var scale_direction: ScaleDirection = ScaleDirection.CENTER

""" [[ Node references ]] """
@onready var title: Label = get_node("Title")

""" [[ Stats ]] """
var saved_item_scale := Vector2.ONE
var saved_text_scale := Vector2.ONE
var saved_default_z_index := 0

var tween_when_selected: Tween
var spawning_tween: Tween

""" [[ ============================================================ ]] """
""" [[ LifeCycle ]] """

func _ready() -> void:
	update_pivot()

	if not Engine.is_editor_hint():
		hide()

func update_pivot() -> void:
	var item_size = size
	var text_size = title.size
	
	match scale_direction:
		ScaleDirection.CENTER:
			pivot_offset = item_size * 0.5
			title.pivot_offset = text_size * 0.5
		
		ScaleDirection.LEFT:
			pivot_offset = Vector2(0, item_size.y * 0.5)
			title.pivot_offset = Vector2(0, text_size.y * 0.5)
		
		ScaleDirection.RIGHT:
			pivot_offset = Vector2(item_size.x, item_size.y * 0.5)
			title.pivot_offset = Vector2(text_size.x, text_size.y * 0.5)

""" [[ ============================================================ ]] """
""" [[ Functions ]] """

func spawn() -> void:
	show()
	
	var saved_position := position
	var transparent_color := base_color
	transparent_color.a = 0.0
	
	set_font_collor(transparent_color)
	position += Vector2.UP * 50.0
	
	if tween_when_selected: tween_when_selected.kill()
		
	tween_when_selected = create_tween()
	tween_when_selected.tween_method(set_font_collor, transparent_color, base_color, 0.4)
	
	if spawning_tween: spawning_tween.kill()
		
	spawning_tween = create_tween()
	spawning_tween.tween_property(self, "position", saved_position, 0.4)

func select() -> void:
	if tween_when_selected: tween_when_selected.kill()
	
	saved_default_z_index = z_index
	saved_item_scale = scale
	saved_text_scale = title.scale
	
	tween_when_selected = create_tween()
	tween_when_selected.set_trans(Tween.TRANS_BACK)
	
	z_index = 1
	
	if use_item_scale_effect:
		tween_when_selected.tween_property(self, "scale", scale * scale_up_text, duration)
	
	if use_text_scale_effect:
		tween_when_selected.tween_property(title, "scale", title.scale * scale_up_text, duration)
	
	set_font_collor(hovered_color)
	material = null

func unselect() -> void:
	if tween_when_selected: tween_when_selected.kill()
	
	if use_item_scale_effect: scale = saved_item_scale
	if use_text_scale_effect: title.scale = saved_text_scale
	z_index = saved_default_z_index
	
	set_font_collor(base_color)
	material = UI_TEXT_RIPPLES

func set_font_collor(color: Color) -> void:
	title.add_theme_color_override("font_color", color)
