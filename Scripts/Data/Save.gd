""" [[ ============================================================ ]] """
extends Resource
class_name SaveGame
""" [[ ============================================================ ]] """

""" [[ Stats ]] """
const SAVE_GAME_PATH := "user://player_stats.save"

""" [[ ============================================================ ]] """
""" [[ Functions ]] """

func save_data():
	var data = {}

	if FileAccess.file_exists(SAVE_GAME_PATH):
		var fileRead = FileAccess.open(SAVE_GAME_PATH, FileAccess.READ)
		data = JSON.parse_string(fileRead.get_as_text())
	if data == null: data = {}

	if Global.USER_NAME == null: return
	data[Global.USER_NAME] = {
		"Password": Global.PASSWORD,
		"PlayerStats": Global.GAME_DATA["PlayerStats"]
	}

	var fileWrite = FileAccess.open(SAVE_GAME_PATH, FileAccess.WRITE)
	fileWrite.store_string(JSON.stringify(data, "\t"))

	print("Saved player:", Global.USER_NAME)
