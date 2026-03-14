""" [[ ============================================================ ]] """
extends Control
""" [[ ============================================================ ]] """

""" [[ Classes ]] """
var game_settings = GameSettings.new()
var game_editor = GameEditor.new()

""" [[ Constants / Exported Data ]] """
@export_enum("Normal", "Menu", "Settings", "Editor") var menu_type: String = "Normal"
@export_range(0, 2, 1) 
var selected_idx: int = 0:
	
	set(new_selected_idx):
		if options.is_empty():
			selected_idx = new_selected_idx
			return
			
		handle_selection_update(selected_idx, new_selected_idx)
		selected_idx = new_selected_idx
		
@export var FIRST_SELECTION_IDX: int = 0
@export var LAST_SELECTION_IDX: int = 2

@export_category("Tool Tip")
@export var tool_title: Array[String] = [
	"Toggle between windowed and fullscreen modes for your game.",
	"Set the width and height of the game window to your preference.",
	"Adjust the camera's field of view to see more or less of the world."
]
@export var tool_sub_title: Array[String] = [
	"Window Mode",
	"Screen Size",
	"Camera FOV",
]

""" [[ Node references ]] """
@onready var options: Array[HBoxContainer] = []
@onready var tooltip_ui: TooltipUI = $TooltipUI
@onready var sub_viewport: SubViewport = $"../../../../../../World/SubViewport"

""" [[ Stats ]] """
var slider_text: Label
signal submenu_selected(index: int)

""" [[ ============================================================ ]] """
""" [[ LifeCycle ]] """

func _ready() -> void:
	for child in $Items.get_children():
		if child is HBoxContainer:
			options.append(child)

	selected_idx = 0
	options[selected_idx].select()

""" [[ ============================================================ ]] """
""" [[ Set Ups ]] """

func set_up_values() -> void:
	for child in options:
		var child_name: String = child.name
		var value: Label = child.get_node("Value")
		if child_name == "Win_Rate": value.text = str(Global.get_looking_value(child_name)) + "%"
		else: value.text = str(Global.get_looking_value(child_name))
	
""" [[ ============================================================ ]] """
""" [[ Functions ]] """

func open() -> void: 
	show()

func open_first_time() -> void:
	if self.name == "PlayerStats":
		set_up_values()
		
	selected_idx = 0
	show()
	open_options()

func select_prev() -> void:
	selected_idx = LAST_SELECTION_IDX if selected_idx <= FIRST_SELECTION_IDX else selected_idx - 1

func select_next() -> void:
	selected_idx = FIRST_SELECTION_IDX if selected_idx >= LAST_SELECTION_IDX else selected_idx + 1

func handle_selection_update(prev_idx: int, new_idx: int) -> void:
	options[prev_idx].unselect()
	
	tooltip_ui.title = tool_title[new_idx]
	tooltip_ui.sub_title = tool_sub_title[new_idx]
	
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
		
		match menu_type:
			"Normal": 
				print("")
				
			"Menu":
				if self.visible:
					submenu_selected.emit(selected_idx + 6)
					self.visible = false
				
			"Editor":
				var new_value = game_editor.update_game_editor(selected_idx, sub_viewport)
				
				var selected_option: HBoxContainer = options[selected_idx]
				var segment_control: HBoxContainer = selected_option.get_node("Segment Control")
				var text: Label = segment_control.get_node_or_null("Text")
				var slider: HSlider = segment_control.get_node_or_null("Slider")
				
				if slider: 
					if str(new_value) == "INF": slider.value = 105
					else: slider.value = new_value
					self.slider_text = text
						
				if text:
					if typeof(new_value) == TYPE_VECTOR2I: text.text = str(new_value.x) + "x" + str(new_value.y)
					else: text.text = str(new_value)
				
			"Settings":
				var player: Node3D = get_node_or_null("../../../../../../World/SubViewport/Player")
				if player: 
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
