""" [[ ============================================================ ]] """
extends Control
""" [[ ============================================================ ]] """

""" [[ Constants / Exported Data ]] """
@export var target_frame_time := 3. / 60.
@export var game_viewport: SubViewport

""" [[ Node references ]] """
@onready var main_menu_pause_ui: Control = $MainMenu/SubViewport/MainMenuPauseUI
@onready var blot_transition: ColorRect = $MainMenu/SubViewport/BlotTransition

@onready var main_menu_sub_viewport_container: SubViewportContainer = $MainMenu
@onready var item_menu_sub_viewport_container: SubViewportContainer = $ItemMenu

@onready var player: Node3D = $"../../../World/SubViewport/Player"
@onready var spectating: Camera3D = $"../../../World/SubViewport/SpectatingCamera/Camera"

@onready var sub_menu_sub_viewport_containers: Array[Control] = [
	$ItemMenu,
	$ItemMenu,
	$ItemMenu,
	$ItemMenu,
]

@onready var sub_menus: Array[Control] = [
	$ItemMenu/SubViewport/Editor, 
	$ItemMenu/SubViewport/Settings, 
	$ItemMenu/SubViewport/Progression, 
	$ItemMenu/SubViewport/Settings, 
]

""" [[ Stats ]] """
var menu_transition_tween: Tween
var in_main_menu: bool = false

""" [[ ============================================================ ]] """
""" [[ LifeCycle ]] """

func _ready() -> void: reset()

""" [[ ============================================================ ]] """
""" [[ Functions ]] """

func reset() -> void:
	hide()
	
	main_menu_pause_ui.set_process(false)
	main_menu_pause_ui.set_process_input(false)
	
	for menu in sub_menus:
		menu.set_process(false)
		menu.set_process_input(false)
		
	main_menu_sub_viewport_container.hide()
	for container in sub_menu_sub_viewport_containers: 
		container.hide()

func switch_player_camera():
	if player.has_method("is_current_camera") and player.has_method("make_current_camera"):
		var is_current: bool = player.is_current_camera()
		if is_current: spectating.make_current()
		else: player.make_current_camera()

func open() -> void:
	show()
	#var subviewport = $"../../../World/SubViewport"
	#subviewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	open_main_menu_first_time()
	UISFX.play_open_pause()
	switch_player_camera()

func close() -> void:
	UISFX.play_cancel()
	#var subviewport = $"../../../World/SubViewport"
	#subviewport.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE
	close_main_menu()
	switch_player_camera()

func open_main_menu() -> void:
	main_menu_pause_ui.set_process(true)
	main_menu_pause_ui.set_process_input(true)
	
	main_menu_pause_ui.open()
	main_menu_sub_viewport_container.show()
	
	in_main_menu = true

func open_main_menu_first_time() -> void:
	main_menu_pause_ui.set_process(true)
	main_menu_pause_ui.set_process_input(true)
	
	main_menu_pause_ui.open_first_time()
	main_menu_sub_viewport_container.show()
	
	in_main_menu = true

func open_sub_menu(sub_menu: Control) -> void:
	sub_menu.show()
	sub_menu.set_process(true)
	sub_menu.set_process_input(true)
	sub_menu.open_first_time()
	
	main_menu_pause_ui.set_process(false)
	main_menu_pause_ui.set_process_input(false)
	
	in_main_menu = false

func close_main_menu() -> void:
	main_menu_pause_ui.close()
	
	main_menu_pause_ui.set_process(false)
	main_menu_pause_ui.set_process_input(false)
	
	in_main_menu = false

func sub_menu_transition_open(sub_menu_sub_viewport_container: SubViewportContainer) -> void:
	if menu_transition_tween: menu_transition_tween.kill()
	menu_transition_tween = create_tween()
	
	sub_menu_sub_viewport_container.show()
	sub_menu_transition_progress(0.0, sub_menu_sub_viewport_container)
	
	menu_transition_tween.tween_method(
		blot_transition_progress, 0.1, 1.0, 0.3)
	menu_transition_tween.parallel().tween_method(
		sub_menu_transition_progress.bind(sub_menu_sub_viewport_container
	), 0.0, 1.0, 0.2).set_delay(0.15)
	menu_transition_tween.chain().tween_callback(main_menu_sub_viewport_container.hide)

func sub_menu_transition_close(sub_menu_sub_viewport_container: SubViewportContainer) -> void:
	if menu_transition_tween: menu_transition_tween.kill()
	menu_transition_tween = create_tween()
	
	main_menu_sub_viewport_container.z_index = 10
	main_menu_sub_viewport_container.show()
	blot_transition_progress(0.0)
	
	menu_transition_tween.tween_method(main_menu_transition_progress, 0.1, 1.0, 0.3)
	menu_transition_tween.chain().tween_callback(sub_menu_sub_viewport_container.hide)
	menu_transition_tween.chain().tween_callback(func(): main_menu_sub_viewport_container.z_index = 0)

func close_sub_menu(sub_menu: Control) -> void:
	sub_menu.hide()
	sub_menu.set_process(false)
	sub_menu.set_process_input(false)
	
	main_menu_pause_ui.set_process(true)
	main_menu_pause_ui.set_process_input(true)
	
	in_main_menu = true

func sub_menu_transition_progress(progress: float, sub_menu: SubViewportContainer) -> void:
	sub_menu.material.set_shader_parameter("progress", progress)

func blot_transition_progress(progress: float) -> void:
	blot_transition.material.set_shader_parameter("progress", progress)

func main_menu_transition_progress(progress: float) -> void:
	main_menu_sub_viewport_container.material.set_shader_parameter("progress", progress)

""" [[ ============================================================ ]] """
""" [[ Events ]] """

func _on_main_menu_pause_ui_submenu_selected(index: int) -> void:
	open_sub_menu(sub_menus[index])
	sub_menu_transition_open(sub_menu_sub_viewport_containers[index])
