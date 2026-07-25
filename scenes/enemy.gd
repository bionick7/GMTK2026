class_name Enemy
extends EnemyPlayerBase

@export var enemy_type: String = "NONE"

signal enemy_turn_ended
signal enemy_action(action: ActionResource, own: Enemy)

var action_pool: Array[ActionResource] = []

@onready var action_labels = [
	$Action1Text,
	$Action2Text,
]


@onready var pendulum: Pendulum = %Pendulum

func _init() -> void:
	pass

func _is_action_valid(action: ActionResource) -> bool:
	if not is_instance_valid(action):
		return false
	return true

func _get_next_action() -> ActionResource:
	# Actions are  tracked in a pool to ensure every action is shown sooner or later
	if action_pool.is_empty():
		if enemy_type not in DataManager.enemy_actions:
			push_error("No actions found for %s, should be in %s" % 
						[enemy_type, str(DataManager.enemy_actions.keys())])
			return null
		var possible_actions := DataManager.enemy_actions[enemy_type]
		action_pool.append_array(possible_actions)
		# Add maybe a bit of randomnes
		var extra_actions := len(possible_actions)
		for _x in range(extra_actions):
			var random_action = possible_actions[randi() % len(possible_actions)]
			action_pool.append(random_action)
		action_pool.shuffle()
	assert(len(action_pool) > 0)
	
	var does_mana_complient_action_exist := false
	for action in action_pool:
		if action.cost <= pendulum.enemy_mana:
			does_mana_complient_action_exist = true
			
	if does_mana_complient_action_exist and action_pool[0].cost > pendulum.enemy_mana:
		action_pool.pop_front()
	
	return action_pool.pop_front()

func reset(p_enemy_type: String) -> void:
	enemy_type = p_enemy_type
	var enemy_type := DataManager.enemy_list[enemy_type]
	max_hp = enemy_type.hp
	hp = max_hp
	statuses = {}
	pendulum.set_player_mana(20)
	for action_label in action_labels:
		action_label.text = ""
	
	print("Spawning Enemy of type %s with %d HP" % [enemy_type.enemy_name, enemy_type.hp])
	$Sprite.texture = enemy_type.icon

func run() -> void:
	if hp <= 0:
		return
	await get_tree().create_timer(0.5).timeout
	var N_actions := 1 
	if has_status("delay"):
		# TODO: Should be replaced by animation
		print("%s is delayed" % enemy_type)
		N_actions = 0
	if has_status("double_action"):
		print("%s double action" % enemy_type)
		N_actions = 2
	if enemy_type not in DataManager.enemy_actions:
		print("No actions found for %s" % enemy_type)
		N_actions = 0
		
	evaluate_stats()
		
	for action_label in action_labels:
		action_label.text = ""
	for i in range(N_actions):
		var action = _get_next_action()
		var label_animation = get_tree().create_tween().set_parallel(true)
		if is_instance_valid(action):
			enemy_action.emit(action, self)
			action_labels[i].text = action.name
			action_labels[i].visible_ratio = 0
			label_animation.tween_property(action_labels[i], "visible_ratio", 1, .2)
	
	tick_delay()
	enemy_turn_ended.emit()

func serialize() -> Dictionary:
	var res := super.serialize()
	res.action_pool = action_pool
	return res

func deserialize(data: Dictionary) -> void:
	super.deserialize(data)
	action_pool = data.action_pool
