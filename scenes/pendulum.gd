class_name Pendulum
extends TextureProgressBar

@export
var initial_mana: int = 6
@export
var max_mana: int = 10

@onready var counter: RichTextLabel = $counter

# Alias for value
var player_mana: int:
	get(): return int(value)
	#set(x): value = x

# Tied to Mana
var enemy_mana:
	get(): return max_mana - value

func _process(delta: float) -> void:
	counter.text = str(max_mana,"/",value as int)


func _ready() -> void:
	min_value = 0
	max_value = max_mana
	value = initial_mana
	


func use_player_mana(x: int) -> void:
	value -= x
	
func use_enemy_mana(x: int) -> void:
	value += x
