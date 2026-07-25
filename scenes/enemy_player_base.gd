class_name EnemyPlayerBase
extends Node

@export var max_hp: int = 100
@export var block := 0

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

func has_status(effect: String) -> bool:
	return statuses.get(effect, 0) > 0

func evaluate_stats():
	# Check for statuses
	if has_status("heal(2)"):
		heal(2)
	if has_status("poison(1)"):
		take_damage(1)
	if has_status("poison(2)"):
		take_damage(2)
	if has_status("poison(4)"):
		take_damage(4)
	if has_status("poison(5)"):
		take_damage(5)

func serialize() -> Dictionary:
	return {
		hp = hp,
		block = block,
		statuses = statuses,
	}

func deserialize(data: Dictionary) -> void:
	hp = data.hp
	block = data.block
	statuses = data.statuses
