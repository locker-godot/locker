@tool
class_name PlayerAccessorV2_0_0
extends LokStorageAccessorVersion

func retrieve_data(dependencies: Dictionary) -> Dictionary:
	var player: Sprite2D = dependencies.get("player")
	
	if player == null:
		return {}
	
	return {
		"position": var_to_str(player.global_position),
		"color": var_to_str(player.modulate)
	}

func consume_data(
	data: Dictionary,
	dependencies: Dictionary
) -> void:
	var player: Sprite2D = dependencies.get("player")
	
	if player == null:
		return
	
	if data.has("position"):
		player.global_position = str_to_var(data["position"])
	if data.has("color"):
		player.modulate = str_to_var(data["color"])
