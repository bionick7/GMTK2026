class_name ActionResource
extends Resource

@export 
var name := ""

@export_multiline 
var description := ""

func is_available(progression_tracker) -> bool:
	return true
