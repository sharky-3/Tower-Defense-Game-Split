""" [[ ============================================================ ]] """
extends Control
""" [[ ============================================================ ]] """

""" [[ Classes ]] """
var game_settings = GameSettings.new()

""" [[ Constants / Exported Data ]] """
@export_range(FIRST_SELECTION_IDX, LAST_SELECTION_IDX, 1) var selected_idx: int = 0 :
	set(new_selected_idx):
		handle_selection_update(selected_idx, new_selected_idx)
		selected_idx = new_selected_idx

""" [[ Node references ]] """
@onready var options: Array[HBoxContainer] = []
@onready var player: Node3D = $"../../../../../../World/SubViewport/Player"
@onready var tooltip_ui: TooltipUI = $TooltipUI

""" [[ Stats ]] """
const FIRST_SELECTION_IDX: int = 0
const LAST_SELECTION_IDX: int = 2
var slider_text: Label

""" [[ ============================================================ ]] """
""" [[ LifeCycle ]] """

func _ready() -> void:
	for child in $Items.get_children():
		if child is HBoxContainer: options.append(child)
	options[selected_idx].select()

""" [[ ============================================================ ]] """
""" [[ Functions ]] """

func open() -> void: 
	show()

func open_first_time() -> void:
	selected_idx = 0
	show()
	open_options()

func select_prev() -> void:
	selected_idx = LAST_SELECTION_IDX if selected_idx <= FIRST_SELECTION_IDX else selected_idx - 1

func select_next() -> void:
	selected_idx = FIRST_SELECTION_IDX if selected_idx >= LAST_SELECTION_IDX else selected_idx + 1

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
		
	if event.is_action_pressed("ui_down"):
		UISFX.play_move()
		select_next()
	
	elif event.is_action_pressed("ui_up"):
		UISFX.play_move()
		select_prev()
	
	elif event.is_action_pressed("ui_select"):
		UISFX.play_select()
		
		var player_camera: Camera3D = player.get_player_camera()
		var new_value = game_settings.update_game_settings(selected_idx, player_camera)
		var selected_option: HBoxContainer = options[selected_idx]
		var segment_control: HBoxContainer = selected_option.get_node("Segment Control")
		var text: Label = segment_control.get_node_or_null("Text")
		var slider: HSlider = segment_control.get_node_or_null("Slider")
		
		if slider: 
			slider.value = new_value
			self.slider_text = text
			
		if text:
			if typeof(new_value) == TYPE_VECTOR2I: text.text = str(new_value.x) + "x" + str(new_value.y)
			else: text.text = str(new_value)

func _on_slider_value_changed(value: float) -> void:
	if self.slider_text: self.slider_text.text = str(int(value))
	
