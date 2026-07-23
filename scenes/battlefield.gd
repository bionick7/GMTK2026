class_name BattlefieldLogic
extends Node

static var singleton: BattlefieldLogic = null

const SKILLS_DATA := "res://working files/GMTK 2026 ideas - Skills.txt"

enum TurnState {
	BLOCKED,
	AWAITING_PLAYER_INPUT,
	PLAYER_TURN_ANIMATION,
	ENEMY_TURN_ANIMATION,
}

var turn_fsm: TurnState = TurnState.BLOCKED

@onready var pendulum = %Pendulum
@onready var enemy_logic = $EnemyLogic

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
	
func player_action(action: ActionResource) -> void:
	if turn_fsm != TurnState.AWAITING_PLAYER_INPUT:
		return
	prints(action.display())
	pendulum.use_player_mana(action.cost)

func enemy_action(action: ActionResource) -> void:
	pass # Replace with function body.

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
		res[action.category].append(action)
	file.close()
	return res

func _on_next_pressed() -> void:
	if turn_fsm == TurnState.AWAITING_PLAYER_INPUT:
		turn_fsm = TurnState.ENEMY_TURN_ANIMATION
		enemy_logic.run()
	
func _on_enemy_turn_ended() -> void:
	turn_fsm = TurnState.AWAITING_PLAYER_INPUT
