class_name EnemyPlayerBase
extends Node

@export var max_hp: int = 100
@export var block := 0
@export var delay := 0

@onready var hp := max_hp

signal die

func take_damage(x: int) ->  void:
	if block > x:
		block -= x
		return
	elif block > 0:
		x -= block
		block = 0
	
	if hp - x < 0:
		die.emit()
	hp = clampi(hp - x, 0, max_hp)

func heal(x: int) ->  void:
	if hp + x < 0:
		die.emit()
	hp = clampi(hp + x, 0, max_hp)

func apply_block(c: int) -> void:
	# Block can be negative
	block = max(block + c, 0)

func apply_delay(c: int) -> void:
	delay = clamp(delay + c, 0, 4)

func tick_delay() -> void:
	delay = max(delay - 1, 0)
