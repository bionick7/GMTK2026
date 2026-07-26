class_name BattlefieldLogic
extends Node


enum TurnState {
	BLOCKED,
	AWAITING_FIRST_PLAYER_INPUT,
	AWAITING_SECOND_PLAYER_INPUT,
	PLAYER_TURN_ANIMATION,
	ENEMY_TURN_ANIMATION,
	OUT_OF_GAME
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
	
	turn_fsm = TurnState.AWAITING_FIRST_PLAYER_INPUT
	safe_state_track.append(get_gamestate())
	_on_enemy_turn_ended()

func setup(enemy_type: String) -> void:
	player.reset()
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		enemy.reset(enemy_type)
	pendulum.set_player_mana(15)
	turn_fsm = TurnState.AWAITING_FIRST_PLAYER_INPUT

func battle_end() -> void:
	turn_fsm = TurnState.OUT_OF_GAME
	
func _handle_attack(action: ActionResource, from: EnemyPlayerBase, 
					to: EnemyPlayerBase) -> void:
	var multiplier := 1
	if from.has_status("double_damage"):
		multiplier = 2
	
	var mana_multiplier = 1
	if from.has_status("no_mana"):  # No mana overrides double mana
		mana_multiplier = 0
	elif from.has_status("double_mana"):
		mana_multiplier = 2
	
	if from is Player:
		pendulum.use_player_mana(action.cost * mana_multiplier)
	else:
		pendulum.use_enemy_mana(action.cost * mana_multiplier)

	to.take_damage(action.damage * multiplier)
	from.heal(action.heal * multiplier)
	from.apply_block(action.block * multiplier)
	for status in action.statuses:
		if status.duration < 0:
			from.apply_status(-status.duration, status.effect)
		else:
			to.apply_status(status.duration, status.effect)

func player_action(action: ActionResource, target: Enemy) -> void:
	$"../ActionMenu".current_tab = 0
	if turn_fsm not in [TurnState.AWAITING_FIRST_PLAYER_INPUT, TurnState.AWAITING_SECOND_PLAYER_INPUT]:
		return

	_handle_attack(action, player, target)
	if action.damage > 0:
		$EnemyHurt.play()
	if action.heal > 0:
		$PlayerAttack.play()
	if action.is_buff:
		$Buff.play()
	elif action.is_buff:
		$Debuff.play()
	
	print("Player -> %s" % target.enemy_type)
	print(action.display())
	safe_state_track.append(get_gamestate())
	# Preovisory

	if turn_fsm == TurnState.AWAITING_FIRST_PLAYER_INPUT and player.has_status("double_action"):
		turn_fsm = TurnState.AWAITING_SECOND_PLAYER_INPUT
	_on_next_pressed()

func enemy_action(action: ActionResource, enemy: Enemy) -> void:
	pendulum.use_enemy_mana(action.cost)

	_handle_attack(action, enemy, player)
	
	if action.damage > 0:
		$PlayerHurt.play()
	if action.is_buff:
		$Buff.play()
	elif action.is_buff:
		$Debuff.play()
	
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
	if turn_fsm == TurnState.OUT_OF_GAME:
		return
		
	player.tick_delay()
	turn_fsm = TurnState.ENEMY_TURN_ANIMATION
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		enemy.run()
		await enemy.enemy_turn_ended
	
func _on_enemy_turn_ended() -> void:
	if turn_fsm == TurnState.OUT_OF_GAME:
		return  # Game ended -- break the cycle
		
	player.evaluate_stats()
	if player.has_status("delay"):
		turn_fsm = TurnState.PLAYER_TURN_ANIMATION
		await get_tree().create_timer(0.5).timeout
		print("Player is delayed (%d)" % player.statuses.get("delay", 0))
		_on_next_pressed()
	else:
		turn_fsm = TurnState.AWAITING_FIRST_PLAYER_INPUT
