
class_name SimpleTopdownPlayerAccessorV1
extends LokStorageAccessorVersion

func retrieve_data(deps: Dictionary) -> Dictionary:
	var player: Sprite2D = deps.get(&"player")
	
	if player == null:
		return {}
	
	return {
		"position": var_to_str(player.global_position),
		"color": var_to_str(player.modulate)
	}

func consume_data(res: Dictionary, deps: Dictionary) -> void:
	var player: Sprite2D = deps.get(&"player")
	
	if player == null:
		return
	
	var data: Dictionary = res.get("data", {})
	
	if data.get("position") != null:
		player.global_position = str_to_var(data.get("position"))
	if data.get("color") != null:
		player.modulate = str_to_var(data.get("color"))
