""" [[ ============================================================ ]] """
extends Node3D
""" [[ ============================================================ ]] """

""" [[ Node references ]] """
@onready var fire: GPUParticles3D = $Fire
@onready var fire_2: GPUParticles3D = $Fire2
@onready var beam: GPUParticles3D = $Beam
@onready var sparks: GPUParticles3D = $Sparks

""" [[ ============================================================ ]] """
""" [[ Functions ]] """

func fire_effect():
	fire.emitting = true
	fire_2.emitting = true
	beam.emitting = true
	sparks.emitting = true
