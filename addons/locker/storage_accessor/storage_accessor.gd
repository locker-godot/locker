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

var storage_manager := LokGlobalStorageManager:
	set = set_storage_manager,
	get = get_storage_manager

@export var versions: Array[LokStorageAccessorVersion] = []:
	set = set_versions,
	get = get_versions

@export var version_number: String = "1.0.0":
	set = set_version_number,
	get = get_version_number

@export var dependency_paths: Dictionary = {}:
	set = set_dependency_paths,
	get = get_dependency_paths

var version: LokStorageAccessorVersion:
	set = set_version,
	get = get_version

#region Setters & Getters

func set_storage_manager(new_manager: LokGlobalStorageManager) -> void:
	storage_manager = new_manager

func get_storage_manager() -> LokGlobalStorageManager:
	return storage_manager

func set_versions(new_versions: Array[LokStorageAccessorVersion]) -> void:
	versions = new_versions
	
	version = find_version(version_number)

func get_versions() -> Array[LokStorageAccessorVersion]:
	return versions

func set_version_number(new_number: String) -> void:
	var old_number: String = version_number
	
	version_number = new_number
	
	if old_number != new_number:
		if new_number == "":
			version = find_latest_version()
		else:
			version = find_version(new_number)

func get_version_number() -> String:
	return version_number

func set_dependency_paths(new_paths: Dictionary) -> void:
	dependency_paths = new_paths

func get_dependency_paths() -> Dictionary:
	return dependency_paths

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

func get_version() -> LokStorageAccessorVersion:
	return version

func set_id(new_id: String) -> void:
	if version == null:
		return
	
	version.id = new_id

func get_id() -> String:
	if version == null:
		return ""
	
	return version.id

func get_dependencies() -> Dictionary:
	var result: Dictionary = {}
	
	for dependency_name: Variant in dependency_paths:
		var dependency_path: Variant = dependency_paths[dependency_name]
		
		if dependency_path is NodePath:
			result[dependency_name] = get_node(dependency_path)
		else:
			result[dependency_name] = dependency_path
	
	return result

#endregion

#region Methods

static func create(
	_versions: Array[LokStorageAccessorVersion],
	_version_number: String,
	_storage_manager: LokGlobalStorageManager
) -> LokStorageAccessor:
	var result := LokStorageAccessor.new()
	result.storage_manager = _storage_manager
	result.versions = _versions
	result.version_number = _version_number
	
	return result

func find_version(
	number: String = version_number
) -> LokStorageAccessorVersion:
	for version: LokStorageAccessorVersion in versions:
		if version.number == number:
			return version
	
	return null

func find_latest_version() -> LokStorageAccessorVersion:
	var reducer: Callable = func(
		prev: LokStorageAccessorVersion,
		next: LokStorageAccessorVersion
	) -> LokStorageAccessorVersion:
		if LokStorageAccessorVersion.compare_versions(prev, next) == 1:
			return prev
		else:
			return next
	
	return versions.reduce(reducer)

func select_version(number: String) -> bool:
	set_version_number(number)
	
	var found_version: bool = version != null
	
	return found_version

func save_data(
	file_id: int,
	version_number: String = "1.0.0",
	remover: Callable = LokStorageManager.default_remover
) -> Dictionary:
	if storage_manager == null:
		return {}
	
	return storage_manager.save_data(
		file_id, version_number, [ get_id() ], false, remover
	)

func load_data(file_id: int) -> Dictionary:
	if storage_manager == null:
		return {}
	
	return storage_manager.load_data(
		file_id, [ get_id() ]
	)

func retrieve_data() -> Dictionary:
	if version == null:
		return {}
	
	return version.retrieve_data(get_dependencies())

func consume_data(data: Dictionary) -> void:
	if version == null:
		return
	
	version.consume_data(data, get_dependencies())

func _init() -> void:
	version = find_version(version_number)

func _enter_tree() -> void:
	if storage_manager == null:
		return
	
	storage_manager.add_accessor(self)

func _exit_tree() -> void:
	if storage_manager == null:
		return
	
	storage_manager.remove_accessor(self)

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

#endregion
