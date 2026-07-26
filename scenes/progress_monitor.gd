class_name ProgressMonitor
extends Control

enum MetaState {
	COMBAT,
	CHOICE,
	ANIMATION_WAIT
}

@export var meta_state := MetaState.COMBAT
@export var start_enemy := ""
@export_range(1, 5, 1) var start_level := 1
var game_floor := 0

var level: int:
	get(): return min(floori(game_floor / 3) + start_level, 5)

var choices = [
	{ enemy_type = "imp" },
	{ enemy_type = "imp" },
]

@onready var current_ui_root = $UIRooot

func _ready() -> void:
	if start_enemy in DataManager.enemy_list:
		restart_combat({ enemy_type = start_enemy })
	elif MetaState.CHOICE:
		_spawn_choices()
	else:
		$Choice.hide()
		
func _get_2_random_enemies() -> Array[EnemyType]:
	var valid_enemy_types = []
	for k in DataManager.enemy_list:
		#printt(k, DataManager.enemy_list[k].levels)
		if DataManager.enemy_list[k].levels & (1 << (level - 1)) != 0:
			valid_enemy_types.append(k)
		
	assert(len(valid_enemy_types) >= 1)
	var enemy_name_1
	var enemy_name_2
	if len(valid_enemy_types) == 1:
		enemy_name_1 = valid_enemy_types[0]
		enemy_name_2 = valid_enemy_types[0]
	else:
		enemy_name_1 = valid_enemy_types.pick_random()
		enemy_name_2 = enemy_name_1
		while enemy_name_2 == enemy_name_1:
			enemy_name_2 = valid_enemy_types.pick_random()
	
	var enemy_a := DataManager.enemy_list[enemy_name_1]
	var enemy_b := DataManager.enemy_list[enemy_name_2]
	return [enemy_a, enemy_b]

func _on_ui_rooot_round_finished(player_won: bool) -> void:
	if player_won:
		game_floor += 1
	else:
		# Play and await death animation from here
		$DeathAnimation.show()
		$DeathAnimation/AnimationPlayer.play("Game over animation")
		await $DeathAnimation/AnimationPlayer.animation_finished
		$DeathAnimation.hide()
		game_floor = 0
	_spawn_choices()
	
func _spawn_choices():
	var enemies = _get_2_random_enemies()
	choices = [
		{ enemy_type = enemies[0].enemy_name },
		{ enemy_type = enemies[1].enemy_name },
	]
	
	$Choice/V/A.setup(enemies[0])
	$Choice/V/B.setup(enemies[1])
	
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
