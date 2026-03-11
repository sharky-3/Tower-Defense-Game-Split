""" [[ ============================================================ ]] """
extends Control
""" [[ ============================================================ ]] """

""" [[ Constants / Exported Data ]] """
@export_range(FIRST_SELECTION_IDX, LAST_SELECTION_IDX, 1) var selected_idx: int = 0 :
	set(new_selected_idx):
		handle_selection_update(selected_idx, new_selected_idx)
		selected_idx = new_selected_idx

""" [[ Node references ]] """
@onready var options: Array[HBoxContainer] = []

""" [[ Stats ]] """
const FIRST_SELECTION_IDX: int = 0
const LAST_SELECTION_IDX: int = 3

signal submenu_selected(index: int)

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
		print(selected_idx)
		submenu_selected.emit(selected_idx)
