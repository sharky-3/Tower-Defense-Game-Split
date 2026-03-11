""" [[ ============================================================ ]] """
extends Control
""" [[ ============================================================ ]] """

""" [[ Constants / Exported Data ]] """
@export var background_ui_viewport: SubViewport
@export_range(FIRST_SELECTION_IDX, LAST_SELECTION_IDX, 1) var selected_idx: int = 0 :
	set(new_selected_idx):
		handle_selection_update(selected_idx, new_selected_idx)
		selected_idx = new_selected_idx

""" [[ Node references ]] """
@onready var cursor: UiMainMenuCursor = $TriangleCursor
@onready var index: Label = $MenuInfo/MenuIndex
@onready var options: Array[HBoxContainer] = []
@onready var tooltip_ui: TooltipUI = $TooltipUI

""" [[ Stats ]] """
const FIRST_SELECTION_IDX = 0
const LAST_SELECTION_IDX = 3

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
	move_cursor(options[selected_idx])

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
	tooltip_ui.title = [
		"Play Game",
		"Game Settings",
		"Player Stats & Tower Upgrades",
		"Quit",
	][new_idx]
	move_cursor(options[new_idx])

func move_cursor(option: Control) -> void:
	cursor.attach_to_option(option)

func open_options() -> void:
	var tween := get_tree().create_tween()
	
	for i in options.size():
		var option := options[i]
		var delay := (options.size() - 1 - i) / 30.
		tween.parallel().tween_callback(option.spawn).set_delay(delay)

func close() -> void:
	for option in options: option.hide()
	cursor.hide()

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
