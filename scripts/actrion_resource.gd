class_name ActionResource
extends Resource

@export 
var name := ""

@export_multiline 
var description := ""

@export_category("Stats")
@export var damage := 0
@export var heal := 0
@export var block := 0

func is_available(progression_tracker) -> bool:
	return true
