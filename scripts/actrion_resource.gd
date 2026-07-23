class_name ActionResource
extends Resource

@export 
var name := ""

@export_multiline 
var description := ""
@export var cost := 1
@export_enum("Fight", "Heal", "Block", "None") var category := "None"

@export_category("Stats")
@export var damage: int = 0
@export var heal: int = 0
@export var block: int = 0
@export var delay: int = 0

static func from_dict(data: Dictionary[String, Variant]) -> ActionResource:
	var res := ActionResource.new()
	res.name = data["SKILL"]
	res.description = data["DESCRIPTION"]
	res.category = data.get("CATEGORY", "None")
	res.cost = data["COST"]
	res.damage = data.get("DAMMAGE", 0)
	res.heal = data.get("HEALTH", 0)
	res.block = data.get("BLOCK", 0)
	res.delay = data.get("DELAY", 0)
	return res
	

func is_available(progression_tracker) -> bool:
	return true

func get_label() -> String:
	return "%s (%d)\n" % [name, cost]

func display() -> String:
	var res := ""
	#res += "---------------\n"
	res += "%s (%d)\n" % [name, cost]
	res += "D %d H %d B %d Dly %d\n" % [damage, heal, block, delay]
	res += description + "\n"
	#res += "---------------\n"
	return res
