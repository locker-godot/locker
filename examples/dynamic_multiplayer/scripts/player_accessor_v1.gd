
class_name DynamicPlayerAccessorV1
extends LokStorageAccessorVersion

func retrieve_data(deps: Dictionary) -> Dictionary:
	var player: Node2D = deps.get(&"player")
	
	var data: Dictionary = {}
	
	if player != null:
		data["position"] = var_to_str(player.global_position)
	
	return data

func consume_data(res: Dictionary, deps: Dictionary) -> void:
	var player: Node2D = deps.get(&"player")
	
	var data: Dictionary = res.get("data", {})
	
	if player != null and data.has("position"):
		player.global_position = str_to_var(data["position"])
