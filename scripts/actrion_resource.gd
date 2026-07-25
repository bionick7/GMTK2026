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
@export var is_buff: bool = false
@export var is_debuff: bool = false

@export var statuses := []

static func from_dict(data: Dictionary[String, Variant]) -> ActionResource:
	var res := ActionResource.new()
	res.name = data["SKILL"]
	res.description = data.get("DESCRIPTION", "")
	res.category = data.get("CATEGORY", "None")
	res.cost = data.get("COST", 0)
	res.damage = data.get("DAMAGE", 0)
	res.heal = data.get("HEALTH", 0)
	res.block = data.get("BLOCK", 0)
	
	var effects_inp = data.get("EFFECT", [])
	var delays_inp = data.get("DURATION", [])
	#printt(effects_inp, delays_inp)
	
	if effects_inp is Array and delays_inp is Array:
		assert(len(effects_inp) == len(delays_inp))
		for i in range(len(effects_inp)):
			res.statuses.append({
				effect=effects_inp[i],
				duration=int(delays_inp[i]),
			})
	elif effects_inp is not Array and delays_inp is not Array:
		res.statuses = [{
			effect=str(effects_inp),
			duration=int(delays_inp),
		}]
		
	for status in res.statuses:
		if status.effect in ["double_action", "double_damage", "heal(2)", "no_mana"]:
			if status.duration < 0:
				res.is_buff = true
			elif status.duration > 0:
				res.is_debuff = true
		if status.effect in ["double_mana", "delay"] or status.effect.begins_with("poison"):
			if status.duration < 0:
				res.is_debuff = true
			elif status.duration > 0:
				res.is_buff = true
	
	return res

func is_available(progression_tracker) -> bool:
	# TODO: Check if tracker is accessible
	return true

func get_label() -> String:
	return "%s (%d)\n" % [name, cost]
	
func display() -> String:
	var res := ""
	#res += "---------------\n"
	res += "%s (%d)\n" % [name, cost]
	res += "D %d H %d B %d\n" % [damage, heal, block]
	for status in statuses:
		res += "%s [%d] ; " % [status.effect, status.duration]
	res += "\n"
	res += description + "\n"
	#res += "---------------\n"
	return res
