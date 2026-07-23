extends Control

const action_button_scene = preload("res://scenes/action_button.tscn")

@export
var actions: Array[ActionResource] = []

@onready var action_button_parent := $V
@onready var description := $Description
@onready var description_text := $Description/TextEdit

var hover_action: ActionResource = null

signal on_action_chosen(action: ActionResource)

func _ready() -> void:
	#$BG.texture = background_image
	for action in actions:
		var action_button : ActionButton = action_button_scene.instantiate()
		action_button.resource = action
		action_button_parent.add_child(action_button)
		action_button.pressed.connect(_on_action_selected.bind(action))
		action_button.mouse_entered.connect(_on_action_hover_in.bind(action))
		action_button.mouse_exited.connect(_on_action_hover_out.bind(action))

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
