extends Node3D

# --- Constants / Exported Data ---
@export_category("Main")
@export var tower_healt: float
@export var max_health: float

@export_category("Visual/Audio")
@export var damage_effect: bool
@export var death_effect: bool
@export var hit_sound: AudioStream
@export var death_sound: AudioStream

# --- Node references ---
@onready var player_tower: Node3D = $"."
@onready var tower_animation: AnimationPlayer = $AnimationPlayer

# --------------------------------------------------------------------
# Life Cycle
# --------------------------------------------------------------------

func _ready():
	tower_animation.animation_finished.connect(Callable(self, "_on_animation_finished"))

# --------------------------------------------------------------------
# Take Damage
# --------------------------------------------------------------------

func take_attack_damage(amount: float) -> void:
	_attempt_damage(amount)

func _attempt_damage(damage: float) -> void:
	tower_healt -= damage
	_update_player_game_stats("damage_taken", damage)

	if _tower_health(tower_healt):
		if death_effect and death_sound:
			$AudioStreamPlayer.stream = death_sound
			$AudioStreamPlayer.play()
		tower_animation.play("death")

# --------------------------------------------------------------------
# Animation Finished
# --------------------------------------------------------------------

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "death":
		player_tower.queue_free()

# --------------------------------------------------------------------
# Health Check
# --------------------------------------------------------------------

func _tower_health(health: float) -> bool:
	return health <= 0

func is_tower_dead() -> bool:
	return _tower_health(tower_healt)

# --------------------------------------------------------------------
# Global Player Stats
# --------------------------------------------------------------------

func _update_player_game_stats(stat_name: String, value: float):
	Global.update_player_game_stats("stats", stat_name, value)
