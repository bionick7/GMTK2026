class_name Statuses
extends RichTextLabel

const EFFECT_ICON_PATHS = {
	"double_action": "res://assets/sprites/Atlases/status_actionx2.tres",
	"double_damage": "res://assets/sprites/Atlases/status_dmgx2.tres",
	"heal(2)": "res://assets/sprites/Atlases/status_heal.tres",
	"double_mana": "res://assets/sprites/Atlases/status_manax2.tres",
	"no_mana": "res://assets/sprites/Atlases/status_nomana.tres",
	"poison(1)": "res://assets/sprites/Atlases/status_poison.tres",
	"poison(2)": "res://assets/sprites/Atlases/status_poison.tres",
	"poison(4)": "res://assets/sprites/Atlases/status_poison.tres",
	"poison(5)": "res://assets/sprites/Atlases/status_poison.tres",
	"delay": "res://assets/sprites/Atlases/status_skip.tres",
}

@export var entity: EnemyPlayerBase
@export var vertical: bool
		
func _ready() -> void:
	bbcode_enabled = true
	
func _process(delta: float) -> void:
	set_statuses(entity.statuses)
	#set_clock_to_state(floori(get_tree().get_frame() / 20) % 5)

func set_statuses(statuses: Dictionary) -> void:
	text = ""
	for effect in statuses:
		text += "[img]%s[/img] %d " % [
			EFFECT_ICON_PATHS[effect],
			statuses[effect],
		]
		if vertical:
			text += "\n"
