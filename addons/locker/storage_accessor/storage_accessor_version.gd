@tool
class_name LokStorageAccessorVersion
extends Resource

signal id_changed(from: String, to: String)

@export var number: String = "1.0.0"

@export var id: String:
	set = set_id

func set_id(new_id: String) -> void:
	var old_id: String = id
	
	id = new_id
	
	if old_id != new_id:
		id_changed.emit(old_id, new_id)

static func compare_versions(
	version1: LokStorageAccessorVersion,
	version2: LokStorageAccessorVersion
) -> bool:
	return version1.number.naturalnocasecmp_to(version2.number)

func retrieve_data(_dependencies: Dictionary) -> Dictionary: return {}

func consume_data(
	_data: Dictionary,
	_dependencies: Dictionary
) -> void: pass
