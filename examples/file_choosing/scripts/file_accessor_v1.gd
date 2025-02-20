
class_name FileChoosingFileAccessorV1
extends LokStorageAccessorVersion

func retrieve_data(_deps: Dictionary) -> Dictionary:
	return {
		"lives": randi_range(0, 10),
		"progress": randf()
	}

func consume_data(res: Dictionary, deps: Dictionary) -> void:
	var file: FileCard = deps.get(&"file_card")
	
	if file == null:
		return
	
	if res.get("status", Error.OK) != Error.OK:
		file.setup_as_new_file()
		return
	
	var data: Dictionary = res.get("data", {})
	
	var lives_amount: int = data.get("lives", 0)
	var progress_amount: float = data.get("progress", 0.0)
	
	file.setup_as_used_file(lives_amount, progress_amount)
