class_name EnemyPlayerBase
extends Node

@export var max_hp: int = 100
@export var block := 0
@export var delay := 0

@onready var hp := max_hp

var statuses: Dictionary[String, int] = {}

signal die

func take_damage(x: int) ->  void:
	if block > 0 and block > x:
		block -= x
		return
	elif block > 0:
		x -= block
		block = 0
	
	if hp - x <= 0:
		die.emit()
	hp = clampi(hp - x, 0, max_hp)

func heal(x: int) ->  void:
	if hp + x <= 0:
		die.emit()
	hp = clampi(hp + x, 0, max_hp)

func apply_block(c: int) -> void:
	# Block can be negative
	block = max(block + c, 0)

func apply_status(c: int, effect: String) -> void:
	if effect in statuses:
		statuses[effect] = max(0, statuses[effect] + c)
	else:
		statuses[effect] = max(0, c)

func tick_delay() -> void:
	for status_key in statuses:
		statuses[status_key] -= 1
		if statuses[status_key] <= 0:
			statuses.erase(status_key)

func serialize() -> Dictionary:
	return {
		hp = hp,
		block = block,
		delay = delay,
		statuses = statuses,
	}

func deserialize(data: Dictionary) -> void:
	hp = data.hp
	block = data.block
	delay = data.delay
	statuses = data.statuses
