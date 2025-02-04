@tool
## The [LokStorageAccessor] is a node specialized in saving and loading data.
## 
## This class should have its [method save_data] and [method load_data] methods
## overwritten in order for them to respectively save and load data. [br]
## Those methods are called by the [LokGlobalStorageManager] in order to get
## or retrieve data from save files.
## [br]
## [b][color=orange]WARNING:[/color][/b]
## In order for that to happen, the [LokGlobalStorageManager] has to keep
## track of this node. That's achievable because this [LokStorageAccessor]
## adds and removes itself from the [LokGlobalStorageManager] on entering and
## on exiting the node tree using the [method _enter_tree]
## and [method _exit_tree] methods. [br]
## That means these methods, if overriden, must have their super implementations
## called in order for this node to work properly.
class_name LokStorageAccessor
extends Node

signal id_changed(from: String, to: String)

@export var versions: Array[LokStorageAccessorVersion] = []:
	set = set_versions

@export var version_number: String = "1.0.0":
	set = set_version_number

@export var dependencies: Dictionary = {}

var version: LokStorageAccessorVersion:
	set = set_version

func set_versions(new_versions: Array[LokStorageAccessorVersion]) -> void:
	versions = new_versions
	
	version = find_version(version_number)

func set_version_number(new_number: String) -> void:
	var old_number: String = version_number
	
	version_number = new_number
	
	if old_number != new_number:
		version = find_version(new_number)

func set_version(new_version: LokStorageAccessorVersion) -> void:
	var old_version: LokStorageAccessorVersion = version
	
	version = new_version
	
	if old_version == new_version:
		return
	
	if old_version != null:
		if old_version.id_changed.is_connected(_on_version_id_changed):
			old_version.id_changed.disconnect(_on_version_id_changed)
		if not new_version.id_changed.is_connected(_on_version_id_changed):
			new_version.id_changed.connect(_on_version_id_changed)
	
	update_configuration_warnings()

func get_id() -> String:
	if version == null:
		return ""
	
	return version.id

#func instantiate_version(
	#number: String = version_number
#) -> LokStorageAccessorVersion:
	#var version_script: GDScript = versions.get(number)
	#
	#if version_script == null:
		#return null
	#
	#var result: Object = version_script.new()
	#
	#if result is not LokStorageAccessorVersion:
		#return null
	#
	#return result

func find_version(
	number: String = version_number
) -> LokStorageAccessorVersion:
	for version: LokStorageAccessorVersion in versions:
		if version.number == number:
			return version
	
	return null

func select_version(number: String) -> bool:
	version_number = number
	
	var found: bool = version != null
	
	return found

func get_dependency_nodes() -> Dictionary:
	var result: Dictionary = {}
	
	for key: Variant in dependencies:
		var value: Variant = dependencies[key]
		
		if value is NodePath:
			result[key] = get_node(value)
		else:
			result[key] = value
	
	return result

func save_data(file_id: int, version_number: String = "1.0.0") -> Dictionary:
	return LokGlobalStorageManager.save_data(
		file_id, version_number, [ get_id() ]
	)

func load_data(file_id: int) -> Dictionary:
	return LokGlobalStorageManager.load_data(
		file_id, [ get_id() ]
	)

func retrieve_data() -> Dictionary:
	if version == null:
		return {}
	
	return version.retrieve_data(get_dependency_nodes())

func consume_data(data: Dictionary) -> void:
	if version == null:
		return
	
	version.consume_data(data, get_dependency_nodes())

func _init() -> void:
	version = find_version(version_number)

#func _ready() -> void:
	#update_configuration_warnings()

func _enter_tree() -> void:
	LokGlobalStorageManager.add_accessor(self)

func _exit_tree() -> void:
	LokGlobalStorageManager.remove_accessor(self)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	if version == null:
		warnings.append("Set a valid version number for this Accessor to use.")
	if get_id() == "":
		warnings.append("To work properly, you must set a unique id to this Storage Accessor.")
	
	return warnings

func _on_version_id_changed(from: String, to: String) -> void:
	id_changed.emit(from, to)
	
	update_configuration_warnings()
