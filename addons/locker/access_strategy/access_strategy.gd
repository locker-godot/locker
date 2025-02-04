
class_name LokAccessStrategy
extends Resource

func save_data(
	_file_id: int,
	_data: Dictionary,
	_version_number: String = "1.0.0",
	_suppress_errors: bool = false
) -> Dictionary: return {}

func load_data(
	_file_id: int,
	_suppress_errors: bool = false
) -> Dictionary: return {}
