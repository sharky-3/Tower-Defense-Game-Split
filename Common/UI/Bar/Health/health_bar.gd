""" [[ ============================================================ ]] """
extends ProgressBar
""" [[ ============================================================ ]] """

""" [[ Node references ]] """
@onready var damage_bar: ProgressBar = $DamageBar
@onready var timer: Timer = $Timer

""" [[ Stats ]] """
var health:float = 0: set = set_health

""" [[ ============================================================ ]] """
""" [[ Initialize ]] """

func init(amount: float) -> void:
	health = amount
	damage_bar.max_value = amount
	damage_bar.value = amount
	max_value = amount
	value = amount

""" [[ ============================================================ ]] """
""" [[ Functions ]] """

func set_health(new: float) -> void:
	var previous = health
	health = clamp(new, 0, max_value)
	value = health

	if health <= 0: queue_free(); return

	if health < previous: timer.start()
	else: damage_bar.value = health

""" [[ ============================================================ ]] """
""" [[ Events ]] """

func _on_timer_timeout() -> void:
	damage_bar.value = health
