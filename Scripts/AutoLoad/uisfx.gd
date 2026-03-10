""" [[ ============================================================ ]] """
extends Node
""" [[ ============================================================ ]] """

""" [[ Node references ]] """
#@onready var select: AudioStreamPlayer = $Select
#@onready var move: AudioStreamPlayer = $Move
#@onready var cancel: AudioStreamPlayer = $Cancel
#@onready var open_menu: AudioStreamPlayer = $OpenMenu

""" [[ ============================================================ ]] """
""" [[ Functions ]] """

func play_select() -> void: pass
func play_move() -> void: pass
func play_cancel() -> void: pass
func play_open_pause() -> void: pass
