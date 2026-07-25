class_name BattlefieldLogic
extends Node


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
	$"../ActionMenu/Fight".actions = DataManager.player_actions["Fight"]
	$"../ActionMenu/Heal".actions = DataManager.player_actions["Heal"]
	$"../ActionMenu/Block".actions = DataManager.player_actions["Block"]
	
	turn_fsm = TurnState.AWAITING_PLAYER_INPUT
	safe_state_track.append(get_gamestate())
	_on_enemy_turn_ended()
	
func player_action(action: ActionResource, target: Enemy) -> void:
	$"../ActionMenu".current_tab = 0
	if turn_fsm != TurnState.AWAITING_PLAYER_INPUT:
		return
	pendulum.use_player_mana(action.cost)
	target.take_damage(action.damage)
	player.heal(action.heal)
	player.apply_block(action.block)
	for status in action.statuses:
		if status.duration < 0:
			player.apply_status(-status.duration, status.effect)
		else:
			target.apply_status(status.duration, status.effect)
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
	for status in action.statuses:
		if status.duration < 0:
			enemy.apply_status(-status.duration, status.effect)
		else:
			player.apply_status(status.duration, status.effect)
	print("%s -> Player" % enemy.enemy_type)
	print(action.display())
	safe_state_track.append(get_gamestate())

func get_gamestate() -> Dictionary:
	var data := {}
	for entity in [player] + get_tree().get_nodes_in_group("Enemies"):
		data[get_path_to(entity)] = entity.serialize()
	return data
	
func set_gamestate(data: Dictionary) -> void:
	for path in data:
		var entity: EnemyPlayerBase = get_node(path)
		entity.deserialize(data[path])

func _on_next_pressed() -> void:
	turn_fsm = TurnState.ENEMY_TURN_ANIMATION
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		enemy.run()
		await enemy.enemy_turn_ended
	
func _on_enemy_turn_ended() -> void:
	if player.delay > 0:
		turn_fsm = TurnState.PLAYER_TURN_ANIMATION
		await get_tree().create_timer(0.5).timeout
		print("Player is delayed (%d)", player.delay)
		player.tick_delay()
		_on_next_pressed()
	else:
		turn_fsm = TurnState.AWAITING_PLAYER_INPUT
