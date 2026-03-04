extends Control

@onready var gold: Label = $Gold

func _process(_delta: float) -> void:
	gold.text = "Gold: " + str(Global.get_looking_value("Gold"))
