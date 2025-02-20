
class_name DynamicMultiplayerPlayer
extends Node2D

const SPEED: float = 256.0

@export var inputs: Dictionary = {
	"up": "player1_up",
	"right": "player1_right",
	"down": "player1_down",
	"left": "player1_left"
}

func _process(delta: float) -> void:
	global_position += Input.get_vector(
		inputs["left"], inputs["right"], inputs["up"], inputs["down"]
	) * SPEED * delta
