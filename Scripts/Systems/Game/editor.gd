""" [[ ============================================================ ]] """
extends Node
class_name GameEditor
""" [[ ============================================================ ]] """

""" [[ Resources ]] """
const FLOWER = preload("uid://dkhie1perrys7")
const ROCK = preload("uid://cj13cnwv7eumy")
const TREE_1 = preload("uid://bwsye514hjd4")
const TREE_2 = preload("uid://b7mx4vexa3go")

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
	{ "Name": "Wave Timer",
		"Values": [ 60, 50, 40, 30, 20, 10, 5 ],
		"CurrentSelectedValue": 5
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
	{ "Name": "Save",
		"Values": [],
		"CurrentSelectedValue": 0
	},
]
var previousSettingName: String = ""

""" [[ ============================================================ ]] """
""" [[ Functions ]] """

func update_game_editor(index: int, viewport: SubViewport):

	var editor = editorValues[index]
	var main: Node3D = viewport.get_parent().get_parent()
	
	var editor_name: String = editor["Name"]
	var values: Array = editor.get("Values", [])
	var current_value: int = editor.get("CurrentSelectedValue", 0)
		
	editor["CurrentSelectedValue"] = current_value
	var new_value = values[current_value] if values.size() > 0 else null

	if values.size() > 0:
		if previousSettingName != editor_name: previousSettingName = editor_name
		current_value = (current_value + 1) % values.size()
		editor["CurrentSelectedValue"] = current_value
		new_value = values[current_value]
	else: new_value = null
		
	match editor_name:
		"Map":
			for map in viewport.get_children():
				if map is Node3D: map.visible = false
				
			var map_node = viewport.get_node_or_null(str(new_value))
			if map_node: map_node.visible = true
				
		"Environment":
			var map_node: Node3D = null

			for map in viewport.get_children():
				if map is Node3D and map.visible:
					map_node = map
					break

			if map_node == null:
				var default_map_name = "Forest"
				map_node = viewport.get_node_or_null(default_map_name)
				if map_node: map_node.visible = true

			if map_node == null: return new_value

			var env_node: Node3D = map_node.get_node_or_null("Environment")
			if env_node == null:
				env_node = Node3D.new()
				env_node.name = "Environment"
				map_node.add_child(env_node)

			var count = int(new_value * 1.5)
			var rocks_count = int(round(count * 0.2))
			var flowers_count = int(round(count * 0.2))
			var remaining = count - rocks_count - flowers_count

			var objects = []
			for i in rocks_count: objects.append(ROCK)
			for i in flowers_count: objects.append(FLOWER)
			for i in remaining: objects.append([TREE_1, TREE_2][randi() % 2])
			objects.shuffle()

			var env_objects = []
			for child in env_node.get_children():
				if child.name.begins_with("EnvObject_"):
					env_objects.append(child)

			if env_objects.size() > count:
				for i in range(env_objects.size() - count):
					env_objects[i].queue_free()

			var existing_positions = []
			for child in env_objects:
				existing_positions.append(child.position)

			var spacing_radius: float = 10.0

			for i in range(count - env_objects.size()):
				var obj_scene = objects[i].instantiate() as Node3D
				obj_scene.name = "EnvObject_%d" % (env_objects.size() + i)

				var pos = find_valid_position(existing_positions, spacing_radius, 45)
				if pos:
					obj_scene.position = pos
					existing_positions.append(pos)
					obj_scene.rotation.y = randf_range(0, TAU)
					env_node.add_child(obj_scene)

		"Wave Timer":
			if main.has_method("set_up_wave_timer"):
				main.set_up_wave_timer(int(new_value))

		"Round Count": 
			if main.has_method("set_up_round_counts"):
				main.set_up_round_counts(str(new_value))
				
		"Bosses": 
			if main.has_method("set_up_bosses"):
				main.set_up_bosses(str(new_value))
				
		"Difficulty": 
			if main.has_method("set_up_difficulty"):
				main.set_up_difficulty(str(new_value))
				
		"Save":
			if main.has_method("saved_and_start_new_game"):
				main.saved_and_start_new_game()
			
				
	return new_value
	
func find_valid_position(existing_positions: Array, radius: float = 10, area_size: float = 45) -> Vector3:
	for attempt in range(100):
		var pos = Vector3(randf_range(-area_size, area_size), 0, randf_range(-area_size, area_size))
		var valid = true
		for other in existing_positions:
			if pos.distance_to(other) < radius:
				valid = false
				break
				
		if valid: return pos
	return Vector3(randf_range(-area_size, area_size), 0, randf_range(-area_size, area_size))
