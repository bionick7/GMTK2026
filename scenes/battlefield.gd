class_name BattlefieldLogic
extends Node

static var singleton: BattlefieldLogic = null

const SKILLS_DATA := "res://mechanics_resources/GMTK 2026 ideas - Skills.txt"

enum TurnState {
	BLOCKED,
	AWAITING_PLAYER_INPUT,
	PLAYER_TURN_ANIMATION,
	ENEMY_TURN_ANIMATION,
}

@export var max_player_hp: int

var turn_fsm: TurnState = TurnState.BLOCKED

@onready var player: Player = %Player
@onready var pendulum = %Pendulum

var safe_state_track := []

func _ready() -> void:
	if is_instance_valid(singleton):
		queue_free()
	else:
		singleton = self
	var actions := _read_actions_from_file(SKILLS_DATA)
	$"../ActionMenu/Fight".actions = actions["Fight"]
	$"../ActionMenu/Heal".actions = actions["Heal"]
	$"../ActionMenu/Block".actions = actions["Block"]
	
	turn_fsm = TurnState.AWAITING_PLAYER_INPUT
	safe_state_track.append(get_gamestate())
	
func player_action(action: ActionResource, target: Enemy) -> void:
	$"../ActionMenu".current_tab = 0
	if turn_fsm != TurnState.AWAITING_PLAYER_INPUT:
		return
	pendulum.use_player_mana(action.cost)
	target.take_damage(action.damage)
	player.heal(action.heal)
	player.apply_block(action.block)
	if action.delay < 0:
		player.apply_delay(action.delay)
	else:
		target.apply_delay(action.delay)
	safe_state_track.append(get_gamestate())
	
	print("Player -> %s" % target.enemy_type)
	print(action.display())
	
	safe_state_track.append(get_gamestate())
	# Preovisory
	_on_next_pressed()

func enemy_action(action: ActionResource, enemy: Enemy) -> void:
	pendulum.use_enemy_mana(action.cost)
	player.take_damage(action.damage)
	enemy.heal(action.heal)
	enemy.apply_block(action.block)
	if action.delay < 0:
		enemy.apply_delay(action.delay)
	else:
		player.apply_delay(action.delay)
	print("%s -> Player" % enemy.enemy_type)
	print(action.display())
	safe_state_track.append(get_gamestate())

func get_gamestate() -> Dictionary:
	var data := {}
	for entity in [player] + get_tree().get_nodes_in_group("Enemies"):
		data[get_path_to(entity)] = {
			hp = entity.hp,
			block = entity.block,
			delay = entity.delay,
		}
	return data
	
func set_gamestate(data: Dictionary) -> void:
	for path in data:
		var entity: EnemyPlayerBase = get_node(path)
		entity.hp = data[path].hp
		entity.block = data[path].block
		entity.delay = data[path].delay

func _read_actions_from_file(filepath: String) -> Dictionary[String, Array]:
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
		print("Loaded ", action_dict)
		res[action.category].append(action)
	file.close()
	return res

func _on_next_pressed() -> void:
	if turn_fsm == TurnState.AWAITING_PLAYER_INPUT:
		turn_fsm = TurnState.ENEMY_TURN_ANIMATION
		for enemy in get_tree().get_nodes_in_group("Enemies"):
			enemy.run()
			await enemy.enemy_turn_ended
	
func _on_enemy_turn_ended() -> void:
	turn_fsm = TurnState.AWAITING_PLAYER_INPUT
