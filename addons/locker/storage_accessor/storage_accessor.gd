@icon("res://addons/locker/icons/storage_accessor.svg")
@tool
## The [LokStorageAccessor] is a node specialized in saving and loading data.
## 
## This class uses different [member versions] to handle data saving
## and loading accross different game versions. [br]
## In order to do the job of managing the data it receives, this class
## must have at least one [LokStorageAccessorVersion] set in its
## [member versions] and point to it through the [member version_number]
## property. [br]
## Such version must define the logic of how the data is gathered to be
## saved and how it is used when loaded. [br]
## See more about it here [LokStorageAccessorVersion]. [br]
## [br]
## [b]Version[/b]: 1.0.0[br]
## [b]Author[/b]: [url]github.com/nadjiel[/url]
class_name LokStorageAccessor
extends Node

## The [member storage_manager] property is just a reference to the
## [LokGlobalStorageManager] autoload. [br]
## Its reference is stored in this property so it can be more easily
## mocked in unit tests. [br]
## The value of this property shouldn't be altered. Doing so may
## cause the saving and loading system to not work properly. [br]
## That's why the setter of this property is originally setup to do
## nothing, so that this property acts essentially like a constant
## unless its setter is overriden.
var storage_manager := LokGlobalStorageManager:
	set = set_storage_manager,
	get = get_storage_manager

## The [member id] property specifies what is the unique id of this
## [LokStorageAccessor]. [br]
## You should always plan your save system to make sure your
## [LokStorageAccessor]'s ids don't crash. [br]
## If they do, there may arise data inconsistency issues or even
## loss of data.
@export var id: String:
	set = set_id,
	get = get_id

## The [member partition] property specifies in what partition the
## data of this [LokStorageAccessor] should be stored. [br]
## If left empty, it means it is stored in the default partition. [br]
## The separation in partitions is useful when a [LokStorageAccessor] or
## group of [LokStorageAccessor]s have data that has to be loaded often
## by itself, like the data from a player that needs to be loaded whenever
## it logs in the game.
@export var partition: String = "":
	set = set_partition,
	get = get_partition

## The [member versions] property stores a list of [LokStorageAccessorVersion]s
## with which this [LokStorageAccessor] is able to save and load data. [br]
## Different versions can be useful if the game needs to change its data
## organization accross different versions, with the addition of features,
## for example. [br]
## To actually do something, this [LokStorageAccessor] needs at least one
## [LokStorageAccessorVersion] to save and load data. [br]
## In order for this [LokStorageAccessor] to correctly find new versions,
## they should be added to this [Array] through a new [Array], so that
## this property's setter gets triggered. Alternatively, you can use
## a method like [method Array.append], but make sure to call
## [method 
@export var versions: Array[LokStorageAccessorVersion] = []:
	set = set_versions,
	get = get_versions

## The [member version_number] property stores a [String] that points
## to one of the [member versions]' [member LokStorageAccessorVersion.number].
## [br]
## To work properly, this [LokStorageAccessor] needs to point to a
## version number existent in the [member versions] list, which is already
## done by default if the list has at least one [LokStorageAccessorVersion]
## that hadn't had its [member LokStorageAccessorVersion.number] altered.
@export var version_number: String = "1.0.0":
	set = set_version_number,
	get = get_version_number

## The [member dependency_paths] property stores a [Dictionary] that helps
## with keeping track of dependencies that this [LokStorageAccessor] needs
## to get or send data to. [br]
## This property is meant to store [String] keys and [NodePath] values that
## are sent to the active [LokStorageAccessorVersion] so that it can manipulate
## the data accordingly. [br]
## Before being sent to a [LokStorageAccessorVersion], the [NodePath]s are
## converted into [Node]s, so that the [LokStorageAccessorVersion] can
## have their references, despite being a [Resource].
@export var dependency_paths: Dictionary = {}:
	set = set_dependency_paths,
	get = get_dependency_paths

## The [member active] property is a flag that tells whether this
## [LokStorageAccessor] should save and load its data when its
## [method save_data] and [method load_data] methods try so. [br]
## By default it is set to [code]true[/code] so that this
## [LokStorageAccessor] can do its tasks as expected.
@export var active: bool = true:
	set = set_active,
	get = is_active

## The [member version] property stores the current [LokStorageAccessorVersion]
## selected by the [member version_number]. [br]
## This is the [LokStorageAccessorVersion] that's used when saving and loading
## data through this [LokStorageAccessor].
var version: LokStorageAccessorVersion:
	set = set_version,
	get = get_version

#region Setters & Getters

func set_storage_manager(new_manager: LokGlobalStorageManager) -> void:
	pass

func get_storage_manager() -> LokGlobalStorageManager:
	return storage_manager

func set_id(new_id: String) -> void:
	var old_id: String = id
	
	id = new_id
	
	if old_id != new_id:
		update_configuration_warnings()

func get_id() -> String:
	return id

func set_partition(new_partition: String) -> void:
	partition = new_partition

func get_partition() -> String:
	return partition

func set_versions(new_versions: Array[LokStorageAccessorVersion]) -> void:
	versions = new_versions
	
	update_version()

func get_versions() -> Array[LokStorageAccessorVersion]:
	return versions

func set_version_number(new_number: String) -> void:
	var old_number: String = version_number
	
	if old_number == new_number:
		return
	
	version_number = new_number
	
	update_version()

func get_version_number() -> String:
	return version_number

func set_dependency_paths(new_paths: Dictionary) -> void:
	dependency_paths = new_paths

func get_dependency_paths() -> Dictionary:
	return dependency_paths

func set_active(new_state: bool) -> void:
	active = new_state

func is_active() -> bool:
	return active

func set_version(new_version: LokStorageAccessorVersion) -> void:
	var old_version: LokStorageAccessorVersion = version
	
	version = new_version
	
	if old_version != new_version:
		update_configuration_warnings()

func get_version() -> LokStorageAccessorVersion:
	return version

#endregion

#region Debug Methods

func get_readable_name() -> String:
	if is_inside_tree():
		return str(get_path())
	if not name == "":
		return name
	
	return str(self)

func push_error_no_manager() -> void:
	push_error(
		"No StorageManager found in Accessor '%s'" % get_readable_name()
	)

func push_error_unactive_accessor() -> void:
	push_error(
		"Tried saving or loading unactive Accessor '%s'" % get_readable_name()
	)

#endregion

#region Methods

## The [method create] method is a utility to create a new
## [LokStorageAccessor] with its properties already
## set to the desired values.
static func create(
	_versions: Array[LokStorageAccessorVersion],
	_version_number: String
) -> LokStorageAccessor:
	var result := LokStorageAccessor.new()
	result.versions = _versions
	result.version_number = _version_number
	
	return result

## The [method get_dependencies] method returns a copy of the
## [member dependency_paths] [Dictionary], but with
## [Node]s as values, instead of the original [NodePath]s. [br]
## This is useful when passing their reference to the
## [method LokStorageAccessorVersion.retrieve_data] and
## [method LokStorageAccessorVersion.consume_data] methods.
func get_dependencies() -> Dictionary:
	var result: Dictionary = {}
	
	for dependency_name: Variant in dependency_paths:
		var dependency_path: Variant = dependency_paths[dependency_name]
		
		if dependency_path is NodePath:
			result[dependency_name] = get_node(dependency_path)
		else:
			result[dependency_name] = dependency_path
	
	return result

## The [method find_version] method looks through all the
## [member versions] and returns the one that has same
## [member LokStorageAccessorVersion.number] as the passed in
## the [param number] parameter. [br]
## If no such version is found, [code]null[/code] is returned.
func find_version(number: String) -> LokStorageAccessorVersion:
	for version_i: LokStorageAccessorVersion in versions:
		if version_i.number == number:
			return version_i
	
	return null

## The [method find_latest_version] method looks through all the
## [member versions] and returns the one that has the latest
## [member LokStorageAccessorVersion.number]. [br]
## If no such version is found, [code]null[/code] is returned.
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

## The [method update_version] method serves to make the [member version]
## property properly store the current version that the [member version_number]
## points to.
func update_version() -> void:
	# Uses latest version for empty version_numbers
	if version_number == "":
		version = find_latest_version()
	# Searches corresponding version for other version_numbers
	else:
		version = find_version(version_number)
	
	# Conforms version_number to current version
	# (in case its latest)
	if version != null:
		version_number = version.number

## The [method select_version] method looks through all the
## [member versions] and sets the current [member version] to be
## the one with number matching the [param number] parameter. [br]
## If no such version is found, [code]false[/code] is returned
## and the [member version] is set to [code]null[/code], else
## [code]true[/code] is returned.
func select_version(number: String) -> bool:
	set_version_number(number)
	
	var found_version: bool = version != null
	
	return found_version

## The [method save_data] method uses the
## [LokGlobalStorageManager] to save the data of this
## [LokStorageAccessor]. [br]
## By default, the version used is the [code]latest[/code],
## but that can be defined in the [param version_number]
## parameter.
func save_data(
	file_id: String,
	version_number: String = ""
) -> Dictionary:
	if not is_active():
		push_error_unactive_accessor()
		return {}
	if storage_manager == null:
		push_error_no_manager()
		return {}
	
	return storage_manager.save_data(
		file_id, version_number, [ id ], false
	)

## The [method load_data] method uses the
## [LokGlobalStorageManager] to load the data of this
## [LokStorageAccessor].
func load_data(file_id: String) -> Dictionary:
	if not is_active():
		push_error_unactive_accessor()
		return {}
	if storage_manager == null:
		push_error_no_manager()
		return {}
	
	return storage_manager.load_data(
		file_id, [ id ], [ partition ]
	)

## The [method retrieve_data] method uses the
## [method LokStorageAccessorVersion.retrieve_data]
## to collect the data that should be saved
## by the [method LokStorageAccessor.save_data] method.
func retrieve_data() -> Dictionary:
	if version == null:
		return {}
	if not is_active():
		return {}
	
	return version.retrieve_data(get_dependencies())

## The [method consume_data] method uses the
## [method LokStorageAccessorVersion.consume_data]
## to use the data that was be loaded
## by the [method LokStorageAccessor.load_data] method.
func consume_data(data: Dictionary) -> void:
	if version == null:
		return
	if not is_active():
		return
	
	version.consume_data(data, get_dependencies())

# Adds this StorageAccessor to the GlobalStorageManager
func _enter_tree() -> void:
	if storage_manager == null:
		push_error_no_manager()
		return
	
	storage_manager.add_accessor(self)

# Removes this StorageAccessor from the GlobalStorageManager
func _exit_tree() -> void:
	if storage_manager == null:
		push_error_no_manager()
		return
	
	storage_manager.remove_accessor(self)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	if version == null:
		warnings.append("Set a valid version for this Accessor to use.")
	if get_id() == "":
		warnings.append("Set a unique id to this Storage Accessor.")
	
	return warnings

#endregion
