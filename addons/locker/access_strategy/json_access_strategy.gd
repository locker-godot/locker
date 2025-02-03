
class_name LokJSONAccessStrategy
extends LokAccessStrategy

func save_data(file_id: int, data: Dictionary) -> Dictionary:
	var save_path: String = LokGlobalStorageManager.get_save_path(file_id)
	
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	
	if file == null:
		push_error("Error on saving data: %s" % [ FileAccess.get_open_error() ])
		return {}
	
	file.store_string(JSON.stringify(data, "\t"))
	
	file.close()
	
	return data

func load_data(file_id: int) -> Dictionary:
	var save_path: String = LokGlobalStorageManager.get_save_path(file_id)
	
	if not FileAccess.file_exists(save_path):
		push_error("File %d not found in path %s" % [ file_id, save_path ])
		return {}
	
	var file := FileAccess.open(save_path, FileAccess.READ)
	
	if file == null:
		push_error("Error on loading data: %s" % [ FileAccess.get_open_error() ])
		return {}
	
	var file_content: String = file.get_as_text()
	
	file.close()
	
	var data: Dictionary = JSON.parse_string(file_content)
	
	if data == null:
		push_error("Couldn't parse JSON data")
		return {}
	
	return data
