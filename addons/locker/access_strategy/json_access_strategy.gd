
class_name LokJSONAccessStrategy
extends LokAccessStrategy

func save_partition(
	partition_path: String,
	data: Dictionary,
	replace: bool = false,
	suppress_errors: bool = false
) -> Dictionary:
	var creation_succeded: bool = check_and_create_file(
		partition_path, "", suppress_errors
	)
	
	if not creation_succeded:
		return {}
	
	var result: Dictionary = data
	var previous_data: Dictionary = {}
	
	if not replace:
		previous_data = load_partition(partition_path, true)
	
	result = data.merged(previous_data)
	
	var writing_succeded: bool = write_or_create_file(
		partition_path, JSON.stringify(result, "\t"), suppress_errors
	)
	
	if not writing_succeded:
		return {}
	
	return result

func load_partition(
	partition_path: String,
	suppress_errors: bool = false
) -> Dictionary:
	if not check_file(partition_path, suppress_errors):
		return {}
	
	var partition_content: String = read_file(
		partition_path, suppress_errors
	)
	var data: Variant = JSON.parse_string(partition_content)
	
	if data == null:
		if not suppress_errors:
			push_error(
				"Couldn't parse JSON data from partition '%s'" % partition_path
			)
		
		return {}
	
	return data
