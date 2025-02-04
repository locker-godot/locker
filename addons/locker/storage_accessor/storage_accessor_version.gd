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

static func create(_number: String, _id: String) -> LokStorageAccessorVersion:
	var result := LokStorageAccessorVersion.new()
	result.number = _number
	result.id = _id
	
	return result

static func compare_versions(
	version1: LokStorageAccessorVersion,
	version2: LokStorageAccessorVersion
) -> int:
	return version1.number.naturalnocasecmp_to(version2.number)

static func compare_minor_versions(
	version1: LokStorageAccessorVersion,
	version2: LokStorageAccessorVersion
) -> int:
	var minor_version1: String = version1.number.get_slice(".", 2)
	var minor_version2: String = version2.number.get_slice(".", 2)
	
	return minor_version1.naturalnocasecmp_to(minor_version2)

static func compare_patch_versions(
	version1: LokStorageAccessorVersion,
	version2: LokStorageAccessorVersion
) -> int:
	var patch_version1: String = version1.number.get_slice(".", 1)
	var patch_version2: String = version2.number.get_slice(".", 1)
	
	return patch_version1.naturalnocasecmp_to(patch_version2)

static func compare_major_versions(
	version1: LokStorageAccessorVersion,
	version2: LokStorageAccessorVersion
) -> int:
	var major_version1: String = version1.number.get_slice(".", 0)
	var major_version2: String = version2.number.get_slice(".", 0)
	
	return major_version1.naturalnocasecmp_to(major_version2)

func retrieve_data(_dependencies: Dictionary) -> Dictionary: return {}

func consume_data(
	_data: Dictionary,
	_dependencies: Dictionary
) -> void: pass
