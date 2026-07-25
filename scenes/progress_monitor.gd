class_name ProgressMonitor
extends Control

enum MetaState {
	COMBAT,
	CHOICE,
	ANIMATION_WAIT
}

@export var meta_state := MetaState.COMBAT
@export var start_enemy := ""

var choices = [
	{ enemy_type = "imp" },
	{ enemy_type = "imp" },
]

@onready var current_ui_root = $UIRooot

func _ready() -> void:
	if start_enemy in DataManager.enemy_list:
		restart_combat({ enemy_type = start_enemy })
	elif MetaState.CHOICE:
		_on_ui_rooot_round_finished(false)
	else:
		$Choice.hide()

func _on_ui_rooot_round_finished(player_won: bool) -> void:
	var enemy_types = DataManager.enemy_list.keys()
	assert(len(enemy_types) >= 2)
	var enemy_type_index_1 = randi() % len(enemy_types)
	var enemy_type_index_2 = randi() % len(enemy_types)
	while enemy_type_index_2 == enemy_type_index_1:
		enemy_type_index_2 = randi() % len(enemy_types)
	choices = [
		{ enemy_type = enemy_types[enemy_type_index_1] },
		{ enemy_type = enemy_types[enemy_type_index_2] },
	]
	
	var enemy_a := DataManager.enemy_list[enemy_types[enemy_type_index_1]]
	var enemy_b := DataManager.enemy_list[enemy_types[enemy_type_index_2]]
	
	# For now, let's set it up this way. For real,
	# you would have a method on the choice button 
	# itself that handles this
	$Choice/V/A.setup(enemy_a)
	$Choice/V/B.setup(enemy_b)
	
	meta_state = MetaState.CHOICE
	$Choice.show()

func restart_combat(new_combat_data: Dictionary) -> void:
	current_ui_root.setup(new_combat_data.enemy_type)
	meta_state = MetaState.COMBAT
	$Choice.hide()

func _on_a_pressed() -> void:
	if meta_state != MetaState.CHOICE:
		return
	restart_combat(choices[0])
	
func _on_b_pressed() -> void:
	if meta_state != MetaState.CHOICE:
		return
	restart_combat(choices[1])
