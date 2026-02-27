""" [[ ============================================================ ]] """
extends Node3D
""" [[ ============================================================ ]] """

""" [[ Constants / Exported Data ]] """
@export_category("Main")
@export var tower_health: float
@export var max_health: float

@export_category("Visual/Audio")
@export var damage_effect: bool
@export var death_effect: bool
@export var hit_sound: AudioStream
@export var death_sound: AudioStream

""" [[ Node references ]] """
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var player_tower: Node3D = $"."
@onready var tower_animation: AnimationPlayer = $AnimationPlayer

""" [[ ============================================================
	// FUNCTIONS
]] """

""" [[ ============================================================ ]] """
""" [[ Ready ]] """
func _ready():
	tower_animation.animation_finished.connect(Callable(self, "_on_animation_finished"))

""" [[ ============================================================ ]] """
""" [[ Take Enemy Damage ]] """
func take_attack_damage(amount: float) -> void:
	_attempt_damage(amount)

""" [[ Attampt To Take Damage ]] """
func _attempt_damage(damage: float) -> void:
	tower_health -= damage
	#audio_stream_player.play()
	_update_player_game_stats("Total_Damage_Taken", damage)

	if _tower_health(tower_health):
		if death_effect and death_sound:
			$AudioStreamPlayer.stream = death_sound
			$AudioStreamPlayer.play()
		tower_animation.play("death")

""" [[ ============================================================ ]] """
""" [[ Death Animation ]] """
func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "death":
		player_tower.queue_free()

""" [[ ============================================================ ]] """
""" [[ Tower Health ]] """
func _tower_health(health: float) -> bool:
	return health <= 0

""" [[ Check If Tower Is Dead ]] """
func is_tower_dead() -> bool:
	return _tower_health(tower_health)
	
""" [[ ============================================================ ]] """
""" [[ Interaction Test ]] """
func on_clicked():
	print("Clicked Player Tower")

""" [[ ============================================================
	// GLOBAL
]] """

""" [[ Update Player Stats ]] """
func _update_player_game_stats(stat_name: String, value: float):
	Global.update_player_game_stats(stat_name, value)
