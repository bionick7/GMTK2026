extends Control

const action_button_scene = preload("res://scenes/action_button.tscn")

@export
var actions: Array = []

@onready var action_button_parent := $V
@onready var description := $Description
@onready var description_text := $Description/TextEdit

var hover_action: ActionResource = null

var ui_action_offset := 0

@onready var action_buttons := [
	$V/ActionButton,
	$V/ActionButton2,
	$V/ActionButton3,
]

signal on_action_chosen(action: ActionResource)

func _ready() -> void:
	_update_action_buttons()
	for action_button in action_buttons:
		action_button.action_hover_in.connect(_on_action_hover_in)
		action_button.action_hover_out.connect(_on_action_hover_out)
		action_button.action_selected.connect(_on_action_selected)

func _update_action_buttons() -> void:
	for button_idx in range(len(action_buttons)):
		var action_idx := (button_idx + ui_action_offset) % len(actions)
		action_buttons[button_idx].set_resource(actions[action_idx])

func _on_action_selected(action: ActionResource) -> void:
	on_action_chosen.emit(action)

func _on_action_hover_in(action: ActionResource) -> void:
	hover_action = action
	description_text.text = action.description
	description.show()
	
func _on_action_hover_out(action: ActionResource) -> void:
	if hover_action == action:
		hover_action = null
		description.hide()
		#description_text.text = ""

func _on_up_pressed() -> void:
	#ui_action_offset = (ui_action_offset - 1) % len(actions)
	ui_action_offset = max(ui_action_offset - 1, 0)
	_update_action_buttons()

func _on_down_pressed() -> void:
	ui_action_offset = min(ui_action_offset + 1, len(actions) - len(action_buttons))
	_update_action_buttons()
