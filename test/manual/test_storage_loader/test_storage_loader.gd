extends Node

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
	

@onready var loader: LokStorageLoader = $Loader

func retrieve_data() -> void:
	loader.version = VersionTest.new()
	
	var data: Dictionary = loader.retrieve_data()
	
	print(data)

func consume_data() -> void:
	loader.version = VersionTest.new()
	
	loader.consume_data({
		"a": 1,
		"b": 2,
		"c": 3
	})
	
	var data: Dictionary = loader.version.data
	
	print(data)

func save_data() -> void:
	loader.version = VersionTest.new()
	
	var data: Dictionary = loader.save_data("1")
	
	print(data)

func _ready() -> void:
	save_data()
