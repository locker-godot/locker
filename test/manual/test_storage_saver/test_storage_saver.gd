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
	

@onready var saver: LokStorageSaver = $Saver

func retrieve_data() -> void:
	saver.version = VersionTest.new()
	
	var data: Dictionary = saver.retrieve_data()
	
	print(data)

func consume_data() -> void:
	saver.version = VersionTest.new()
	
	saver.consume_data({
		"a": 1,
		"b": 2,
		"c": 3
	})
	
	var data: Dictionary = saver.version.data
	
	print(data)

func load_data() -> void:
	saver.version = VersionTest.new()
	
	var data: Dictionary = saver.load_data("1")
	
	print(data)

func _ready() -> void:
	load_data()
