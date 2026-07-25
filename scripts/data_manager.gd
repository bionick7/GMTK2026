extends Node

const ENEMY_FOLDER := "res://mechanics_resources/enemies"
const SKILLS_DATA := "res://mechanics_resources/GMTK 2026 ideas - Skills.csv"
const ENEMY_SKILLS_DATA := "res://mechanics_resources/GMTK 2026 ideas - Enemy Skills.csv"

# I used to just check the folder, but theat doesn't work within
# the web version
const ENEMY_PATHS := [
	"res://mechanics_resources/enemies/Angel's Corpse.tres",
	"res://mechanics_resources/enemies/Demon's Remains.tres",
	"res://mechanics_resources/enemies/Ice Fairy.tres",
	"res://mechanics_resources/enemies/Living Glass.tres",
	"res://mechanics_resources/enemies/Moss Man.tres",
	"res://mechanics_resources/enemies/Mossatuar.tres",
	"res://mechanics_resources/enemies/Old Doll.tres",
	"res://mechanics_resources/enemies/Regrets of Time.tres",
	"res://mechanics_resources/enemies/Shrime.tres",
	"res://mechanics_resources/enemies/Shrimobi.tres",
	"res://mechanics_resources/enemies/Shrub.tres",
	"res://mechanics_resources/enemies/Stumped.tres",
	"res://mechanics_resources/enemies/Time Fairy.tres",
	"res://mechanics_resources/enemies/Water Fairy.tres",
]

var enemy_list: Dictionary[String, EnemyType] = {}
var player_actions: Dictionary[String, Array] = {}
var enemy_actions: Dictionary[String, Array] = {}

func _init() -> void:
	enemy_list = {}
	#_extract_enemy_types_from_dir(ENEMY_FOLDER, enemy_list)
	_extract_enemy_types_from_files(enemy_list)
	player_actions = _load_player_actions(SKILLS_DATA)
	enemy_actions = _load_enemy_actions(ENEMY_SKILLS_DATA)
	for enemy in enemy_list:
		assert(enemy in enemy_actions, "No actions for enemy %s " % enemy)
		#printt(enemy, len(enemy_actions[enemy]))
	#breakpoint
	
func _extract_enemy_types_from_files(res: Dictionary[String, EnemyType]) -> void:
	for path in ENEMY_PATHS:
		var resource := load(path)
		res[resource.enemy_name] = resource
	
func _extract_enemy_types_from_dir(folder_path: String, 
									res: Dictionary[String, EnemyType]) -> void:
	var dir = DirAccess.open(folder_path)
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		var path = folder_path + "/" + file_name
		if dir.current_is_dir():
			_extract_enemy_types_from_dir(path, res)
		else:
			var resource := load(path)
			if resource is EnemyType:
				res[resource.enemy_name] = resource
		file_name = dir.get_next()
	
func _generate_dict_from_csv_row(file: FileAccess, header) -> Dictionary[String, Variant]:
	var row := file.get_csv_line()
	if len(row) <= 1:
		return {}
	var action_dict: Dictionary[String, Variant]= {}
	for i in range(min(len(header), len(row))):
		if row[i] != "" and row[i] != "-":
			action_dict[header[i]] = row[i]
		if ";" in row[i]:
			action_dict[header[i]] = []
			for element in row[i].split(";"):
				action_dict[header[i]].append(element)
	return action_dict
	
func _load_player_actions(filepath: String) -> Dictionary[String, Array]:
	var res: Dictionary[String, Array] = {
		"Fight": [],
		"Heal": [],
		"Block": [],
		"None": [],
	}
	var file := FileAccess.open(filepath, FileAccess.READ)
	var header := file.get_csv_line()
	while not file.eof_reached():
		var action_dict = _generate_dict_from_csv_row(file, header)
		if not action_dict:
			continue
		var action = ActionResource.from_dict(action_dict)
		res[action.category].append(action)
	file.close()
	return res

func _load_enemy_actions(filepath: String) -> Dictionary[String, Array]:
	var res: Dictionary[String, Array] = {}
	var file := FileAccess.open(filepath, FileAccess.READ)
	var header := file.get_csv_line()
	while not file.eof_reached():
		var action_dict = _generate_dict_from_csv_row(file, header)
		if not action_dict:
			continue
		var action = ActionResource.from_dict(action_dict)
		var action_enemy_types = []
		action_enemy_types = action_dict.get("WHO", [])
		if action_enemy_types is String:
			action_enemy_types = [action_enemy_types]
		for action_enemy_type in action_enemy_types:
			if action_enemy_type not in res:
				res[action_enemy_type] = []
			res[action_enemy_type].append(action)
	file.close()
	return res
