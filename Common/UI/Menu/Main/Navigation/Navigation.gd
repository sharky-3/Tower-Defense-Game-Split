""" [[ ============================================================ ]] """
extends Control
""" [[ ============================================================ ]] """

""" [[ Constants / Exported Data ]] """
@export var background_ui_viewport: SubViewport
@export_range(0, 2, 1) 
var selected_idx: int = 0:
	set(new_selected_idx):
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
@onready var index: Label = $MenuInfo/MenuIndex
@onready var options: Array[HBoxContainer] = []
@onready var tooltip_ui: TooltipUI = $TooltipUI

""" [[ Stats ]] """

signal submenu_selected(index: int)

""" [[ ============================================================ ]] """
""" [[ LifeCycle ]] """

func _ready() -> void: 
	for child in $Options/SubViewport/Options.get_children():
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
	options[new_idx].select()
	
	index.text = "%d" % (new_idx + 1)
	tooltip_ui.title = tool_title[new_idx]
	tooltip_ui.sub_title = tool_sub_title[new_idx]

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
	
	if event.is_action_pressed("ui_down"):
		UISFX.play_move()
		select_next()
	
	elif event.is_action_pressed("ui_up"):
		UISFX.play_move()
		select_prev()
	
	elif event.is_action_pressed("ui_select"):
		UISFX.play_select()
		submenu_selected.emit(selected_idx)
