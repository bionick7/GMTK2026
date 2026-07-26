extends Control

@export
var tab_button_group: ButtonGroup

@onready
var menu_buttons : Array[BaseButton] = [
	$ActionMenuButtons/H/Fight,
	$ActionMenuButtons/H/Heal,
	$ActionMenuButtons/H/Block,
]

signal round_finished(player_won: bool)

func _ready() -> void:
	tab_button_group.pressed.connect(_on_action_tab_changed)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_sepuku"):
		round_finished.emit(false)
	
func setup(enemy_type: String) -> void:
	$BattlefieldLogic.setup(enemy_type)
	
func _on_action_tab_changed(x: BaseButton):
	for i in range(len(menu_buttons)):
		if menu_buttons[i].button_pressed:
			$ActionMenu.current_tab = i + 1
			return
	$ActionMenu.current_tab = 0

func _on_player_die() -> void:
	$BattlefieldLogic.battle_end()
	print("Player died")
	await get_tree().create_timer(1).timeout
	round_finished.emit(false)

func _on_enemy_die() -> void:
	round_finished.emit(true)
	$BattlefieldLogic.battle_end()
	print("Enemy died")

func play() -> void:
	pass # Replace with function body.
