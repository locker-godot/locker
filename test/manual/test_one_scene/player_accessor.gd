@tool
extends LokStorageAccessor

@onready var player: Sprite2D = $".."

func save_data() -> Dictionary:
	return {
		"position": var_to_str(player.global_position)
	}

func load_data(data: Dictionary) -> void:
	if data.has("position"):
		player.global_position = str_to_var(data["position"])
