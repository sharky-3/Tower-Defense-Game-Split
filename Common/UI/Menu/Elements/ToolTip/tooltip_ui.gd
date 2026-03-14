@tool
extends Control
class_name TooltipUI

@onready var title_label: Label = $Title
@onready var sub_title_container: HBoxContainer = $SubTitleContainer
@onready var sub_title_label: Label = $SubTitleContainer/SubTitle

const MAX_WIDTH := 500

@export var title: String = "Title":
	set(v):
		title = v
		if is_node_ready():
			title_label.text = title
			title_label.autowrap_mode = TextServer.AUTOWRAP_WORD

			title_label.custom_minimum_size = Vector2(MAX_WIDTH, title_label.custom_minimum_size.y)
			title_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER

			_recalculate_titles_position()

@export var sub_title: String = "Sub":
	set(v):
		sub_title = v
		if is_node_ready():
			sub_title_label.text = sub_title
			
func _recalculate_titles_position() -> void:
	var title_height = title_label.get_minimum_size().y
	var sub_title_pos = sub_title_container.position
	title_label.position = sub_title_pos - Vector2(0, title_height)

func _ready() -> void:
	title = title
	sub_title = sub_title
