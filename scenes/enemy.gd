class_name Enemy
extends EnemyPlayerBase

@export var enemy_type: String = "NONE"

signal enemy_turn_ended
signal enemy_action(action: ActionResource, own: Enemy)

var action_pool: Array[ActionResource] = []

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
            push_error("No actions found for %s, should be" % 
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
    return action_pool.pop_front()

func set_enemy_type(p_enemy_type: String) -> void:
    enemy_type = p_enemy_type
    var enemy_type := DataManager.enemy_list[enemy_type]
    max_hp = enemy_type.hp
    hp = max_hp
    print("Spawning Enemy of type %s with %d HP" % [enemy_type.enemy_name, enemy_type.hp])
    $Sprite.texture = enemy_type.icon

func run():
    if statuses.get("delay", 0) > 0:
        # TODO: Should be replaced by animation
        await get_tree().create_timer(0.5).timeout
        print("%s is delayed" % enemy_type)
    elif enemy_type in DataManager.enemy_actions:
        var action = _get_next_action()

        enemy_action.emit(action, self)
    tick_delay()
    enemy_turn_ended.emit()

func serialize() -> Dictionary:
    var res := super.serialize()
    res.action_pool = action_pool
    return res

func deserialize(data: Dictionary) -> void:
    super.deserialize(data)
    action_pool = data.action_pool
