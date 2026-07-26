extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_custom_mouse_cursor(load("res://assets/sprites/UI/Cursor/cursor_normal.png"))
	Input.set_custom_mouse_cursor(load("res://assets/sprites/UI/Cursor/cursor_hover.png"), Input.CURSOR_POINTING_HAND)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	if Input.CursorShape.CURSOR_POINTING_HAND:
#		if Input.is_action_pressed("clicking"):
#			Input.set_custom_mouse_cursor(load("res://assets/sprites/UI/Cursor/cursor_click.png"), Input.CURSOR_POINTING_HAND)
#	else:
#			Input.set_custom_mouse_cursor(load("res://assets/sprites/UI/Cursor/cursor_normal.png"))
