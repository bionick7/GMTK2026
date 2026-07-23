extends Control

@export
var tab_button_group: ButtonGroup

@onready
var menu_buttons : Array[BaseButton] = [
	$ActionMenuButtons/H/Fight,
	$ActionMenuButtons/H/Heal,
	$ActionMenuButtons/H/Block,
]

func _ready() -> void:
	tab_button_group.pressed.connect(_on_action_tab_changed)

func  _process(delta: float) -> void:
	pass
	
func _on_action_tab_changed(x: BaseButton):
	for i in range(len(menu_buttons)):
		if menu_buttons[i].button_pressed:
			$ActionMenu.current_tab = i + 1
			return
	$ActionMenu.current_tab = 0
