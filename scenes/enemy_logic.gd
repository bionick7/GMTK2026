class_name EnemyLogic
extends Node

const ENEMY_SKILLS_DATA := "res://..."

signal enemy_turn_ended
signal enemy_action(action: ActionResource)

@onready var pendulum = %Pendulum

func run():
	# TODO: Enemy logic
	enemy_turn_ended.emit()
