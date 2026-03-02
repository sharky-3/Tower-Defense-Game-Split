extends Node3D

@onready var debris := get_node_or_null("Debris")
@onready var smoke := get_node_or_null("Smoke")
@onready var fire := get_node_or_null("Fire")
@onready var explosion_sound := get_node_or_null("explosionSound")

var timer := 0.0
var interval := 3.0   # time between explosions

func _process(delta: float) -> void:
	timer += delta
	
	if timer >= interval:
		timer = 0.0
		explode()

func explode():
	if debris: debris.restart()
	if smoke: smoke.restart()
	if fire: fire.restart()
	if explosion_sound: explosion_sound.play()
