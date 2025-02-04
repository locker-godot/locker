
class_name LokJSONAccessStrategy
extends LokAccessStrategy

func save_data(
	file_id: int,
	data: Dictionary,
	version_number: String = "1.0.0",
	suppress_errors: bool = false
) -> Dictionary:
	var save_path: String = LockerPlugin.get_save_path(file_id)
	
	var file: FileAccess
	
	if not FileAccess.file_exists(save_path):
		file = FileAccess.open(save_path, FileAccess.WRITE)
		file.close()
	
	var file_data: Dictionary = load_data(file_id, true)
	
	var result: Dictionary = data.merged(file_data)
	
	result["version"] = version_number
	
	file = FileAccess.open(save_path, FileAccess.WRITE)
	
	if file == null:
		if not suppress_errors:
			push_error(
				"Error on saving data: %s" % [ FileAccess.get_open_error() ]
			)
		
		return {}
	
	file.store_string(JSON.stringify(result, "\t"))
	
	file.close()
	
	return result

func load_data(
	file_id: int,
	suppress_errors: bool = false
) -> Dictionary:
	var save_path: String = LockerPlugin.get_save_path(file_id)
	
	if not FileAccess.file_exists(save_path):
		if not suppress_errors:
			push_error("File %d not found in path %s" % [ file_id, save_path ])
		
		return {}
	
	var file := FileAccess.open(save_path, FileAccess.READ)
	
	if file == null:
		if not suppress_errors:
			push_error(
				"Error on loading data: %s" % [ FileAccess.get_open_error() ]
			)
		
		return {}
	
	var file_content: String = file.get_as_text()
	
	file.close()
	
	var data: Variant = JSON.parse_string(file_content)
	
	if data == null:
		if not suppress_errors:
			push_error("Couldn't parse JSON data")
		
		return {}
	
	return data
