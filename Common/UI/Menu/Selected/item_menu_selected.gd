extends Control

@onready var options: Array[HBoxContainer] = []
@onready var tooltip_ui: TooltipUI = $TooltipUI

""" [[ ============================================================ ]] """
""" [[ LifeCycle ]] """

func _ready() -> void:
	for child in $Items.get_children():
		if child is HBoxContainer: options.append(child)

""" [[ ============================================================ ]] """
""" [[ Functions ]] """

func open() -> void: 
	show()

func open_first_time() -> void:
	show()
	open_options()

func handle_selection_update(prev_idx: int, new_idx: int) -> void:
	options[prev_idx].unselect()
	
	tooltip_ui.title = [
		"Toggle between windowed and fullscreen modes for your game.",
		"Set the width and height of the game window to your preference.",
		"Adjust the camera's field of view to see more or less of the world.",
	][new_idx]

	tooltip_ui.sub_title = [
		"Window Mode",
		"Screen Size",
		"Camera FOV",
	][new_idx]
	options[new_idx].select()

func open_options() -> void:
	var tween := get_tree().create_tween()
	
	for i in options.size():
		var option := options[i]
		var delay := (options.size() - 1 - i) / 30.
		tween.parallel().tween_callback(option.spawn).set_delay(delay)

func close() -> void: 
	for option in options: option.hide()

""" [[ ============================================================ ]] """
""" [[ Events ]] """

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		UISFX.play_cancel()
		$"../../..".close_sub_menu(self)
		$"../../..".sub_menu_transition_close($"../..")
