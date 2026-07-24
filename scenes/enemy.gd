class_name Enemy
extends EnemyPlayerBase

const ENEMY_SKILLS_DATA := "res://mechanics_resources/GMTK 2026 ideas - Enemy Skills.txt"

var action_database: Dictionary[StringName, Array] = {}

@export var enemy_type: StringName

signal enemy_turn_ended
signal enemy_action(action: ActionResource, own: Enemy)

func _init() -> void:
	action_database = _read_actions_from_file(ENEMY_SKILLS_DATA)
	enemy_type = action_database.keys()[1]

func _read_actions_from_file(filepath: String) -> Dictionary[StringName, Array]:
	var res: Dictionary[StringName, Array] = {}
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

func _is_action_valid(action: ActionResource) -> bool:
	if not is_instance_valid(action):
		return false
	return true

func run():
	if delay > 0:
		await get_tree().create_timer(0.5).timeout
		tick_delay()
	else:
		# Very simple enemy logic: chooses a random available action with equal likelyhood
		var possible_actions := action_database[enemy_type]
		var action = possible_actions[randi() % len(possible_actions)]
		while not _is_action_valid(action):
			action = possible_actions[randi() % len(possible_actions)]

		enemy_action.emit(action, self)
	enemy_turn_ended.emit()
