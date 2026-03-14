""" [[ ============================================================ ]] """
extends Resource
class_name LoadGame
""" [[ ============================================================ ]] """

""" [[ Stats ]] """
const SAVE_GAME_PATH := "user://player_stats.save"

""" [[ ============================================================ ]] """
""" [[ Functions ]] """

func load_data() -> void:
	var data = {}
	
	if FileAccess.file_exists(SAVE_GAME_PATH):
		var file = FileAccess.open(SAVE_GAME_PATH, FileAccess.READ)
		data = JSON.parse_string(file.get_as_text())
	if data == null: data = {}

	if data.has(Global.USER_NAME):
		var playerData = data[Global.USER_NAME]
		if playerData.get("Password", "") == Global.PASSWORD:
			Global.GAME_DATA["PlayerStats"] = playerData.get("PlayerStats", []).duplicate(true)
			print("Loaded existing player:", Global.USER_NAME)
		else:
			print("Username exists but password mismatch. Creating new account...")
			Global.GAME_DATA["PlayerStats"] = Global.DEFAULT_PLAYER_DATA["PlayerStats"].duplicate(true)
	else:
		print("Creating new player:", Global.USER_NAME)
		Global.GAME_DATA["PlayerStats"] = Global.DEFAULT_PLAYER_DATA["PlayerStats"].duplicate(true)
