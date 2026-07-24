extends Node

const ENEMY_FOLDER := "res://mechanics_resources/enemies"
const SKILLS_DATA := "res://mechanics_resources/GMTK 2026 ideas - Skills.txt"
const ENEMY_SKILLS_DATA := "res://mechanics_resources/GMTK 2026 ideas - Enemy Skills.txt"

var enemy_list: Dictionary[String, EnemyType] = {}
var player_actions: Dictionary[String, Array] = {}
var enemy_actions: Dictionary[String, Array] = {}

func _init() -> void:
	enemy_list = load_enemies(ENEMY_FOLDER)
	player_actions = load_player_actions(SKILLS_DATA)
	enemy_actions = load_enemy_actions(ENEMY_SKILLS_DATA)
	
func _extract_enemy_types_from_dict(folder_path: String, 
									res: Dictionary[String, EnemyType]) -> void:
	var dir = DirAccess.open(folder_path)
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		var path = folder_path + "/" + file_name
		if dir.current_is_dir():
			_extract_enemy_types_from_dict(path, res)
		else:
			var resource := load(path)
			if resource is EnemyType:
				res[resource.enemy_name] = resource
		file_name = dir.get_next()
		
	
func load_enemies(folder_path: String) -> Dictionary[String, EnemyType]:
	var res: Dictionary[String, EnemyType] = {}
	_extract_enemy_types_from_dict(folder_path, res)
	return res
	
func load_player_actions(filepath: String) -> Dictionary[String, Array]:
	var res: Dictionary[String, Array] = {
		"Fight": [],
		"Heal": [],
		"Block": [],
		"None": [],
	}
	var file := FileAccess.open(filepath, FileAccess.READ)
	var header := file.get_csv_line()
	while not file.eof_reached():
		var row := file.get_csv_line()
		if len(row) <= 1:
			continue
		var action_dict: Dictionary[String, Variant]= {}
		for i in range(min(len(header), len(row))):
			if row[i] != "" and row[i] != "-":
				action_dict[header[i]] = row[i]
		var action = ActionResource.from_dict(action_dict)
		#print("Loaded ", action_dict)
		res[action.category].append(action)
	file.close()
	return res

func load_enemy_actions(filepath: String) -> Dictionary[String, Array]:
	var res: Dictionary[String, Array] = {}
	var file := FileAccess.open(filepath, FileAccess.READ)
	var header := file.get_csv_line()
	while not file.eof_reached():
		var row := file.get_csv_line()
		if len(row) <= 1:
			continue
		var action_dict: Dictionary[String, Variant]= {}
		for i in range(min(len(header), len(row))):
			if row[i] != "" and row[i] != "-":
				action_dict[header[i]] = row[i]
		var action = ActionResource.from_dict(action_dict)
		var action_enemy_types = []
		if "WHO" in action_dict:
			action_enemy_types = action_dict.get("WHO", "").split(";")
		for action_enemy_type in action_enemy_types:
			if action_enemy_type not in res:
				res[action_enemy_type] = []
			res[action_enemy_type].append(action)
	file.close()
	return res
