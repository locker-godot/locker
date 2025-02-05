
class_name LokAccessStrategy
extends Resource

static func create_directory(directory: String) -> bool:
	var err: Error = DirAccess.make_dir_recursive_absolute(directory)
	
	if err != OK:
		push_error("Unable to create directory: '%s'" % directory)
		
		return false
	
	return true

static func check_directory(
	directory: String, suppress_error: bool = false
) -> bool:
	if not DirAccess.dir_exists_absolute(directory):
		if not suppress_error:
			push_error("Directory not found: '%s'" % directory)
		
		return false
	
	return true

static func check_and_create_directory(directory: String) -> bool:
	if not check_directory(directory, true):
		return create_directory(directory)
	
	return true

func save_data(
	_file_id: int,
	_data: Dictionary,
	_replace: bool = false,
	_remover: Callable = LokStorageManager.default_remover,
	_suppress_errors: bool = false
) -> Dictionary: return {}

func load_data(
	_file_id: int,
	_suppress_errors: bool = false
) -> Dictionary: return {}
