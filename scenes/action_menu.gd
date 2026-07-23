extends Control

@export
var background_image: Texture2D

@export
var actions: Array[ActionResource] = []

func _ready() -> void:
	$BG.texture = background_image
	
