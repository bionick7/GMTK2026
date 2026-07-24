class_name Enemy
extends EnemyPlayerBase

@export var enemy_type: String = "NONE"

signal enemy_turn_ended
signal enemy_action(action: ActionResource, own: Enemy)

func _init() -> void:
	pass

func _is_action_valid(action: ActionResource) -> bool:
	if not is_instance_valid(action):
		return false
	return true

func set_enemy_type(p_enemy_type: String) -> void:
	enemy_type = p_enemy_type
	var possible_actions := DataManager.enemy_actions[enemy_type]
	var enemy_type := DataManager.enemy_list[enemy_type]
	$Sprite.texture = enemy_type.icon

func run():
	if delay > 0:
		# TODO: Should be replaced by animation
		await get_tree().create_timer(0.5).timeout
		tick_delay()
	elif enemy_type in DataManager.enemy_actions:
		# Very simple enemy logic: chooses a random available action with equal likelyhood
		var possible_actions := DataManager.enemy_actions[enemy_type]
		var action = possible_actions[randi() % len(possible_actions)]
		while not _is_action_valid(action):
			action = possible_actions[randi() % len(possible_actions)]

		enemy_action.emit(action, self)
	enemy_turn_ended.emit()
