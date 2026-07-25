class_name EnemyType
extends Resource

@export var enemy_name: String = "ENEMY"
@export_multiline var description: String = "NOT YET USED"
@export var icon: Texture2D

@export_range(0, 200, 1, "or_greater") var hp := 100
@export_flags("F 1", "F 2", "F 3", "F 4", "F 5") var levels: int
