""" [[ ============================================================ ]] """
extends Control
""" [[ ============================================================ ]] """

""" [[ Exported Data ]] """
@export var selected_idx: int = 0:
	set(value):
		if value == selected_idx:
			return
		handle_selection_update(selected_idx, value)
		selected_idx = value


""" [[ Node references ]] """
@onready var cursor: Node2D = $Main/SubViewport/Items/TriangleCursor
@onready var index: Label = $Main/SubViewport/Items/Info/MenuIndex

@onready var options: Array[UiMainMenuOption] = [
	$Main/SubViewport/Items/Options/Skill,
	$Main/SubViewport/Items/Options/Item,
]

@onready var background_ui_viewport: SubViewport = $Main/SubViewport


""" [[ Stats ]] """
var menu_opened: bool = false

signal submenu_selected(index: int)


""" [[ ============================================================ ]] """
""" [[ LifeCycle ]] """

func _ready() -> void:
	if options.size() == 0:
		return
	
	selected_idx = clamp(selected_idx, 0, options.size() - 1)
	options[selected_idx].select()
	move_cursor(options[selected_idx])


""" [[ ============================================================ ]] """
""" [[ Input ]] """

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


""" [[ ============================================================ ]] """
""" [[ Menu Logic ]] """

func open() -> void:
	show()
	move_cursor(options[selected_idx])


func open_first_time() -> void:
	selected_idx = 0
	show()
	open_options()


func close() -> void:
	for option in options:
		option.hide()
	cursor.hide()


""" [[ ============================================================ ]] """
""" [[ Selection ]] """

func select_next() -> void:
	if options.size() == 0:
		return
	
	selected_idx = (selected_idx + 1) % options.size()


func select_prev() -> void:
	if options.size() == 0:
		return
	
	selected_idx = (selected_idx - 1 + options.size()) % options.size()


func handle_selection_update(prev_idx: int, new_idx: int) -> void:
	if prev_idx >= 0 and prev_idx < options.size():
		options[prev_idx].unselect()

	if new_idx >= 0 and new_idx < options.size():
		options[new_idx].select()
		move_cursor(options[new_idx])

	index.text = "%d" % (new_idx + 1)


""" [[ ============================================================ ]] """
""" [[ Cursor ]] """

func move_cursor(option: Control) -> void:
	cursor.attach_to_option(option)


""" [[ ============================================================ ]] """
""" [[ Animations ]] """

func open_options() -> void:
	var tween := get_tree().create_tween()

	for i in range(options.size()):
		var option := options[i]
		var delay := (options.size() - 1 - i) / 30.0
		tween.parallel().tween_callback(option.spawn).set_delay(delay)
