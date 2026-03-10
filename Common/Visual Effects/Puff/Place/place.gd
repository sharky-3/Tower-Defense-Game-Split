""" [[ ============================================================ ]] """
extends Node3D
""" [[ ============================================================ ]] """

""" [[ Node references ]] """
@onready var cloud: GPUParticles3D = $Cloud
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

""" [[ ============================================================ ]] """
""" [[ Functions ]] """

func play_effect():
	cloud.emitting = true
	audio_stream_player.play()
