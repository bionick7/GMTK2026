class_name Clock
extends Sprite2D

const ROWS: int = 2
const MAX_STATE: int = 5

@export var entity: EnemyPlayerBase

func  _ready() -> void:
	if texture is not AtlasTexture:
		printerr("Texture of clock must be AtlasTexture")
		
func _process(delta: float) -> void:
	visible = entity.delay != 0
	set_clock_to_state(entity.delay)
	#set_clock_to_state(floori(get_tree().get_frame() / 20) % 5)

func set_clock_to_state(state: int) -> void:
	var row := floori(min(state, MAX_STATE) % ROWS)
	var col := floori(min(state, MAX_STATE) / ROWS)
	#prints(state, row, col)
	(texture as AtlasTexture).region = Rect2(
		row * 32, col * 32, 32, 32
	)
