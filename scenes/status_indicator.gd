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

const DESCRIPTIONS = {
	"double_action": "Performs 2 actions",
	"double_damage": "2x damage",
	"heal(2)": "Heals 2 p. round",
	"double_mana": "2x Mana cost",
	"no_mana": "No Mana cost",
	"poison(1)": "Damages 1 p. round",
	"poison(2)": "Damages 2 p. round",
	"poison(4)": "Damages 4 p. round",
	"poison(5)": "Damages 5 p. round",
	"delay": "Cannot take any action",
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
		text += "[hint=%s][img]%s[/img][/hint] %d " % [
			DESCRIPTIONS[effect],
			EFFECT_ICON_PATHS[effect],
			statuses[effect],
		]
		if vertical:
			text += "\n"
