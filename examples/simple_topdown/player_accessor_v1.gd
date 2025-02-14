
class_name PlayerAccessorV1
extends LokStorageAccessorVersion

func retrieve_data(deps: Dictionary) -> Dictionary:
	var player: Sprite2D = deps.get(&"player")
	
	if player == null:
		return {}
	
	return {
		"position": var_to_str(player.global_position),
		"color": var_to_str(player.modulate)
	}

func consume_data(data: Dictionary, deps: Dictionary) -> void:
	var player: Sprite2D = deps.get(&"player")
	
	if player == null:
		return
	
	if data.get("position") != null:
		player.global_position = str_to_var(data.get("position"))
	if data.get("color") != null:
		player.modulate = str_to_var(data.get("color"))
