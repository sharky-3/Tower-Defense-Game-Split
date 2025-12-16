extends Node2D

@onready var button: Button = $Button

func _ready() -> void:
	var viewport_size = get_viewport_rect().size
	global_position = viewport_size * 0.5

func _on_left_pressed() -> void:
	$CarouseContainer.move_left()

func _on_right_pressed() -> void:
	$CarouseContainer.move_right()
