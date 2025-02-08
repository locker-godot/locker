extends Node

@onready var accessor: LokStorageAccessor = $Accessor

class VersionTest extends LokStorageAccessorVersion:
	
	var data: Dictionary = {}
	
	func retrieve_data(_dep: Dictionary) -> Dictionary:
		return {
			"a": 1,
			"b": 2,
			"c": 3
		}
	
	func consume_data(_data: Dictionary, _dep: Dictionary) -> void:
		data = _data
	

func version_number_setter() -> void:
	#accessor.versions = [
		#LokStorageAccessorVersion.create("2.1.2"),
		#LokStorageAccessorVersion.create("1.0.1")
	#]
	#accessor.versions.append(LokStorageAccessorVersion.create("2.1.2"))
	#accessor.versions.append(LokStorageAccessorVersion.create("1.0.0"))
	#accessor.update_version()
	
	print(accessor.version_number)
	print(accessor.version)

func find_latest_version() -> void:
	var result: String
	
	accessor.versions.append(LokStorageAccessorVersion.create("2.1.2"))
	accessor.versions.append(LokStorageAccessorVersion.create("1.0.0"))
	accessor.versions.append(LokStorageAccessorVersion.create("2.1.1"))
	accessor.versions.append(LokStorageAccessorVersion.create("1.1.0"))
	accessor.versions.append(LokStorageAccessorVersion.create("1.1.1"))
	
	result = accessor.find_latest_version().number
	
	print(result)

func retrieve_data() -> void:
	var version: LokStorageAccessorVersion = VersionTest.new()
	
	accessor.versions = [ version ]
	accessor.active = false
	
	var result: Dictionary = accessor.retrieve_data()
	
	print(result)

func consume_data() -> void:
	var version: LokStorageAccessorVersion = VersionTest.new()
	
	accessor.versions = [ version ]
	accessor.active = false
	
	accessor.consume_data({
		"a": 1,
		"b": 2,
		"c": 3
	})
	
	var result: Dictionary = accessor.version.data
	
	print(result)

func _ready() -> void:
	consume_data()
