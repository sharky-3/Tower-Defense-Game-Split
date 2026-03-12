""" [[ ============================================================ ]] """
extends Node
class_name GameSettings
""" [[ ============================================================ ]] """

""" [[ Stats ]] """
var settings: Array = [
	{ "Name": "Windowed Mode", 
		"Values": [ "Windowed", "Maximized", "Fullscreen" ], 
		"CurrentSelectedValue": 2
	},
	{ "Name": "Resolution",
		"Values": [ Vector2i(1024, 768), Vector2i(1280, 720), Vector2i(1366, 768), Vector2i(1600, 900), Vector2i(1920, 1080), Vector2i(1920, 1200), Vector2i(2560, 1440), Vector2i(2560, 1600), Vector2i(3440, 1440), Vector2i(3840, 2160), Vector2i(5120, 2880), Vector2i(7680, 4320) ],
		"CurrentSelectedValue": 0
	},
	{ "Name": "Fov",
		"Values": [], 
		"CurrentSelectedValue": 75,
		"MinValue": 30,
		"MaxValue": 120
	},
]
var previousSettingName: String = ""

""" [[ ============================================================ ]] """
""" [[ Functions ]] """

func update_game_settings(index: int, player_camera: Camera3D):
	var setting = settings[index]

	var setting_name: String = setting["Name"]
	var values: Array = setting.get("Values", [])
	var current_value: int = setting.get("CurrentSelectedValue", 0)

	setting["CurrentSelectedValue"] = current_value
	var new_value = values[current_value] if values.size() > 0 else null

	if values.size() > 0:
		if previousSettingName != setting_name: previousSettingName = setting_name
		current_value = (current_value + 1) % values.size()
		setting["CurrentSelectedValue"] = current_value
		new_value = values[current_value]
	else:  new_value = null

	match setting_name:
		"Windowed Mode":
			match str(new_value):
				"Windowed": DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_WINDOWED)
				"Maximized": DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_MAXIMIZED)
				"Fullscreen": DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN)
		"Resolution":
			if typeof(new_value) == TYPE_VECTOR2I:
				DisplayServer.window_set_size(new_value)
		"Fov":
			var fov_options := [120, 110, 100, 90, 75, 60, 45, 30]
			if previousSettingName == setting_name:
				var current_idx := fov_options.find(current_value)
				current_idx = (current_idx + 1) % fov_options.size()
				current_value = fov_options[current_idx]
			else:
				current_value = 75
				previousSettingName = setting_name
			setting["CurrentSelectedValue"] = current_value
			if player_camera: player_camera.fov = current_value
			
			return current_value
			
	return new_value
