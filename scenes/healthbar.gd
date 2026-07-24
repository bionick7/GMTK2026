extends Range

@export var target: EnemyPlayerBase
@onready var shield = $Shield

func _process(delta: float) -> void:
	value = target.hp
	max_value = target.max_hp
	if is_instance_valid(shield):
		shield.value = target.block
		shield.max_value = target.max_hp
