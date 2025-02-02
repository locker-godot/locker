extends Node2D

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	global_position += Input.get_vector(
		"left", "right", "up", "down"
	) * 256.0 * delta
