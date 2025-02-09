
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
		data["version"] = number
	

class SquareVersion1Test extends LokStorageAccessorVersion:
	
	var data: Dictionary = {}
	
	func _init() -> void:
		number = "1.0.0"
	
	func retrieve_data(_dep: Dictionary) -> Dictionary:
		return {
			"points": 4,
			"faces": 1,
			"lines": 4
		}
	
	func consume_data(_data: Dictionary, _dep: Dictionary) -> void:
		data = _data
		data["version"] = number
	

class CircleVersion1Test extends LokStorageAccessorVersion:
	
	var data: Dictionary = {}
	
	func _init() -> void:
		number = "1.2.0"
	
	func retrieve_data(_dep: Dictionary) -> Dictionary:
		return {
			"points": 0,
			"faces": 1,
			"lines": 1
		}
	
	func consume_data(_data: Dictionary, _dep: Dictionary) -> void:
		data = _data
		data["version"] = number
	

class CubeVersion1Test extends LokStorageAccessorVersion:
	
	var data: Dictionary = {}
	
	func _init() -> void:
		number = "1.0.2"
	
	func retrieve_data(_dep: Dictionary) -> Dictionary:
		return {
			"points": 8,
			"faces": 6,
			"lines": 12
		}
	
	func consume_data(_data: Dictionary, _dep: Dictionary) -> void:
		data = _data
		data["version"] = number
	

class CillinderVersion1Test extends LokStorageAccessorVersion:
	
	var data: Dictionary = {}
	
	func _init() -> void:
		number = "3.0.0"
	
	func retrieve_data(_dep: Dictionary) -> Dictionary:
		return {
			"points": 0,
			"faces": 3,
			"lines": 2
		}
	
	func consume_data(_data: Dictionary, _dep: Dictionary) -> void:
		data = _data
		data["version"] = number
	

@onready var accessor1: LokStorageAccessor = $Accessor1
@onready var accessor2: LokStorageAccessor = $Accessor2

@onready var square_accessor: LokStorageAccessor = $SquareAccessor
@onready var circle_accessor: LokStorageAccessor = $CircleAccessor
@onready var cube_accessor: LokStorageAccessor = $CubeAccessor
@onready var cillinder_accessor: LokStorageAccessor = $CillinderAccessor

func accessors() -> void:
	print(LokGlobalStorageManager.accessors)

func collect_data() -> void:
	var version := VersionTest.new()
	version.number = "1.0.1"
	
	accessor1.versions = [ version ]
	
	var result: Dictionary = LokGlobalStorageManager.collect_data(accessor1)
	
	print(result)

func gather_data() -> void:
	var version1 := VersionTest.new()
	version1.number = "1.0.1"
	var version2 := VersionTest.new()
	version2.number = "1.2.1"
	
	accessor1.versions = [ version1 ]
	accessor1.id = "accessor1"
	accessor1.partition = "partition1"
	accessor2.versions.append(version2)
	accessor2.partition = "partition2"
	accessor2.id = "accessor2"
	
	var result: Dictionary = LokGlobalStorageManager.gather_data(
		[ "accessor1" ], "1.0.1"
	)
	
	print(result)

func distribute_data() -> void:
	var version1 := VersionTest.new()
	version1.number = "1.0.1"
	var version2 := VersionTest.new()
	version2.number = "1.2.1"
	
	accessor1.versions = [ version1 ]
	accessor1.id = "accessor1"
	accessor2.versions = [ version2 ]
	accessor2.id = "accessor1"
	
	LokGlobalStorageManager.distribute_data({
		"accessor1": {
			"version": "",
			"a": 1,
			"b": 2,
			"c": 3
		},
		"accessor2": {
			"version": "",
			"a": 1,
			"b": 2,
			"c": 3
		}
	})
	
	if accessor1.version != null:
		print(accessor1.version.data)
	if accessor2.version != null:
		print(accessor2.version.data)

func save_data() -> void:
	var version1 := VersionTest.new()
	version1.number = "1.0.1"
	var version2 := VersionTest.new()
	version2.number = "1.2.1"
	
	accessor1.versions = [ version1 ]
	accessor1.id = "accessor1"
	accessor1.partition = "partition1"
	accessor2.versions.append(version2)
	accessor2.id = "accessor2"
	accessor2.partition = "partition2"
	
	var result: Dictionary = LokGlobalStorageManager.save_data(
		"test1"
	)
	
	print(result)

func read_data() -> void:
	var result: Dictionary = LokGlobalStorageManager.read_data(
		"test1", [ "accessor2" ], [ "partition2" ], [ "1.2.1" ]
	)
	
	print(result)

func save_data_shapes() -> void:
	accessor1.active = false
	accessor2.active = false
	
	square_accessor.id = "square"
	square_accessor.partition = "2d"
	square_accessor.versions = [ SquareVersion1Test.new() ]
	square_accessor.version_number = "1.0.0"
	
	circle_accessor.id = "circle"
	circle_accessor.partition = "2d"
	circle_accessor.versions = [ CircleVersion1Test.new() ]
	circle_accessor.version_number = "1.2.0"
	
	cube_accessor.id = "cube"
	cube_accessor.partition = "3d"
	cube_accessor.versions = [ CubeVersion1Test.new() ]
	cube_accessor.version_number = "1.0.2"
	
	cillinder_accessor.id = "cillinder"
	cillinder_accessor.partition = "3d"
	cillinder_accessor.versions = [ CillinderVersion1Test.new() ]
	cillinder_accessor.version_number = "3.0.0"
	
	var result: Dictionary = LokGlobalStorageManager.save_data(
		"shapes"
	)
	
	print(result)

func _ready() -> void:
	save_data_shapes()
