class_name Pendulum
extends TextureProgressBar

@export
var initial_mana: int = 6
@export
var max_mana: int = 10

# Alias for value
var player_mana: int:
	get(): return value
	set(x): value = x

# Tied to Mana
var enemy_mana:
	get(): return max_mana - value

func _ready() -> void:
	min_value = 0
	max_mana = max_mana
	value = initial_mana
