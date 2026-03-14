""" [[ ============================================================ ]] """
extends Node
class_name GameAccount
""" [[ ============================================================ ]] """

""" [[ Stats ]] """
var password_displayed: bool = false
var random_account_name: Array[String] = [
	"Iron Sentinel",
	"Flamewarden",
	"Storm Archer",
	"Crystal Golem",
	"Shadow Ranger",
	"Thunder Mage",
	"Blight Assassin",
	"Frost Guardian",
	"Arcane Knight",
	"Obsidian Sentinel",
	"Ember Paladin",
	"Vortex Sorcerer",
	"Grim Reaper",
	"Skyward Archer",
	"Blood Hunter",
	"Stonebreaker",
	"Windblade",
	"Nightblade",
	"Solar Champion",
    "Void Shaman"
]

""" [[ ============================================================ ]] """
""" [[ Functions ]] """

func game_account_registered(index: int):
	var new_value

	match index:
		0: 
			randomize()
			var random_number = randi() % random_account_name.size()
			var random_name = random_account_name[random_number]
			new_value = random_name
		
		1: 
			if password_displayed: 
				new_value = false
				password_displayed = false
			else: 
				new_value = true
				password_displayed = true

		2:
			print("Registered")

	return new_value
