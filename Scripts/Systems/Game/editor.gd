""" [[ ============================================================ ]] """
extends Node
class_name GameEditor
""" [[ ============================================================ ]] """

""" [[ Stats ]] """
var editorValues: Array = [
	{ "Name": "Map",
		"Values": [ "Forest", "Ocean", "Desert" ],
		"CurrentSelectedValue": 0
	},
	{ "Name": "Environment",
		"Values": [ 30, 25, 20, 15, 10, 5, 3, 0 ],
		"CurrentSelectedValue": 1
	},
	{ "Name": "Round Count",
		"Values": [ "INF", 100, 90, 80, 70, 60, 50, 40, 30, 20, 10, 5 ],
		"CurrentSelectedValue": 0
	},
	{ "Name": "Bosses",
		"Values": [ "On", "Off" ],
		"CurrentSelectedValue": 0
	},
	{ "Name": "Difficulty",
		"Values": [ "Easy", "Normal", "Medium", "Hard" ],
		"CurrentSelectedValue": 1
	},
]
var previousSettingName: String = ""

""" [[ ============================================================ ]] """
""" [[ Functions ]] """

func update_game_editor(index: int):
	var editor = editorValues[index]
	
	var editor_name: String = editor["Name"]
	var values: Array = editor.get("Values", [])
	var current_value: int = editor.get("CurrentSelectedValue", 0)
	
	if previousSettingName == editor_name and values.size() > 0: current_value = (current_value + 1) % values.size()
	else: previousSettingName = editor_name
	editor["CurrentSelectedValue"] = current_value
	var new_value = values[current_value] if values.size() > 0 else null
	
	match editor_name:
		"Map": pass
		"Environment": pass
		"Round Count": pass
		"Bosses": pass
		"Difficulty": pass
		
	return new_value
