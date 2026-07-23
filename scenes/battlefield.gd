class_name BattlefieldLogic
extends Node

var allow_player_action := true

func player_action(action: ActionResource) -> void:
	if not allow_player_action:
		return
	prints("Player", action.name)
