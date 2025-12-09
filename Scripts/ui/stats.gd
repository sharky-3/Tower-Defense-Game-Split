extends Control

@onready var gold: Label = $Gold

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	gold.text = str(
		"Gold: ", 
		Global.get_looking_value("currency", "gold")
	)
