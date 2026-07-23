class_name ActionButton
extends TextureButton

var action: ActionResource = null

signal action_selected(action)
signal action_hover_in(action)
signal action_hover_out(action)

func set_resource(p_action: ActionResource) -> void:
	action = p_action
	$CostLabel.text = str(action.cost)
	$NameLabel.text = action.name
	
func _process(delta: float) -> void:
	if action.cost > BattlefieldLogic.singleton.pendulum.player_mana:
		disabled = true
		modulate = Color.GRAY
	else:
		disabled = false
		modulate = Color.WHITE

func _on_mouse_entered() -> void:
	action_hover_in.emit(action)

func _on_mouse_exited() -> void:
	action_hover_out.emit(action)

func _on_pressed() -> void:
	action_selected.emit(action)
