class_name ActionButton
extends TextureButton

var resource: ActionResource = null

func _ready() -> void:
	$Label.text = resource.name
