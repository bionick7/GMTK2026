class_name EnemyType
extends Resource

@export var enemy_name: String = "ENEMY"
@export_multiline var description: String = "NOT YET USED"
@export var icon: Texture2D

@export_range(0, 200, 1, "or_greater") var hp := 100
